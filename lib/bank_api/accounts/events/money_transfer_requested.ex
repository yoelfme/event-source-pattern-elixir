defmodule BankAPI.Accounts.Events.MoneyTransferRequested do
  @derive [Jason.Encoder]

  defstruct [
    :transfer_id,
    :source_account_id,
    :destination_account_id,
    :amount
  ]
end
