defmodule BankAPI.EventApp do
  @moduledoc false

  @default [
    adapter: Commanded.EventStore.Adapters.EventStore,
    event_store: BankAPI.EventStore
  ]

  use Commanded.Application,
    otp_app: :bank_api,
    event_store: Application.get_env(:bank_api, :event_store, @default)

  router BankAPI.EventRouter
end
