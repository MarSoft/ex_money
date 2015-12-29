defmodule ExMoney.DashboardController do
  use ExMoney.Web, :controller

  alias ExMoney.Repo
  alias ExMoney.Transaction
  alias ExMoney.Account

  alias ExMoney.SessionController
  alias Guardian.Plug.EnsureAuthenticated

  plug EnsureAuthenticated, %{ on_failure: { SessionController, :new } }

  def overview(conn, _params) do
    recent_transactions = Transaction.recent
    |> Repo.all
    |> Enum.group_by(fn(transaction) ->
      transaction.made_on
    end)
    |> Enum.sort(fn({date_1, _transactions}, {date_2, _transaction}) ->
      Ecto.Date.compare(date_1, date_2) != :lt
    end)

    last_month_transactions = Transaction.last_month
    |> Repo.all

    accounts = Account.show_on_dashboard
    |> Repo.all

    render conn, "overview.html",
      navigation: "overview",
      topbar: "dashboard",
      recent_transactions: recent_transactions,
      last_month_transactions: last_month_transactions,
      accounts: accounts
  end
end
