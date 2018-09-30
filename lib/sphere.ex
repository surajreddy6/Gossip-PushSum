defmodule Sphere do
  # node names need to be CAPITAL
  # generate a list of children to start under supervisor
  def create_child_nodes(children) do
    # start child nodes under supervisor
    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)
    Process.register pid, Super
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

    n = length(child_names)
    sq_root = :math.sqrt(n) |> trunc

    lists = Enum.chunk_every(child_names, sq_root)
    array = Utils.from_list(lists)

    Enum.each(0..(sq_root - 1), fn i ->
      Enum.each(0..(sq_root - 1), fn j ->
        curr = array[i][j]

        if i == 0 do
          cond do
            j == 0 ->
              neighbors_list = [
                array[i][j + 1],
                array[i + 1][j],
                array[i][sq_root - 1],
                array[sq_root - 1][j]
              ]

              set_neighbors(curr, listener_pid, neighbors_list)

            j == sq_root - 1 ->
              neighbors_list = [array[i][j - 1], array[i + 1][j], array[j][j], array[i][i]]
              set_neighbors(curr, listener_pid, neighbors_list)

            true ->
              neighbors_list = [
                array[i + 1][j],
                array[i][j + 1],
                array[i][j - 1],
                array[sq_root - 1][j]
              ]

              set_neighbors(curr, listener_pid, neighbors_list)
          end
        else
          if i == sq_root - 1 do
            cond do
              j == 0 ->
                neighbors_list = [array[j][j], array[i - 1][j], array[i][j + 1], array[i][i]]
                set_neighbors(curr, listener_pid, neighbors_list)

              j == sq_root - 1 ->
                neighbors_list = [array[i - 1][j], array[i][j - 1], array[i][0], array[0][j]]
                set_neighbors(curr, listener_pid, neighbors_list)

              true ->
                neighbors_list = [array[i][j - 1], array[i][j + 1], array[i - 1][j], array[0][j]]
                set_neighbors(curr, listener_pid, neighbors_list)
            end
          end
        end

        if j == 0 && (i != 0 && i != sq_root - 1) do
          neighbors_list = [
            array[i][j + 1],
            array[i - 1][j],
            array[i + 1][j],
            array[i][sq_root - 1]
          ]

          set_neighbors(curr, listener_pid, neighbors_list)
        end

        if j == sq_root - 1 && (i != 0 && i != sq_root - 1) do
          neighbors_list = [array[i][j - 1], array[i + 1][j], array[i - 1][j], array[i][0]]
          set_neighbors(curr, listener_pid, neighbors_list)
        end

        # join checks

        if i != 0 && i != sq_root - 1 && j != 0 && j != sq_root - 1 do
          neighbors_list = [array[i][j - 1], array[i - 1][j], array[i][j + 1], array[i + 1][j]]
          # NwNode.set_neighbors(curr, neighbors_list)
          # Listener.set_neighbors(listener_pid, {curr, neighbors_list})
          set_neighbors(curr, listener_pid, neighbors_list)
        end
      end)
    end)

    # IO.inspect(child_names)
    # for the first and last node

    # returning supervisor pid
    pid
  end

  defp set_neighbors(curr, listener_pid, neighbors_list) do
    NwNode.set_neighbors(curr, neighbors_list)
    Listener.set_neighbors(listener_pid, {curr, neighbors_list})
  end

  # setting up intial topology - FULL
  def setup(n, algo) do
    sq_root = :math.sqrt(n)
    n = (:math.ceil(sq_root) * :math.ceil(sq_root)) |> trunc

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
