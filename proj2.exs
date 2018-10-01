:observer.start()
Process.register self(), Main
[n, topology, algo] = System.argv

{n, _} = Integer.parse(n)
topology = String.to_atom(topology)
algo = String.to_atom(algo)

{:ok, god_pid} = God.start_link(name: God)


case {topology} do
  {:full} ->
    IO.puts "Setting up #{topology} network"
    supervisor_pid = Full.setup(n, algo)
    God.kill_nodes(god_pid)
    IO.puts "Starting #{algo} algorithm"
    Startnw.start(supervisor_pid, algo)

  {:line} ->
    IO.puts "Setting up #{topology} network"
    supervisor_pid = Line.setup(n, algo)
    God.kill_nodes(god_pid)
    IO.puts "Starting #{algo} algorithm"
    Startnw.start(supervisor_pid, algo)

  {:imp2D} ->
    IO.puts "Setting up #{topology} network"
    supervisor_pid = Imp2D.setup(n, algo)
    God.kill_nodes(god_pid)
    IO.puts "Starting #{algo} algorithm"
    Startnw.start(supervisor_pid, algo)

  {:sphere} ->
    IO.puts "Setting up #{topology} network"
    supervisor_pid = Sphere.setup(n, algo)
    IO.puts "Starting #{algo} algorithm"
    God.kill_nodes(god_pid)
    Startnw.start(supervisor_pid, algo)

  {:d3} ->
    IO.puts "Setting up #{topology} network"
    supervisor_pid = D3.setup(n, algo)
    IO.puts "Starting #{algo} algorithm"
    God.kill_nodes(god_pid)
    Startnw.start(supervisor_pid, algo)

  {:rand2D} ->
    IO.puts "Setting up #{topology} network"
    supervisor_pid = Rand2D.setup(n, algo)
    IO.puts "Starting #{algo} algorithm"
    God.kill_nodes(god_pid)
    :erlang.statistics(:wall_clock)
    Startnw.start(supervisor_pid, algo)
  end

receive do 
  {:done} ->
    {_, t} = :erlang.statistics(:wall_clock)
    IO.puts "Time taken to complete #{algo} is #{t} milliseconds"
    if algo == :pushsum do
      dead_nodes = Listener.get_dead_nodes(MyListener)
      Enum.each(dead_nodes, fn node ->
        state = NwNode.get_state(node)
        s = Map.fetch!(state, :s)
        w = Map.fetch!(state, :w)
        IO.inspect(s / w)
      end)
    end
    IO.puts "Main is done"
end

