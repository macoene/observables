defmodule Observables.Filter do
  @moduledoc """
  Range takes a start and end value and produces all the values in between.
  """
  use Observables.GenObservable

  def init([filter]) do
    Logger.debug("Filter: #{inspect(self())}")
    # We don't keep state in merge.
    {:ok, %{:pred => filter}}
  end

  def handle_event(v, state = %{:pred => f}) do
    if f.(v) do
      {:value, v, state}
    else
      {:novalue, state}
    end
  end

  def handle_done(pid, _state) do
    Logger.debug("#{inspect(self())}: dependency stopping: #{inspect(pid)}")
    {:ok, :continue}
  end
end
