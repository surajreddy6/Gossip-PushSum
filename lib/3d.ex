defmodule D3 do
  # node names need to be CAPITAL
  # generate a list of children to start under supervisor
  def create_child_nodes(children) do
    # start child nodes under supervisor
    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)
    Process.register(pid, Super)
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

    max = 2
    n = length(child_names)
    # each stack will have n/3 nodes - as we will have three stacks
    each_n = (n / max) |> trunc
    sqroot_each_n = :math.sqrt(each_n) |> trunc
    lists = Enum.chunk_every(child_names, each_n)

    list_2darray =
      Enum.map(lists, fn each_list ->
        list = Enum.chunk_every(each_list, sqroot_each_n)
        Utils.from_list(list)
      end)

    d3array = 0..length(list_2darray) |> Stream.zip(list_2darray) |> Enum.into(%{})

    # IO.inspect(d3array)

    # setting up basic 2D grip topology 
    Enum.each(d3array, fn {key, val} ->
      d2_setup(val, sqroot_each_n, listener_pid)
    end)

    # setting the 3D neighbors
    Enum.each(0..(max - 1), fn k ->
      Enum.each(0..(sqroot_each_n - 1), fn i ->
        Enum.each(0..(sqroot_each_n - 1), fn j ->
          cond do
            k == 0 ->
              NwNode.update_neighbors(d3array[k][i][j], [d3array[k + 1][i][j]])
              Listener.update_neighbors(listener_pid, {d3array[k][i][j], [d3array[k + 1][i][j]]})

            k == max - 1 ->
              NwNode.update_neighbors(d3array[k][i][j], [d3array[k - 1][i][j]])
              Listener.update_neighbors(listener_pid, {d3array[k][i][j], [d3array[k - 1][i][j]]})

            true ->
              NwNode.update_neighbors(d3array[k][i][j], [
                d3array[k - 1][i][j],
                d3array[k + 1][i][j]
              ])

              Listener.update_neighbors(
                listener_pid,
                {d3array[k][i][j], [d3array[k - 1][i][j], d3array[k + 1][i][j]]}
              )
          end
        end)
      end)
    end)

    # returning supervisor pid
    pid
  end

  def d2_setup(array, sq_root, listener_pid) do
    Enum.each(0..(sq_root - 1), fn i ->
      Enum.each(0..(sq_root - 1), fn j ->
        curr = array[i][j]

        if i == 0 do
          cond do
            j == 0 ->
              neighbors_list = [
                array[i][j + 1],
                array[i + 1][j]
              ]

              set_neighbors(curr, listener_pid, neighbors_list)

            j == sq_root - 1 ->
              neighbors_list = [array[i][j - 1], array[i + 1][j]]
              set_neighbors(curr, listener_pid, neighbors_list)

            true ->
              neighbors_list = [
                array[i + 1][j],
                array[i][j + 1],
                array[i][j - 1]
              ]

              set_neighbors(curr, listener_pid, neighbors_list)
          end
        else
          if i == sq_root - 1 do
            cond do
              j == 0 ->
                neighbors_list = [array[i - 1][j], array[i][j + 1]]
                set_neighbors(curr, listener_pid, neighbors_list)

              j == sq_root - 1 ->
                neighbors_list = [array[i - 1][j], array[i][j - 1]]
                set_neighbors(curr, listener_pid, neighbors_list)

              true ->
                neighbors_list = [array[i][j - 1], array[i][j + 1], array[i - 1][j]]
                set_neighbors(curr, listener_pid, neighbors_list)
            end
          end
        end

        if j == 0 && (i != 0 && i != sq_root - 1) do
          neighbors_list = [array[i][j + 1], array[i - 1][j], array[i + 1][j]]
          set_neighbors(curr, listener_pid, neighbors_list)
        end

        if j == sq_root - 1 && (i != 0 && i != sq_root - 1) do
          neighbors_list = [array[i][j - 1], array[i + 1][j], array[i - 1][j]]
          set_neighbors(curr, listener_pid, neighbors_list)
        end

        if i != 0 && i != sq_root - 1 && j != 0 && j != sq_root - 1 do
          neighbors_list = [array[i][j - 1], array[i - 1][j], array[i][j + 1], array[i + 1][j]]
          set_neighbors(curr, listener_pid, neighbors_list)
        end
      end)
    end)
  end

  defp set_neighbors(curr, listener_pid, neighbors_list) do
    NwNode.set_neighbors(curr, neighbors_list)
    Listener.set_neighbors(listener_pid, {curr, neighbors_list})
  end

  # setting up intial topology - FULL
  def setup(n, algo) do
    max = 2
    each_n = (n / max) |> :math.ceil() |> trunc
    sq_root = :math.sqrt(each_n)
    each_n = (:math.ceil(sq_root) * :math.ceil(sq_root)) |> trunc
    n = each_n * max

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
