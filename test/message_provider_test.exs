defmodule PactEx.MessageProviderTest do
  use ExUnit.Case
  alias PactEx.MessageProvider

  describe "start/2" do
    test "responds with message payload and metadata for a single request" do
      payload = %{"message" => "Hello"}
      metadata = %{"routing_key" => "message.sent"}

      port = MessageProvider.start(payload, metadata)

      assert {:ok, %{status: 200, body: body, headers: headers}} =
               Tesla.get("http://localhost:#{port}")

      assert Jason.decode!(body) == payload

      assert [
               {"content-length", "19"},
               {"content-type", "application/json"},
               {"pact-message-metadata", Base.encode64(Jason.encode!(metadata))}
             ] == headers

      assert {:error, :econnrefused} =
               Tesla.get("http://localhost:#{port}")
    end
  end
end
