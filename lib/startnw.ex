defmodule Startnw do
  def start(supervisor_pid, algo) do
    child_nodes = Supervisor.which_children(supervisor_pid)
    # child_names - list of all node names
    child_names =
      Enum.map(child_nodes, fn curr_node ->
        {curr_name, _, _, _} = curr_node
        curr_name
      end)

    dead_nodes = Listener.get_dead_nodes(MyListener)
    alive_nodes = child_names -- dead_nodes

    # child_pids =
    #   Enum.map(child_nodes, fn curr_node ->
    #     {_, curr_pid, _, _} = curr_node
    #     curr_pid
    #   end)

    # sending the first GOSSIP message
    if length(alive_nodes) > 1 do
      first_node = Enum.random(alive_nodes)
      # TODO: message dynamic, current message is "Blue"

      case {algo} do
        {:gossip} ->
          NwNode.gossip(first_node, {first_node, "Blue"})

        {:pushsum} ->
          NwNode.pushsum(first_node, {first_node, 0, 0})
      end
    else
      send Main, {:done}
    end
  end
end
