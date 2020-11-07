defmodule BankAPI.EventRouter do
  @moduledoc false
  use Commanded.Commands.Router

  alias BankAPI.Accounts.Aggregates.Account
  alias BankAPI.Accounts.Commands.{
    OpenAccount,
    CloseAccount,
    DepositIntoAccount,
    WithdrawFromAccount
  }

  middleware BankAPI.Middleware.ValidateCommand

  identify Account, by: :account_id

  dispatch [
    OpenAccount,
    CloseAccount,
    DepositIntoAccount,
    WithdrawFromAccount
  ], to: Account
end
