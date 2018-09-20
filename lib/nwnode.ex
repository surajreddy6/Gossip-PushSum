defmodule NwNode do
  use GenServer

  def start_link(args, opts) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def set_neighbors(server, args) do
    GenServer.cast(server, {:set_neighbors, args})
  end

  def gossip(server, args) do
    GenServer.cast(server, {:gossip, args})
  end

  def pushsum(server, args) do
    GenServer.cast(server, {:pushsum, args})
  end

  def init(:gossip) do
    {:ok, %{:neigh => [], :count => 0, :msg => ""}}
  end

  def init({:pushsum, start_number}) do
    {:ok, %{:neigh => [], :s => start_number, :w => 1, :queue => :queue.new}}
  end

  def handle_cast({:set_neighbors, args}, state) do
    state = Map.replace!(state, :neigh, args)
    {:noreply, state}
  end

  def handle_cast({:gossip, args}, state) do
    # for first time receiving msg update state
    {server, msg} = args
    count = Map.get(state, :count)

    if count < 5 do
      next_neighbor = Enum.random(Map.get(state, :neigh))
      NwNode.gossip(next_neighbor, {next_neighbor, msg})
      Process.send_after(server, {:gossip, args}, :rand.uniform(100))

      # TODO figure out how to update state only once - scope issue
      state = Map.replace!(state, :msg, msg)

      {:noreply, Map.replace!(state, :count, count + 1)}
    else
      IO.puts("I'm done")
      {:noreply, state}
    end
  end

  def handle_cast({:pushsum, args}, state) do
    {server, new_s, new_w} = args

    # create a function for this repeatitive thing
    s = Map.fetch!(state, :s)
    w = Map.fetch!(state, :w)

    # ratio from previous iteration
    old_ratio = s/w

    state = Map.replace!(state, :s, s + new_s)
    state = Map.replace!(state, :w, w + new_w)

    # storing half the updated s and w : Need to send and retain the same
    s_t = Map.fetch!(state, :s) / 2
    w_t = Map.fetch!(state, :w) / 2

    # creating queue to store the s/w
    queue = Map.fetch!(state, :queue)
    ratio = s_t/w_t

    ratio_diff = abs(ratio - old_ratio)

    if :queue.len(queue) == 3 do
      queue_list = :queue.to_list(queue)
      boolean_list = Enum.map(queue_list, fn(i) ->
        i <= 0.001
      end)
      # IO.puts "boolean_list"
      # IO.inspect boolean_list
      if boolean_list == [true, true, true] do
        #terminate
        # IO.puts "I'm done"
        {:noreply, state}
      else
        state = Map.replace!(state, :s, s_t)
        state = Map.replace!(state, :w, w_t)
        next_neighbor = Enum.random(Map.get(state, :neigh))
        {_, queue} = :queue.out(queue)
        queue = :queue.in(ratio_diff, queue)
        state = Map.replace!(state, :queue, queue)
        NwNode.pushsum(next_neighbor, {next_neighbor, s_t, w_t})
        Process.send_after(server, {:pushsum, {server, s_t, w_t}}, :rand.uniform(100))
        {:noreply, state}
      end
    else
      state = Map.replace!(state, :s, s_t)
      state = Map.replace!(state, :w, w_t)
      next_neighbor = Enum.random(Map.get(state, :neigh))
      queue = :queue.in(ratio_diff, queue)
      state = Map.replace!(state, :queue, queue)
      NwNode.pushsum(next_neighbor, {next_neighbor, s_t, w_t})
      Process.send_after(server, {:pushsum, {server, s_t, w_t}}, :rand.uniform(100))
      {:noreply, state}
    end
  end

  def handle_info({:pushsum, args}, state) do
    {server, new_s, new_w} = args
    # TODO handle termination
    NwNode.pushsum(server, {server, new_s, new_w})
    {:noreply, state}
  end

  def handle_info({:gossip, args}, state) do
    {server, msg} = args
    count = Map.get(state, :count)

    if count < 5 do
      NwNode.gossip(server, {server, msg})
    end

    {:noreply, state}
  end
end
