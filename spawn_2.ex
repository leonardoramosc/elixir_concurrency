defmodule Spawn2 do

  def greet do
    receive do
      {sender, name} ->
        send sender, "Hello #{name}"
        greet()
    end
  end
end

greet_pid = spawn(Spawn2, :greet, [])

send greet_pid, {self(), "Leonardo"}

receive do
  message ->
    IO.puts(message)
end

send greet_pid, {self(), "Ramon"}

receive do
  message ->
    IO.puts(message)
  after 1000 ->
    IO.puts("The message has not been received")
end
