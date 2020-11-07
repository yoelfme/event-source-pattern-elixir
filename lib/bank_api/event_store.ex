defmodule BankAPI.EventStore do
  @moduledoc false

  use EventStore, otp_app: :bank_api
end
