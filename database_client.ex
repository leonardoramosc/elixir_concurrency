defmodule DatabaseServer.Client do
  import DatabaseServer

  def run_queries(quantity, server_pool) do
    Enum.each(1..quantity, fn n ->
      server_pid = Enum.random(server_pool)
      run_async(server_pid, "Query #{n}")
    end)
  end

  def get_results(quantity) do
    Enum.map(1..quantity, fn _ -> get_result() end)
  end
end
