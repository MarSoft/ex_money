defmodule ExMoney.Plugs.GraphqlContext do
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    case Guardian.Plug.current_resource(conn) do
      nil -> send_resp(conn, 403, "Unauthorized") |> halt
      user -> put_private(conn, :absinthe, %{context: %{current_user: user}})
    end
  end
end
