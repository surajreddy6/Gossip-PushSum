defmodule Startnw do
  def start(supervisor_pid, algo) do
    child_nodes = Supervisor.which_children(supervisor_pid)
    # child_names - list of all node names
    child_names =
      Enum.map(child_nodes, fn curr_node ->
        {curr_name, _, _, _} = curr_node
        curr_name
      end)

    # child_pids =
    #   Enum.map(child_nodes, fn curr_node ->
    #     {_, curr_pid, _, _} = curr_node
    #     curr_pid
    #   end)

    # sending the first GOSSIP message
    first_node = Enum.random(child_names)
    # TODO: message dynamic, current message is "Blue"

    case {algo} do
      {:gossip} ->
        NwNode.gossip(first_node, {first_node, "Blue"})

      {:pushsum} ->
        NwNode.pushsum(first_node, {first_node, 0, 0})
    end
  end
end
