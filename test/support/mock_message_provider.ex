defmodule PactEx.MockMessageProvider do
  @moduledoc """
  A mock provider that returns a 200 response with a JSON body
  and metadata encoded in the `Pact-Message-Metadata` header.
  """
  @behaviour Plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.put_resp_header(
      "Pact-Message-Metadata",
      Base.encode64(Jason.encode!(%{routing_key: "user.added"}))
    )
    |> Plug.Conn.send_resp(200, Jason.encode!(%{name: "John"}))
  end
end
