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
      {:ok, %{:neigh => [], :count => 0, :msg => nil}}
  end

  def handle_cast({:set_neighbors, args}, state) do
    state = Map.replace!(state, :neigh, args)
    {:noreply, state}
  end

  def handle_cast({:gossip, args}, state) do
    # for first time receiving msg update state

    {server, msg} = args
    count = Map.get(state, :count)
    #if count is 10 then handle
    #IO.inspect %{count: count, pid: server}
    if count < 5 do
      # IO.puts "Gossiping"
      next_neighbor = Enum.random(Map.get(state, :neigh))
      #IO.inspect %{gossiping_with: next_neighbor, im: server}
      NwNode.gossip(next_neighbor, {next_neighbor, msg})
      # send a message to the current node to continue gossiping
      Process.send_after(server, {:gossip, args}, :rand.uniform(100))
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
