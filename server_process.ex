# Modulo para crear server process genericos
defmodule ServerProcess do

  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end

  defp loop(callback_module, current_state) do
    receive do
      {request, caller} ->
        {response, new_state} =
          callback_module.handle_call(request, current_state)

        send(caller, {:response, response})

        loop(callback_module, new_state)
    end
  end

  def call(server_pid, request) do
    send(server_pid, {request, self()})

    receive do
      {:response, response} ->
        response
    end
  end
end

# Este sera el modulo de ejemplo que hara uso del servidor generico
# Recordar que este modulo debe implementar dos funciones callbacks
# que seran usadas por el servidor generico: init/0, handle_call/2
defmodule KeyValueStore do

  def init do
    %{}
  end

  def start do
    ServerProcess.start(KeyValueStore)
  end

  def get(pid, key) do
    ServerProcess.call(pid, {:get, key})
  end

  def put(pid, key, value) do
    ServerProcess.call(pid, {:put, key, value})
  end

  def handle_call({:put, key, value}, state) do
    {:ok, Map.put(state, key, value)}
  end

  def handle_call({:get, key}, state) do
    {Map.get(state, key), state}
  end
end
