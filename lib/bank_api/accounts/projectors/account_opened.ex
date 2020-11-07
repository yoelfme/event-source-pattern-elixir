defmodule BankAPI.Accounts.Projectors.AccountOpened do
  use Commanded.Projections.Ecto,
    application: BankAPI.EventApp,
    repo: BankAPI.Repo,
    name: "BankAPI.Accounts.Projectors.AccountOpened"

    alias BankAPI.Accounts.Events.AccountOpened
    alias BankAPI.Accounts.Projections.Account

    project(
      %AccountOpened{account_id: account_id, initial_balance: initial_balance},
      _metadata,
      fn multi ->
        Ecto.Multi.insert(multi, :account_opened, %Account{
          id: account_id,
          current_balance: initial_balance,
          status: Account.status().open
        })
      end
    )
end
