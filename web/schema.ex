defmodule ExMoney.Schema do
  use Absinthe.Schema

  import_types ExMoney.Schema.Types

  query do
    field :accounts, list_of(:account) do
      arg :show_on_dashboard, :boolean
      resolve &ExMoney.Resolver.Account.all/2
    end

    field :account, type: :account do
      arg :id, non_null(:id)
      resolve &ExMoney.Resolver.Account.find/2
    end

    field :transactions, list_of(:transaction) do
      resolve &ExMoney.Resolver.Transaction.all/2
    end

    field :transaction, type: :transaction do
      arg :id, non_null(:id)
      resolve &ExMoney.Resolver.Transaction.find/2
    end

    field :categories, list_of(:category) do
      resolve &ExMoney.Resolver.Category.all/2
    end

    field :category, type: :category do
      arg :id, non_null(:id)
      resolve &ExMoney.Resolver.Category.find/2
    end
  end
end
