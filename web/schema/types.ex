defmodule ExMoney.Schema.Types do
  use Absinthe.Schema.Notation

  object :account do
    field :id, :id
    field :saltedge_account_id, :integer
    field :saltedge_login_id, :integer
    field :name, :string
    field :nature, :string
    field :balance, :string
    field :currency_code, :string
    field :currency_label, :string
    field :balance, :decimal
    field :show_on_dashboard, :boolean
  end

  object :transaction do
    field :id, :id
    field :saltedge_transaction_id, :integer
    field :saltedge_account_id, :integer
    field :account_id, :integer
    field :category_id, :integer
    field :user_id, :integer
    field :mode, :string
    field :status, :string
    field :made_on, :time
    field :amount, :decimal
    field :currency_code, :string
    field :description, :string
  end

  object :category do
    field :id, :id
    field :parent_id, :integer
    field :name, :string
    field :humanized_name, :string
    field :css_color, :string
  end

  scalar :decimal, description: "BigDecimal type" do
    parse &Decimal.new(&1)
    serialize &Decimal.to_string(&1, :normal)
  end

  scalar :time, description: "strftime" do
    parse &Timex.DateFormat.parse(&1, "%Y-%m-%d", :strftime)
    serialize fn(date) ->
      {:ok, serialized} = Ecto.Date.to_erl(date)
      |> Timex.Date.from
      |> Timex.DateFormat.format("%Y-%m-%d", :strftime)

      serialized
    end
  end
end
