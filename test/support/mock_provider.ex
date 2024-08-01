defmodule PactEx.MockProvider do
  @moduledoc """
  A mock provider that has two routes
  In a real application, you would use your actual server.

  GET / returns a 200 response with a JSON body if the
  Authorization header is set to 'Bearer 123', otherwise returns a 401.

  POST /message returns a 200 response with a JSON body
  and metadata encoded in the `Pact-Message-Metadata` header
  """
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
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
    |> Plug.Conn.halt()
  end

  post "/message" do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.put_resp_header(
      "Pact-Message-Metadata",
      Base.encode64(Jason.encode!(%{routing_key: "user.added"}))
    )
    |> Plug.Conn.send_resp(200, Jason.encode!(%{name: "John"}))
    |> Plug.Conn.halt()
  end
end
