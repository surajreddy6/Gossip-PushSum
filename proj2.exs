:observer.start()
[n, topology, algo] = System.argv

{n, _} = Integer.parse(n)
topology = String.to_atom(topology)
algo = String.to_atom(algo)


case {topology} do
  {:full} ->
    supervisor_pid = Full.setup(n, algo)
    Startnw.start(supervisor_pid, algo)
    :timer.sleep(10000000)

  {:line} ->
    supervisor_pid = Line.setup(n, algo)
    Startnw.start(supervisor_pid, algo)
    :timer.sleep(10000000)

  {:imp2D} ->
    supervisor_pid = Imp2D.setup(n, algo)
    Startnw.start(supervisor_pid, algo)
    :timer.sleep(10000000)

  {:sphere} ->
    supervisor_pid = Sphere.setup(n, algo)
    Startnw.start(supervisor_pid, algo)
    :timer.sleep(10000000)

  {:d3} ->
    supervisor_pid = D3.setup(n, algo)
    Startnw.start(supervisor_pid, algo)
    :timer.sleep(10000000)

    # case {algo} do
    #   {:gossip} ->
    #     Startnw.start(supervisor_pid)
    #
    #   {:pushsum} ->
    #       #hfbkigskfehr
    #
    #   end
  end
