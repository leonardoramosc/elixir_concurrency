defmodule Spawn1 do

  def greet do
    receive do
      {sender, message} ->
        send sender, "Hello #{message}"
    end
  end
end

pid = spawn(Spawn1, :greet, [])

send pid, {self, "World!"}

receive do
  message ->
    IO.puts(message)
end
