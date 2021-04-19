defmodule Parallel do

  # Con esta funcion creamos un proceso por cada elemento de la coleccion
  # y cada proceso se encarga de ejecutar la funcion pasada como argumento
  # a cada uno de los elemntos. Es decir, si la coleccion tiene 1000 elementos,
  # se crearan 1000 procesos.
  def pmap(collection, fun) do

    # Obtener el PID del proceso actual
    me = self()

    collection # retornar lista de PID's
    |> Enum.map(fn (elem) ->

      # enviar al proceso principal el PID del proceso que se esta creando mas el valor
      # retornado por la funcion que se paso como parametro
      spawn_link fn -> (send me, { self(), fun.(elem) }) end

    end)
    |> Enum.map(fn (pid) ->

      # Manejar los mensajes recibidos al proceso principal
      receive do
        {^pid, value} ->
          value
      end

    end)
  end

  def no_parallel(collection) do
    Enum.map(collection, &(&1 * &1))
  end
end
