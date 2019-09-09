defmodule Full do
  # node names need to be CAPITAL
  # generate a list of children to start under supervisor
  def create_child_nodes(children) do
    # start child nodes under supervisor
    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)
    Process.register pid, Super
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

    # setup a fully connected network
    Enum.map(child_names, fn curr_name ->
      # setting neighbors for each node, in full that is every other node
      NwNode.set_neighbors(curr_name, List.delete(child_names, curr_name))
      # sending neighbor info of each node to listener
      Listener.set_neighbors(listener_pid, {curr_name, List.delete(child_names, curr_name)})
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
