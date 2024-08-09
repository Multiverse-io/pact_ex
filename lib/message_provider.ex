defmodule PactEx.MessageProvider do
  @moduledoc """
  A mock provider that returns a JSON response containing a message payload
  and optionally metadata. Responds to a single request.
  """

  @doc """
  Starts the message provider on an unused port and returns the port.
  """
  @spec start(map(), map()) :: integer
  def start(response_body, metadata \\ %{}) do
    pid = self()

    Task.start(fn ->
      {:ok, listen_socket} = :gen_tcp.listen(0, [:binary, packet: :raw])

      send(pid, :inet.port(listen_socket))

      process_request(listen_socket, response_body, metadata)
    end)

    receive do
      {:ok, port} -> port
    end
  end

  @spec process_request(:inet.socket(), map(), map()) :: :ok
  defp process_request(listen_socket, response_body, metadata) do
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)
    :gen_tcp.recv(client_socket, 0)

    response = create_response(response_body, metadata)

    :gen_tcp.send(client_socket, response)
    :gen_tcp.close(client_socket)
  end

  @spec create_response(map(), map()) :: String.t()
  defp create_response(response_body, metadata) do
    body = Jason.encode!(response_body)

    """
    HTTP/1.1 200 OK\r
    Content-Type: application/json\r
    Content-Length: #{byte_size(body)}\r
    Pact-Message-Metadata: #{Base.encode64(Jason.encode!(metadata))}\r
    \r
    #{body}
    """
    |> String.trim_trailing()
  end
end
