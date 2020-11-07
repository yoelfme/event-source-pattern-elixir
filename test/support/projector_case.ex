defmodule BankAPI.ProjectorCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import BankAPI.DataCase

      import BankAPI.Helpers.ProjectorUtils

      alias BankAPI.Repo
    end
  end

  setup _tags do
    :ok = BankAPI.Helpers.ProjectorUtils.truncate_database()

    :ok
  end
end
