defmodule Link2 do

  import :timer, only: [sleep: 1]

  def sad_function do

    sleep(500)

    exit(:mamalo)
  end

  def run do

    spawn_link(Link2, :sad_function, [])

    receive do
      msg ->
        IO.puts("MESSAGE RECEIVED: #{msg}")
      after 1000 ->
        IO.puts("NOTHING HAPPENED")
    end

  end
end

Link2.run()
