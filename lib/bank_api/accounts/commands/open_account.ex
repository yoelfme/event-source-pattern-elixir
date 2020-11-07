defmodule BankAPI.Accounts.Commands.OpenAccount do
  @enforce_keys [:account_id]
  defstruct [:account_id, :initial_balance]

  alias BankAPI.Accounts
  alias BankAPI.Accounts.Commands.Validators

  def valid?(command) do
    Skooma.valid?(Map.from_struct(command), schema())
  end

  defp schema do
    %{
      account_id: [:string, Skooma.Validators.regex(Accounts.uuid_regex())],
      initial_balance: [:int, &Validators.positive_integer(&1)]
    }
  end
end
