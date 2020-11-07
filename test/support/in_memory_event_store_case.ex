defmodule BankAPI.InMemoryEventStoreCase do
  use ExUnit.CaseTemplate


  using do
    quote do
      import BankAPI.Helpers.AggregateUtils

      alias Commanded.EventStore.Adapters.InMemory
    end
  end

  setup do
    on_exit(fn ->
      :ok = Application.stop(:bank_api)
      :ok = Application.stop(:commanded)

      {:ok, _apps} = Application.ensure_all_started(:bank_api)

      :ok = BankAPI.Helpers.ProjectorUtils.truncate_database()
    end)
  end
end
