defmodule TodoServer do

  def start() do
    todo_server = spawn(fn -> loop(TodoList.new()) end)
    Process.register(todo_server, :todo_server)
  end

  def entries(date) do
    send(:todo_server, {:entries, self(), date})

    receive do
      {:todo_entries, entries} ->
        entries
      after 5000 ->
        {:error, :timeout}
    end

  end

  def add_entry(entry) do
    send(:todo_server, {:add_entry, entry})
  end

  defp loop(todo) do
    new_todo =
      receive do
        message -> process_message(todo, message)
      end

    loop(new_todo)
  end

  defp process_message(todo, {:entries, caller, date}) do
    entries = TodoList.entries(todo, date)
    send(caller, {:todo_entries, entries})
    todo
  end

  defp process_message(todo, {:add_entry, entry}) do
    TodoList.add_entry(todo, entry)
  end

end

defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      &add_entry(&2, &1)
    )
  end

  # Example Entry:
  # %{date: ~D[2021-04-25], title: "Dentist"}

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)
    new_entries = Map.put(todo_list.entries, todo_list.auto_id, entry)

    %TodoList{todo_list | entries: new_entries, auto_id: todo_list.auto_id + 1}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        new_entry = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    %TodoList{todo_list | entries: Map.delete(todo_list.entries, entry_id)}
  end
end
