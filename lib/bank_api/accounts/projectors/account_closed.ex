defmodule BankAPI.Accounts.Projectors.AccountClosed do
  use Commanded.Projections.Ecto,
    application: BankAPI.EventApp,
    repo: BankAPI.Repo,
    name: "BankAPI.Accounts.Projectors.AccountClosed"

  alias BankAPI.Accounts
  alias BankAPI.Accounts.Events.AccoundClosed
  alias BankAPI.Accounts.Projections.Account
  alias Ecto.{Changeset, Multi}

  project(%AccoundClosed{} = event, _metadata, fn multi ->
    with {:ok, %Account{} = account} <- Accounts.get_account(event.account_id) do
      Multi.update(
        multi,
        :account,
        Changeset.change(account, status: Account.status().closed)
      )
    else
      # ignore when this happens
      _ -> multi
    end
  end)
end
