defmodule Line do
  # node names need to be CAPITAL
  # generate a list of children to start under supervisor
  def create_child_nodes(children) do
    # start child nodes under supervisor
    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)
    # to listen to all the child nodes (keeping track of dead or alive state)
    {:ok, listener_pid} = Listener.start_link(name: MyListener)

    # get pids, names of child nodes
    # Supervisor.count_children(pid)
    child_nodes = Supervisor.which_children(pid)

    # extract child names
    child_names =
      Enum.map(child_nodes, fn curr_node ->
        {curr_name, _, _, _} = curr_node
        curr_name
      end)

    # IO.inspect(child_names)
    # for the first and last node

    # TODO: put this in a clean function
    first_node = Enum.fetch!(child_names, 0)
    last_node = Enum.fetch!(child_names, length(child_names) - 1)
    NwNode.set_neighbors(first_node, [Enum.fetch!(child_names, 1)])
    Listener.set_neighbors(listener_pid, {first_node, [Enum.fetch!(child_names, 1)]})
    NwNode.set_neighbors(last_node, [Enum.fetch!(child_names, length(child_names) - 2)])

    Listener.set_neighbors(
      listener_pid,
      {last_node, [Enum.fetch!(child_names, length(child_names) - 2)]}
    )

    # setup a line network
    Enum.each(1..(length(child_names) - 2), fn i ->
      prev = Enum.fetch!(child_names, i - 1)
      curr = Enum.fetch!(child_names, i)
      next = Enum.fetch!(child_names, i + 1)
      NwNode.set_neighbors(curr, [prev, next])
      Listener.set_neighbors(listener_pid, {curr, [prev, next]})
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
