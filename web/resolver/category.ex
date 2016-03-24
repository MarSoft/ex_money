defmodule ExMoney.Resolver.Category do
  alias ExMoney.{Repo, Category}

  def all(_args, _info) do
    {:ok, Repo.all(Category)}
  end

  def find(%{id: id}, _info) do
    case Repo.get(Category, id) do
      nil -> {:error, "Category id #{id} not found"}
      category -> {:ok, category}
    end
  end
end
