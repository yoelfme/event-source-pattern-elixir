defmodule BankAPI.Accounts.Supervisor do
  use Supervisor

  alias BankAPI.Accounts.Projectors.{
    AccountOpened,
    AccountClosed,
    DepositsAndWithdrawals
  }

  alias BankAPI.Accounts.ProcessManagers.TransferMoney

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_arg) do
    children = [
      # Projectors
      Supervisor.child_spec({AccountOpened, []}, id: :account_opened),
      Supervisor.child_spec({AccountClosed, []}, id: :account_closed),
      Supervisor.child_spec({DepositsAndWithdrawals , []}, id: :deposits_and_withdrawals),

      # Process Managers
      Supervisor.child_spec({TransferMoney, []}, id: :transfer_money)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
