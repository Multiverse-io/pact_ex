defmodule PactEx.ProviderTest do
  use ExUnit.Case
  import PactEx
  alias PactEx.{MockProvider, MockMessageProvider}

  # See https://docs.pact.io/implementation_guides/rust/pact_verifier_cli#verifying-message-pacts
  describe "provider verification" do
    test "success when providers match pacts" do
      # Start a mock provider on an unused port
      {:ok, pid} = Bandit.start_link(plug: MockProvider, port: 0)

      # Get the port of the mock provider
      {:ok, {_address, port}} = ThousandIsland.listener_info(pid)

      # Ensure the server is up
      assert {:ok, _} =
               Tesla.get("http://localhost:#{port}/", headers: [{"Authorization", "Bearer 123"}])

      # Start a mock provider on an unused port for messages
      {:ok, pid} = Bandit.start_link(plug: MockMessageProvider, port: 0)

      # Get the port of the mock provider for messages
      {:ok, {_address, message_port}} = ThousandIsland.listener_info(pid)

      # Ensure the server is up for messages
      assert {:ok, _} = Tesla.get("http://localhost:#{message_port}/")

      # Verify pacts against the mock provider
      verifier =
        verifier_new_for_application("tests", "1.0.0")
        |> verifier_set_provider_info("Provider", "http", "localhost", port, "")
        |> verifier_add_custom_header("Authorization", "Bearer 123")
        |> verifier_add_provider_transport("message", message_port, "", "")
        |> verifier_add_directory_source("test/pacts")

      assert verifier_execute(verifier), "Verification failed"

      verifier_shutdown(verifier)
    end
  end
end
