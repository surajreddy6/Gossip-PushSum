defmodule Listener do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def set_neighbors(server, args) do
    GenServer.cast(server, {:set_neighbors, args})
  end

  def delete_me(server, node_name) do
    # node_name is passed
    GenServer.cast(server, {:delete_me, node_name})
  end

  def gossip_done(server, node_name) do
    # node_name is passed
    GenServer.cast(server, {:gossip_done, node_name})
  end

  def init(:ok) do
    {:ok, %{:dead_nodes => [], :neighbors => %{}}}
  end

  def handle_cast({:set_neighbors, args}, state) do
    {node_name, node_neighbors} = args
    neighbors_list = Map.fetch!(state, :neighbors)
    neighbors_list = Map.put(neighbors_list, node_name, node_neighbors)
    state = Map.replace!(state, :neighbors, neighbors_list)
    {:noreply, state}
  end

  def handle_cast({:gossip_done, node_name}, state) do
    neighbors_list = Map.fetch!(state, :neighbors)
    dead_nodes = Map.fetch!(state, :dead_nodes)
    dead_nodes = [node_name | dead_nodes]
    # fetch neighbors of the node to be deleted. 
    curr_neighbors = Map.fetch!(neighbors_list, node_name)
    # iterate through the neighbors of the node to be deleted
    Enum.each(curr_neighbors, fn neighbor ->
      # neighbors_neighbors is a list of each (neighbor of node_name)'s neighbors
      neighbors_neighbors = Map.fetch!(neighbors_list, neighbor)
      neighbors_neighbors = List.delete(neighbors_neighbors, node_name)
      # now neighbors_neighbors is the new updated list
      neighbors_list = Map.replace!(neighbors_list, neighbor, neighbors_neighbors)
      # update each node's neighbors list in nwnode.ex
      NwNode.remove_neighbor(neighbor, node_name)
      state = Map.replace!(state, :neighbors, neighbors_list)
    end)

    neighbors_list_count = Enum.count(Map.keys(neighbors_list))

    if Enum.count(dead_nodes) == neighbors_list_count do
      IO.puts("All done!!")
      exit(:shutdown)
    end

    state = Map.replace!(state, :dead_nodes, dead_nodes)
    {:noreply, state}
  end

  def handle_cast({:delete_me, node_name}, state) do
    dead_nodes = Map.fetch!(state, :dead_nodes)
    IO.inspect(dead_nodes)

    if node_name not in dead_nodes do
      dead_nodes = [node_name | dead_nodes]
      state = Map.replace!(state, :dead_nodes, dead_nodes)

      neighbors_list = Map.fetch!(state, :neighbors)
      # curr_neighbors is a list of node_name's neighbors
      curr_neighbors = Map.fetch!(neighbors_list, node_name)

      Enum.map(curr_neighbors, fn neighbor ->
        # neighbors_neighbors is a list of each (neighbor of node_name)'s neighbors
        neighbors_neighbors = Map.fetch!(neighbors_list, neighbor)
        neighbors_neighbors = List.delete(neighbors_neighbors, node_name)
        # now neighbors_neighbors is the new updated list
        neighbors_list = Map.replace!(neighbors_list, neighbor, neighbors_neighbors)
        NwNode.remove_neighbor(neighbor, node_name)
        state = Map.replace!(state, :neighbors, neighbors_list)
      end)

      {:noreply, state}
    else
      {:noreply, state}
      # the end for if
    end
  end
end
