defmodule BankAPI.Accounts.Projectors.DepositsAndWithdrawals do
  use Commanded.Projections.Ecto,
    application: BankAPI.EventApp,
    repo: BankAPI.Repo,
    name: "Accounts.Projectors.DepositsAndWithdrawals",
    consistency: :strong

  alias BankAPI.Accounts
  alias BankAPI.Accounts.Events.{DepositedIntoAccount, WithdrawnFromAccount}
  alias BankAPI.Accounts.Projections.Account
  alias Ecto.{Changeset, Multi}

  project(%DepositedIntoAccount{} = event, _metadata, fn multi ->
    with {:ok, %Account{} = account} <- Accounts.get_account(event.account_id) do
      Multi.update(
        multi,
        :account,
        Changeset.change(
          account,
          current_balance: event.new_current_balance
        )
      )
    else
      # ignore when this happens
      _ -> multi
    end
  end)

  project(%WithdrawnFromAccount{} = event, _metadata, fn multi ->
    with {:ok, %Account{} = account} <- Accounts.get_account(event.account_id) do
      Multi.update(
        multi,
        :account,
        Changeset.change(
          account,
          current_balance: event.new_current_balance
        )
      )
    else
      _ -> multi
    end
  end)

end