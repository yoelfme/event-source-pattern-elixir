defmodule BankAPIWeb.AccountView do
  use BankAPIWeb, :view
  alias BankAPIWeb.AccountView

  alias BankAPI.Accounts.Projections.Account

  def render("show.json", %{account: account}) do
    %{data: render_one(account, AccountView, "account.json")}
  end

  def render("account.json", %{account: account}) do
    if account.status == Account.status().closed do
      %{
        id: account.id,
        current_balance: account.current_balance
      }
    else
      %{
        id: account.id,
        status: account.status
      }
    end
  end
end
