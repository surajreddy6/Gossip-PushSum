defmodule Full do
  # node names need to be CAPITAL
  # generate a list of children to start under supervisor
  def create_child_nodes(children) do
    # start child nodes under supervisor
    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)

    :timer.sleep(2000)
    # get pids, names of child nodes
    Supervisor.count_children(pid)
    child_nodes = Supervisor.which_children(pid)

    child_pids =
      Enum.map(child_nodes, fn curr_node ->
        {_, curr_pid, _, _} = curr_node
            IO.puts "What is alive"
            IO.inspect Process.alive?(curr_pid)
        curr_pid
      end)

    # setup a fully connected network
    Enum.map(child_nodes, fn curr_node ->
      {node_name, curr_pid, _, _} = curr_node
      NwNode.set_neighbors(curr_pid, List.delete(child_pids, curr_pid))
    end)

    # returning supervisor pid
    pid
  end

  def setup(n, algo) do
    case {algo} do
      {:gossip} ->
        children =
          Enum.map(0..(n - 1), fn i ->
            node_name = ("Node" <> Integer.to_string(i)) |> String.to_atom()

            %{
              id: node_name,
              start: {NwNode, :start_link, [:gossip, []]}
            }
          end)

        create_child_nodes(children)

      {:pushsum} ->
        children =
          Enum.map(0..(n - 1), fn i ->
            node_name = ("Node" <> Integer.to_string(i)) |> String.to_atom()
            %{
              id: node_name,
              start: {NwNode, :start_link, [{:pushsum, i}, []]}
            }
          end)

        create_child_nodes(children)
    end
  end
end
