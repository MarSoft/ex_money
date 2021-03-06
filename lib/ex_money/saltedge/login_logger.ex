defmodule ExMoney.Saltedge.LoginLogger do
  use GenServer
  require Logger

  alias ExMoney.{Repo, LoginLog, Login}

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: :login_logger)
  end

  def log_event(callback, event, login_id, params) do
    GenServer.cast(:login_logger, {:log, callback, event, login_id, params})
  end

  def handle_cast({:log, callback, event, saltedge_login_id, params}, state) do
    login_logger_enabled = Application.get_env(:ex_money, :login_logger_worker)[:enabled]
    login = Login.by_saltedge_login_id(saltedge_login_id) |> Repo.one

    case {login_logger_enabled, login} do
      {false, _} -> :nothing
      {_, nil} -> Logger.error("Could not create a login log entry, login with saltedge_login_id #{saltedge_login_id} not found")
      {_, login} ->
        changeset = LoginLog.changeset(%LoginLog{}, %{
          callback: callback,
          event: event,
          params: params,
          login_id: login.id
        })

        case Repo.insert(changeset) do
          {:ok, _} -> Logger.info("Login log entry has been created.")
          {:error, changeset} -> Logger.error("Could not create a login log entry, #{inspect(changeset.errors)}")
        end
    end

    {:noreply, state}
  end
end
