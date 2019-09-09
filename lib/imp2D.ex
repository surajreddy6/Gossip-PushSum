defmodule Imp2D do
  # node names need to be CAPITAL
  # generate a list of children to start under supervisor
  def create_child_nodes(children) do
    # setup a line network
    pid = Line.create_child_nodes(children)

    # get pids, names of child nodes
    # Supervisor.count_children(pid)
    child_nodes = Supervisor.which_children(pid)

    # extract child names
    child_names =
      Enum.map(child_nodes, fn curr_node ->
        {curr_name, _, _, _} = curr_node
        curr_name
      end)

    Enum.each(child_names, fn curr_node ->
      neighbors = NwNode.get_neighbors(curr_node)
      random_node = Enum.random(child_names)
      NwNode.set_neighbors(curr_node, [random_node | neighbors])
      Listener.set_neighbors(MyListener, {curr_node, [random_node | neighbors]})

      # TODO: Play around with this
      # random_node_neighbors = NwNode.get_neighbors(random_node)
      # NwNode.set_neighbors(random_node, [curr_node | random_node_neighbors])
      # Listener.set_neighbors(MyListener, {random_node, [curr_node | random_node_neighbors]})
    end)

    # returning supervisor pid
    pid
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
