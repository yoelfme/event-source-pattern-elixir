defmodule BankAPI.Accounts.Commands.Validators do
  def positive_integer(value, minimum \\ 0) do
    with {:is_integer, true} <- {:is_integer, is_integer(value)},
         {:is_greather, true} <- {:is_greather, value > minimum} do
      :ok
    else
      {:is_integer, false} ->
        {:error, "Argument must be an integer"}

      {:is_greather, false} ->
        {:error, "Argument must be bigget than #{minimum}"}
    end
  end
end
