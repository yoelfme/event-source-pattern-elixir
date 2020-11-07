defmodule BankAPI.Accounts.Projectors.AccountOpenedTest do
  use BankAPI.ProjectorCase

  alias BankAPI.Accounts.Projections.Account
  alias BankAPI.Accounts.Events.AccountOpened
  alias BankAPI.Accounts.Projectors.AccountOpened, as: Projector

  test "should succeed with valid data" do
    id = UUID.uuid4()

    account_opened_event = %AccountOpened{
      account_id: id,
      initial_balance: 1_000
    }

    last_seen_event_number = get_last_seen_event_number("Accounts.Projectors.AccountOpened")

    assert :ok = Projector.handle(
      account_opened_event,
      %{
        event_number: last_seen_event_number + 1,
        handler_name: ""
      }
    )

    assert only_instance_of(Account).current_balance == 1_000
    assert only_instance_of(Account).id == id
  end
end
