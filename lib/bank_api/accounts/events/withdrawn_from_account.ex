defmodule BankAPI.Accounts.Events.WithdrawnFromAccount do
  @derive [Jason.Encoder]

  defstruct [
    :account_id,
    :new_current_balance,
    :transfer_id
  ]
end
