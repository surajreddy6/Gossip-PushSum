defmodule NwNode do
  use GenServer

  def start_link(args, opts) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def get_state(server) do
    GenServer.call(server, {:get_state}, :infinity)
  end

  def set_neighbors(server, args) do
    GenServer.cast(server, {:set_neighbors, args})
  end

  def update_neighbors(server, args) do
    GenServer.cast(server, {:update_neighbors, args})
  end

  def get_neighbors(server) do
    GenServer.call(server, {:get_neighbors}, :infinity)
  end

  def remove_neighbor(server, node_name) do
    GenServer.cast(server, {:remove_neighbor, node_name})
  end

  def die(server) do
    GenServer.cast(server, {:die, server})
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
    {:ok, %{:neigh => [], :s => start_number, :w => 1, :queue => :queue.new()}}
  end

  def handle_cast({:remove_neighbor, node_name}, state) do
    neighbors = Map.fetch!(state, :neigh)
    neighbors = List.delete(neighbors, node_name)
    state = Map.replace!(state, :neigh, neighbors)
    {:noreply, state}
  end

  def handle_cast({:set_neighbors, args}, state) do
    state = Map.replace!(state, :neigh, args)
    {:noreply, state}
  end

  def handle_cast({:update_neighbors, args}, state) do
    neighbors = Map.fetch!(state, :neigh)
    neighbors = neighbors ++ args
    # IO.inspect neighbors
    state = Map.replace!(state, :neigh, neighbors)
    {:noreply, state}
  end

  def handle_cast({:gossip, args}, state) do
    # for first time receiving msg update state
    # server -  current nodes name
    {server, msg} = args
    count = Map.get(state, :count)


    if count < 10 do
      # picking a random neighbor from the current node's (server's) neighbor list
      neighbors = Map.get(state, :neigh)
      if neighbors == [] do
        # IO.puts("No neighbors to reach")
        Listener.delete_me(MyListener, server)
        Startnw.start(Super, :gossip)
        {:noreply, state}
      else
        next_neighbor = Enum.random(neighbors)
        NwNode.gossip(next_neighbor, {next_neighbor, msg})
        Process.send_after(server, {:gossip, args}, 0)

        # TODO: figure out how to update state only once - scope issue
        state = Map.replace!(state, :msg, msg)
        {:noreply, Map.replace!(state, :count, count + 1)}
      end
    else
      # IO.puts("I'm done")
      Listener.gossip_done(MyListener, server)
      # delete current node from all the neighbors list
      Enum.each(Map.get(state, :neigh), fn neighbor_node ->
        NwNode.remove_neighbor(neighbor_node, server)
      end)

      {:noreply, state}
    end
  end

  def handle_cast({:pushsum, args}, state) do
    {server, new_s, new_w} = args
    neighbors = Map.get(state, :neigh)
    # create a function for this repeatitive thing
    s = Map.fetch!(state, :s)
    w = Map.fetch!(state, :w)

    # ratio from previous iteration
    old_ratio = s / w

    state = Map.replace!(state, :s, s + new_s)
    state = Map.replace!(state, :w, w + new_w)

    # storing half the updated s and w : Need to send and retain the same
    s_t = Map.fetch!(state, :s) / 2
    w_t = Map.fetch!(state, :w) / 2

    # creating queue to store the s/w
    queue = Map.fetch!(state, :queue)
    ratio = s_t / w_t

    ratio_diff = abs(ratio - old_ratio)

    # when the current node has no neighbors to communicate
    if neighbors == [] do
      # IO.puts("No neighbors to reach")
      Listener.delete_me(MyListener, server)
      Startnw.start(Super, :pushsum)
      {:noreply, state}
    else
      if :queue.len(queue) == 3 do
        queue_list = :queue.to_list(queue)

        boolean_list =
          Enum.map(queue_list, fn i ->
            i <= 0.0000000001
          end)

        if boolean_list == [true, true, true] do
          # terminate
          # IO.puts "I'm done"
          next_neighbor = Enum.random(Map.get(state, :neigh))
          NwNode.pushsum(next_neighbor, {next_neighbor, s_t, w_t})
          Listener.delete_me(MyListener, server)
          state = Map.replace!(state, :s, s_t)
          state = Map.replace!(state, :w, w_t)

          # delete current node from all the neighbors list
          Enum.each(neighbors, fn neighbor_node ->
            NwNode.remove_neighbor(neighbor_node, server)
          end)

          # IO.inspect "I'm terminating"
          {:noreply, state}
        else
          state = Map.replace!(state, :s, s_t)
          state = Map.replace!(state, :w, w_t)
          next_neighbor = Enum.random(Map.get(state, :neigh))
          {_, queue} = :queue.out(queue)
          queue = :queue.in(ratio_diff, queue)
          state = Map.replace!(state, :queue, queue)
          NwNode.pushsum(next_neighbor, {next_neighbor, s_t, w_t})
          {:noreply, state}
        end
      else
        state = Map.replace!(state, :s, s_t)
        state = Map.replace!(state, :w, w_t)
        next_neighbor = Enum.random(Map.get(state, :neigh))
        queue = :queue.in(ratio_diff, queue)
        state = Map.replace!(state, :queue, queue)
        NwNode.pushsum(next_neighbor, {next_neighbor, s_t, w_t})
        {:noreply, state}
      end
    end
  end

  def handle_cast({:die, server}, state) do
    neighbors = Map.fetch!(state, :neigh)
    Enum.each(neighbors, fn neigh ->
      NwNode.remove_neighbor(neigh, server)
    end)
    {:noreply, state}
  end

  def handle_call({:get_neighbors}, _from, state) do
    neighbors = Map.fetch!(state, :neigh)
    {:reply, neighbors, state}
  end

  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
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
