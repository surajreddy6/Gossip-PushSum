defmodule God do
    use GenServer

    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def init(:ok) do
        {:ok, []}
    end

    def kill_nodes(server) do
        GenServer.cast(server, {:kill_nodes})
    end

    def handle_cast({:kill_nodes}, state) do
        :timer.sleep(:rand.uniform(2000))
        IO.puts "Killing spree!!"
        data = Listener.get_state(MyListener)
        all_nodes = Map.keys(data[:neighbors])
        kill_ratio = 0.2
        num_nodes_to_kill = length(all_nodes) * kill_ratio |> trunc
        nodes_to_kill = Enum.map(0..num_nodes_to_kill-1, fn i->
            Enum.random(all_nodes)
        end)
        Enum.each(nodes_to_kill, fn node ->
            NwNode.die(node)
        end)
        {:noreply, state}
    end
end