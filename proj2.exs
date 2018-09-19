[n, topology, algo] = System.argv

{n, _} = Integer.parse(n)
topology = String.to_atom(topology)
algo = String.to_atom(algo)


case {topology} do
  {:full} ->
    supervisor_pid = Full.setup(n, algo)
    Startnw.start(supervisor_pid, algo)

    # case {algo} do
    #   {:gossip} ->
    #     Startnw.start(supervisor_pid)
    #
    #   {:pushsum} ->
    #       #hfbkigskfehr
    #
    #   end
  end
