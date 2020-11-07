defmodule BankAPI.Accounts.EventHandler.AccountOpened do
  use Commanded.Event.Handler,
    application: BankAPI.EventApp,
    name: __MODULE__,
    consistency: :strong

  alias BankAPI.Accounts.Events.AccountOpened
  alias BankAPI.Accounts.Projections.Account
  alias BankAPI.Repo

  def handle(%AccountOpened{account_id: account_id, initial_balance: initial_balance}, _metadata) do
    Repo.insert(%Account{
      id: account_id,
      current_balance: initial_balance
    })
  end
end
