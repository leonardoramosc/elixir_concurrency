defmodule Calculator do

  def start do
    spawn(fn -> loop(0) end)
  end

  def val(pid) do
    send(pid, {:value, self()})

    receive do
      value -> value
      after 1000 ->
        "None value was received."
    end
  end

  def add(pid, value) do
    send(pid, {:add, value})
  end

  def sub(pid, value) do
    send(pid, {:subtract, value})
  end

  defp loop(current_value) do
    new_value =
      receive do
        message -> process_message(current_value, message)
      end

    loop(new_value)
  end

  defp process_message(current_value, {:value, caller}) do
    send(caller, current_value)
    current_value
  end

  defp process_message(current_value, {:add, value}) do
    current_value + value
  end

  defp process_message(current_value, {:subtract, value}) do
    current_value - value
  end

  defp process_message(current_value, invalid_request) do
    IO.puts("You sent an invalid request: #{IO.inspect(invalid_request)}")
    current_value
  end
end
