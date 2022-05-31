defmodule BankAPI.Accounts.Commands.TransferBetweenAccounts do
  @enforce_keys [:account_id, :transfer_id]

  defstruct [:account_id, :transfer_id, :transfer_amount, :destination_account_id]

  alias BankAPI.Repo
  alias BankAPI.Accounts
  alias BankAPI.Accounts.Commands.Validators
  alias BankAPI.Accounts.Projections.Account

  def valid?(command) do
    cmd = Map.from_struct(command)

    with %Account{} <- account_exists?(cmd.destination_account_id),
      true <- account_open?(cmd.destination_account_id) do
        Skooma.valid?(cmd, schema())
      else
        nil ->
          {:error, ["Destination account does not exist"]}

        false ->
          {:error, ["Destination account closed"]}

        reply ->
          reply
      end
  end

  defp schema do
    %{
      account_id: [:string, Skooma.Validators.regex(Accounts.uuid_regex())],
      transfer_id: [:string, Skooma.Validators.regex(Accounts.uuid_regex())],
      transfer_amount: [:int, &Validators.positive_integer(&1, 1)],
      destination_account_id: [:string, Skooma.Validators.regex(Accounts.uuid_regex())]
    }
  end

  defp account_exists?(account_id) do
    Repo.get!(Account, account_id)
  end

  defp account_open?(account_id) do
    account = Repo.get!(Account, account_id)
    account.status == Account.status().open
  end
end
