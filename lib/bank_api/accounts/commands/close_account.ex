defmodule BankAPI.Accounts.Commands.CloseAccount do
  @enforce_keys [:account_id]
  defstruct [:account_id]

  alias BankAPI.Accounts

  def valid?(command) do
    Skooma.valid?(Map.from_struct(command), schema())
  end

  defp schema do
    %{
      account_id: [:string, Skooma.Validators.regex(Accounts.uuid_regex())]
    }
  end
end
