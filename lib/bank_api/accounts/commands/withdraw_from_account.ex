defmodule BankAPI.Accounts.Commands.WithdrawFromAccount do
  @enforce_keys [:account_id]
  defstruct [:account_id, :withdraw_amount, :transfer_id]

  alias BankAPI.Accounts
  alias BankAPI.Accounts.Commands.Validators

  def valid?(command) do
    Skooma.valid?(Map.from_struct(command), schema())
  end

  defp schema do
    %{
      account_id: [:string, Skooma.Validators.regex(Accounts.uuid_regex())],
      withdraw_amount: [:int, &Validators.positive_integer(&1, 1)]
    }
  end
end
