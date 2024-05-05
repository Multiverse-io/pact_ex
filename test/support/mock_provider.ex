defmodule PactEx.MockProvider do
  @moduledoc """
  A mock provider that returns a 200 response with a JSON body if the
  Authorization header is set to 'Bearer 123', otherwise returns a 401.
  In a real application, you would replace this with your actual provider.
  """
  @behaviour Plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(%Plug.Conn{} = conn, _opts) do
    case List.keyfind(conn.req_headers, "authorization", 0) do
      {"authorization", "Bearer 123"} ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{name: "John"}))

      _ ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(401, Jason.encode!(%{error: "Unauthorized"}))
    end
  end
end
