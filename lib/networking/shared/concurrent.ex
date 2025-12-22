defmodule Networking.Shared.Concurrent do
  @doc """
  Concurrency utilities
  """

  def race_tasks(tasks) do
    Enum.each(tasks, fn task ->
      Task.start(task)
    end)
  end
end
