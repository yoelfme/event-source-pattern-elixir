defmodule BankAPI.Accounts.Aggregates.Account do
  defstruct id: nil, current_balance: nil, closed?: false

  alias BankAPI.Accounts.Aggregates.Account
  alias BankAPI.Accounts.Commands.{
    OpenAccount,
    CloseAccount,
    DepositIntoAccount,
    WithdrawFromAccount
  }
  alias BankAPI.Accounts.Events.{
    AccountOpened,
    AccoundClosed,
    DepositedIntoAccount,
    WithdrawnFromAccount
  }

  # command handlers
  def execute(
    %Account{id: account_id, closed?: false, current_balance: current_balance},
    %DepositIntoAccount{
      account_id: account_id,
      deposit_amount: amount
    }
  ) do
    %DepositedIntoAccount{
      account_id: account_id,
      new_current_balance: current_balance + amount
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
    %WithdrawFromAccount{account_id: account_id, withdraw_amount: amount}
  ) do
    if current_balance - amount > 0 do
      %WithdrawnFromAccount{
        account_id: account_id,
        new_current_balance: current_balance - amount
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
end
