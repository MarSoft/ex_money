defmodule ExMoney.Resolver.Transaction do
  alias ExMoney.{Repo, Transaction}

  def all(_args, _info) do
    {:ok, Repo.all(Transaction)}
  end

  def find(%{id: id}, _info) do
    case Repo.get(Transaction, id) do
      nil -> {:error, "Transaction id #{id} not found"}
      transaction -> {:ok, transaction}
    end
  end
end
