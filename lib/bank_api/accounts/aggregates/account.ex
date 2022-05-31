defmodule BankAPI.Accounts.Aggregates.Account do
  @derive Jason.Encoder
  defstruct id: nil, current_balance: nil, closed?: false

  alias BankAPI.Accounts.Aggregates.Account
  alias BankAPI.Accounts.Commands.{
    OpenAccount,
    CloseAccount,
    DepositIntoAccount,
    WithdrawFromAccount,
    TransferBetweenAccounts
  }
  alias BankAPI.Accounts.Events.{
    AccountOpened,
    AccoundClosed,
    DepositedIntoAccount,
    WithdrawnFromAccount,
    MoneyTransferRequested
  }

  # command handlers
  def execute(
    %Account{id: account_id, closed?: false, current_balance: current_balance},
    %DepositIntoAccount{
      account_id: account_id,
      deposit_amount: amount,
      transfer_id: transfer_id
    }
  ) do
    %DepositedIntoAccount{
      account_id: account_id,
      new_current_balance: current_balance + amount,
      transfer_id: transfer_id
    }
  end

  def execute(
    %Account{id: account_id, closed?: true},
    %DepositIntoAccount{account_id: account_id}
  ) do
    {:error, :account_closed}
  end

  def execute(
    %Account{},
    %DepositIntoAccount{}
  ) do
    {:error, :not_found}
  end

  def execute(
    %Account{id: account_id, closed?: false, current_balance: current_balance},
    %WithdrawFromAccount{account_id: account_id, withdraw_amount: amount, transfer_id: transfer_id}
  ) do
    if current_balance - amount > 0 do
      %WithdrawnFromAccount{
        account_id: account_id,
        new_current_balance: current_balance - amount,
        transfer_id: transfer_id
      }
    else
      {:error, :insufficient_funds}
    end
  end

  def execute(
    %Account{id: account_id, closed?: true},
    %WithdrawFromAccount{account_id: account_id}
  ) do
    {:error, :account_closed}
  end

  def execute(
    %Account{},
    %WithdrawFromAccount{}
  ) do
    {:error, :not_found}
  end

  def execute(
    %Account{id: account_id, closed?: true},
    %CloseAccount{
      account_id: account_id
    }
  ) do
    {:error, :account_already_closed}
  end

  def execute(
    %Account{id: account_id, closed?: false},
    %CloseAccount{
      account_id: account_id
    }
  ) do
    %AccoundClosed{
      account_id: account_id
    }
  end

  def execute(
    %Account{},
    %CloseAccount{}
  ) do
    {:error, :not_found}
  end

  def execute(
    %Account{id: nil},
    %OpenAccount{
      account_id: account_id,
      initial_balance: initial_balance
    }
  ) when initial_balance > 0 do
    %AccountOpened{
      account_id: account_id,
      initial_balance: initial_balance
    }
  end

  def execute(
    %Account{id: nil},
    %OpenAccount{
      initial_balance: initial_balance
    }
  ) when initial_balance <= 0 do
    {:error, :initial_balance_must_be_above_zero}
  end

  def execute(%Account{}, %OpenAccount{}) do
    {:error, :account_already_opened}
  end

  def execute(
    %Account{id: account_id, closed?: true},
    %TransferBetweenAccounts{
      account_id: account_id
    }), do: {:error, :account_closed}

  def execute(
    %Account{id: account_id, closed?: false},
    %TransferBetweenAccounts{
      account_id: account_id,
      destination_account_id: destination_account_id
    }
  ) when account_id === destination_account_id do
    {:error, :transfer_to_same_account}
  end

  def execute(
    %Account{id: account_id, closed?: false, current_balance: current_balance},
    %TransferBetweenAccounts{
      account_id: account_id,
      transfer_amount: transfer_amount
    }
  ) when current_balance < transfer_amount do
    {:error, :insufficient_funds}
  end

  def execute(
    %Account{id: account_id, closed?: false},
    %TransferBetweenAccounts{
      account_id: account_id,
      transfer_id: transfer_id,
      transfer_amount: transfer_amount,
      destination_account_id: destination_account_id
    }
  ) do
    %MoneyTransferRequested{
      transfer_id: transfer_id,
      source_account_id: account_id,
      amount: transfer_amount,
      destination_account_id: destination_account_id
    }
  end

  def execute(
    %Account{},
    %TransferBetweenAccounts{}
  ) do
    {:error, :not_found}
  end

  # state mutators

  def apply(
    %Account{
      id: account_id,
      current_balance: _current_balance
    } = account,
    %DepositedIntoAccount{
      account_id: account_id,
      new_current_balance: new_current_balance
    }
  ) do
    %Account{
      account
      | current_balance: new_current_balance
    }
  end

  def apply(
    %Account{
      id: account_id,
      current_balance: _current_balance
    } = account,
    %WithdrawnFromAccount{
      account_id: account_id,
      new_current_balance: new_current_balance
    }
  ) do
    %Account{
      account
      | current_balance: new_current_balance
    }
  end

  def apply(
    %Account{} = account,
    %AccountOpened{
      account_id: account_id,
      initial_balance: initial_balance
    }
  ) do
    %Account{
      account
      | id: account_id,
        current_balance: initial_balance
    }
  end

  def apply(
    %Account{id: account_id} = account,
    %AccoundClosed{
      account_id: account_id
    }
  ) do
    %Account{
      account
      | closed?: true
    }
  end

  def apply(
    %Account{} = account,
    %MoneyTransferRequested{}
  ) do
    account
  end
end
