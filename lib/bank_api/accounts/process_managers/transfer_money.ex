defmodule BankAPI.Accounts.ProcessManagers.TransferMoney do
  use Commanded.ProcessManagers.ProcessManager,
    name: "Accounts.ProcessManagers.TransferMoney",
    application: BankAPI.EventApp

  require Logger


  @derive [Jason.Encoder]

  defstruct [
    :transfer_id,
    :source_account_id,
    :destination_account_id,
    :amount,
    :status
  ]

  alias BankAPI.Accounts.ProcessManagers.TransferMoney
  alias BankAPI.Accounts.Events.{
    MoneyTransferRequested,
    WithdrawnFromAccount,
    DepositedIntoAccount
  }

  alias BankAPI.Accounts.Commands.{
    WithdrawFromAccount,
    DepositIntoAccount
  }

  def interested?(%MoneyTransferRequested{transfer_id: transfer_id}), do: {:start!, transfer_id}

  def interested?(%WithdrawnFromAccount{transfer_id: transfer_id}) when is_nil(transfer_id), do: false
  def interested?(%WithdrawnFromAccount{transfer_id: transfer_id}), do: {:continue!, transfer_id}

  def interested?(%DepositedIntoAccount{transfer_id: transfer_id}) when  is_nil(transfer_id), do: false
  def interested?(%DepositedIntoAccount{transfer_id: transfer_id}), do: {:stop, transfer_id}

  def interested?(_event), do: false

  # handlers

  def handle(
    %TransferMoney{},
    %MoneyTransferRequested{
      source_account_id: source_account_id,
      amount: transfer_amount,
      transfer_id: transfer_id
    }
  ) do
    %WithdrawFromAccount{
      account_id: source_account_id,
      withdraw_amount: transfer_amount,
      transfer_id: transfer_id
    }
  end

  def handle(
    %TransferMoney{transfer_id: transfer_id} = pm,
    %WithdrawnFromAccount{transfer_id: transfer_id}
  ) do
    %DepositIntoAccount{
      account_id: pm.destination_account_id,
      deposit_amount: pm.amount,
      transfer_id: pm.transfer_id
    }
  end

  # mutate state

  def apply(
    %TransferMoney{} = pm,
    %MoneyTransferRequested{} = evt
  ) do
    %TransferMoney{
      pm
      | transfer_id: evt.transfer_id,
        source_account_id: evt.source_account_id,
        destination_account_id: evt.destination_account_id,
        amount: evt.amount,
        status: :withdraw_money_From_source_account
    }
  end

  def apply(
    %TransferMoney{} = pm,
    %WithdrawnFromAccount{}
  ) do
    %TransferMoney{
      pm
      | status: :deposit_money_in_destination_account
    }
  end

  def error(error, _command_or_event, _failure_context) do
    Logger.error(fn -> "#{__MODULE__} encountered an error: " <> inspect(error) end)

    :skip
  end
end
