defmodule Full do

def setup(n) do
  # node names need to be CAPITAL
  children = Enum.map(0..n-1, fn (i) ->
    node_name =  "Node" <> Integer.to_string(i) |> String.to_atom
    %{
      id: node_name,
      start: {NwNode, :start_link, [[]]}
      }
  end)

  {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)
  Supervisor.count_children(pid)

  # node_names = Enum.map children, fn(child) ->
  #   Map.get(child, :id)
  # end

  child_nodes = Supervisor.which_children(pid)
  child_pids = Enum.map child_nodes, fn(curr_node) ->
    {_, curr_pid, _, _} = curr_node
    curr_pid
  end

    Enum.map child_nodes, fn(curr_node) ->
    {node_name, curr_pid, _, _} = curr_node
    NwNode.set_neighbors(curr_pid, (List.delete(child_pids, curr_pid)))
  end

  # returning supervisor pid
  pid
end




end
