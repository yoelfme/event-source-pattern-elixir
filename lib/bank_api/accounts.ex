defmodule BankAPI.Accounts do
  @moduledoc """
  The Accounts context
  """
  alias BankAPI.Repo
  alias BankAPI.EventApp
  alias BankAPI.Accounts.Commands.{
    OpenAccount,
    CloseAccount,
    DepositIntoAccount,
    WithdrawFromAccount,
    TransferBetweenAccounts
  }
  alias BankAPI.Accounts.Projections.Account

  import Ecto.Query, warn: false

  def uuid_regex do
    ~r/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/
  end

  def get_account(id), do: {:ok, Repo.get(Account, id)}

  def transfer(source_id, amount, destination_id) do
    %TransferBetweenAccounts{
      account_id: source_id,
      transfer_id: UUID.uuid4(),
      transfer_amount: amount,
      destination_account_id: destination_id
    }
    |> EventApp.dispatch()
  end

  def close_account(id) do
    %CloseAccount{
      account_id: id
    }
    |> EventApp.dispatch()
  end

  def deposit(id, amount) do
    dispatch_result = %DepositIntoAccount{
      account_id: id,
      deposit_amount: amount
    }
    |> EventApp.dispatch(consistency: :strong)

    case dispatch_result do
      :ok ->
        {
          :ok,
          Repo.get!(Account, id)
        }

      reply ->
        reply
    end
  end
  def withdraw(id, amount) do
    dispatch_result =
      %WithdrawFromAccount{
        account_id: id,
        withdraw_amount: amount
      }
      |> EventApp.dispatch(consistency: :strong)

    case dispatch_result do
      :ok -> {
        :ok,
        Repo.get!(Account, id)
      }

      reply ->
        reply
    end
  end
  def open_account(%{"initial_balance" => initial_balance}) do
    account_id = UUID.uuid4()

    dispatch_result = %OpenAccount{
      initial_balance: initial_balance,
      account_id: account_id
    }
    |> EventApp.dispatch(consistency: :strong)

    case dispatch_result do
      :ok ->
        {
          :ok,
          # get_account(account_id)
          %Account{
            id: account_id,
            current_balance: initial_balance,
            status: Account.status().open
          }
        }

      reply ->
        reply
    end
  end

  def open_account(_params), do: {:error, :bad_command}
end
