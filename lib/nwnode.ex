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
    IO.inspect %{pid: server, count: count}
    if count < 5 do
      # IO.puts "Gossiping"
      next_neighbor = Enum.random(Map.get(state, :neigh))
      IO.inspect %{im: server, gossiping_with: next_neighbor}
      NwNode.gossip(next_neighbor, {next_neighbor, msg})
      {:noreply, Map.replace!(state, :count, count + 1)}
    else
      IO.puts "I'm done"
      {:noreply, state}
    end
  end

end
