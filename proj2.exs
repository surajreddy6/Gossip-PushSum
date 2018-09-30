:observer.start()
Process.register self(), Main
[n, topology, algo] = System.argv

{n, _} = Integer.parse(n)
topology = String.to_atom(topology)
algo = String.to_atom(algo)


case {topology} do
  {:full} ->
    IO.puts "Setting up #{topology} network"
    supervisor_pid = Full.setup(n, algo)
    IO.puts "Starting #{algo} algorithm"
    Startnw.start(supervisor_pid, algo)

  {:line} ->
    IO.puts "Setting up #{topology} network"
    supervisor_pid = Line.setup(n, algo)
    IO.puts "Starting #{algo} algorithm"
    Startnw.start(supervisor_pid, algo)

  {:imp2D} ->
    IO.puts "Setting up #{topology} network"
    supervisor_pid = Imp2D.setup(n, algo)
    IO.puts "Starting #{algo} algorithm"
    Startnw.start(supervisor_pid, algo)

  {:sphere} ->
    IO.puts "Setting up #{topology} network"
    supervisor_pid = Sphere.setup(n, algo)
    IO.puts "Starting #{algo} algorithm"
    Startnw.start(supervisor_pid, algo)

  {:d3} ->
    IO.puts "Setting up #{topology} network"
    supervisor_pid = D3.setup(n, algo)
    IO.puts "Starting #{algo} algorithm"
    Startnw.start(supervisor_pid, algo)
  end

receive do 
  {:done} ->
    IO.puts "Main is done"
end

