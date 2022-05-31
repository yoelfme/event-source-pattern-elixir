defmodule BankAPI.Accounts.Events.AccoundClosed do
  @derive [Jason.Encoder]
  defstruct [:account_id]
end
