defmodule DatabaseServer do

  def start do
    spawn(fn ->
      connection = :random.uniform(100)
      loop(connection)
    end)
  end

  def run_async(server_pid, query_def) do
    send server_pid, {:run_query, self(), query_def}
  end

  def get_result do
    receive do
      {:query_result, result} ->
        result
      after 5000 ->
        {:error, :timeout}
    end
  end

  def get_pool(quantity) when is_integer(quantity) do
    Enum.map(1..quantity, fn _ -> start() end)
  end

  defp loop(connection) do
    receive do
      {:run_query, caller, query_def} ->
        send caller, {:query_result, run_query(connection, query_def)}
    end
    loop(connection)
  end

  defp run_query(connection, query_def) do
    Process.sleep(2000)
    %{connection: connection, result: query_def}
  end
end
