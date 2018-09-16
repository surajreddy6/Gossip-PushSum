[n, topology, algo] = System.argv

{n, _} = Integer.parse(n)
topology = String.to_atom(topology)
algo = String.to_atom(algo)


gossip = fn(supervisor_pid) ->
  child_nodes = Supervisor.which_children(supervisor_pid)
  child_pids = Enum.map child_nodes, fn(curr_node) ->
    {_, curr_pid, _, _} = curr_node
    curr_pid
  end
  # sending the first GOSSIP message
  first_node = Enum.random(child_pids)
  NwNode.gossip(first_node, {first_node, "Blue"})

  # # wait for async node to complete computation
  # Enum.map child_pids, fn (i) ->
  #     state_after_exec = :sys.get_state(i, :infinity)
  # end

  # Read state of all nodes
  Enum.each 0..5, fn i ->
    :timer.sleep(2000)
    IO.puts "Iteration - #{i}"
    Enum.map child_nodes, fn child ->
      {_, pid, _, _} = child
      IO.inspect :sys.get_state pid
    end
  end
end


case {topology} do
  {:full} ->
    supervisor_pid = Full.setup(n)
    gossip.(supervisor_pid)
end