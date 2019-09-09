defmodule Rand2D do
  # node names need to be CAPITAL
  # generate a list of children to start under supervisor
  def create_child_nodes(children) do
    # start child nodes under supervisor
    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)
    Process.register(pid, Super)
    # Process.register self(), Super
    # to listen to all the child nodes (keeping track of dead or alive state)
    {:ok, listener_pid} = Listener.start_link(name: MyListener)
    # get pids, names of child nodes
    child_nodes = Supervisor.which_children(pid)

    # extract child names
    child_names =
      Enum.map(child_nodes, fn curr_node ->
        {curr_name, _, _, _} = curr_node
        curr_name
      end)

    precision = 2
    co_list = Enum.map(child_names, fn node ->
      x = Float.round(:rand.uniform(), precision)
      y = Float.round(:rand.uniform(), precision)
      {node, {x, y}}
    end)

    # IO.inspect co_list

    Enum.each(co_list, fn curr_node ->
      neighbors = get_neighbors(curr_node, co_list -- [curr_node]) |> Enum.filter(& !is_nil(&1))
      {current_node, _} = curr_node
      NwNode.set_neighbors(current_node, neighbors)
      Listener.set_neighbors(listener_pid, {current_node, neighbors})
    end)

    # returning supervisor pid
    pid
  end

  defp get_neighbors(curr_node, co_list) do
    {current_node, {x_c, y_c}} = curr_node
    neighbors = Enum.map(co_list, fn {node, {x, y}} ->
      dist = :math.sqrt(:math.pow((x_c - x), 2) + :math.pow((y_c - y), 2)) |> Float.round(1)
      # IO.puts "Distance between #{current_node} and #{node}: #{dist}"
      if dist <= 0.1 do
        node
      end
    end)
  end

  # setting up intial topology - FULL
  def setup(n, algo) do
    case {algo} do
      {:gossip} ->
        children =
          Enum.map(0..(n - 1), fn i ->
            node_name = ("Node" <> Integer.to_string(i)) |> String.to_atom()

            %{
              id: node_name,
              start: {NwNode, :start_link, [:gossip, [name: node_name]]}
            }
          end)

        create_child_nodes(children)

      {:pushsum} ->
        children =
          Enum.map(0..(n - 1), fn i ->
            node_name = ("Node" <> Integer.to_string(i)) |> String.to_atom()

            %{
              id: node_name,
              # assigning each node to value i initially
              start: {NwNode, :start_link, [{:pushsum, i}, [name: node_name]]}
            }
          end)

        create_child_nodes(children)
    end
  end
end
