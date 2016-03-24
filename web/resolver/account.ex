defmodule ExMoney.Resolver.Account do
  alias ExMoney.{Repo, Account}

  def all(args, _info) do
    scope = case args[:show_on_dashboard] do
      true -> Account.show_on_dashboard
      _ -> Account
    end
    {:ok, Repo.all(scope)}
  end

  def find(%{id: id}, _info) do
    case Repo.get(Account, id) do
      nil -> {:error, "Account id #{id} not found"}
      account -> {:ok, account}
    end
  end
end
