defmodule BankAPI.EventRouter do
  @moduledoc false
  use Commanded.Commands.Router

  alias BankAPI.Accounts.Aggregates.{
    Account,
    AccountLifespan
  }

  alias BankAPI.Accounts.Commands.{
    OpenAccount,
    CloseAccount,
    DepositIntoAccount,
    WithdrawFromAccount,
    TransferBetweenAccounts
  }

  middleware BankAPI.Middleware.ValidateCommand

  identify Account, by: :account_id

  dispatch [
    OpenAccount,
    CloseAccount,
    DepositIntoAccount,
    WithdrawFromAccount,
    TransferBetweenAccounts
  ], to: Account, lifespan: AccountLifespan
end
