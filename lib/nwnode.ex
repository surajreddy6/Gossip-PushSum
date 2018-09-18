defmodule NwNode do
  use GenServer

  def start_link(opts)  do
      GenServer.start_link(__MODULE__, :ok, opts)
  end

  def set_neighbors(server, args) do
    GenServer.cast(server, {:set_neighbors, args})
  end

  def gossip(server, args) do
    GenServer.cast(server, {:gossip, args})
  end

  def init(:ok) do
      {:ok, %{:neigh => [], :count => 0, :msg => ""}}
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

      #TODO figure out how to update state only once - scope issue
      state = Map.replace!(state, :msg, msg)

      {:noreply, Map.replace!(state, :count, count + 1)}
    else
      IO.puts "I'm done"
      {:noreply, state}
    end
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
