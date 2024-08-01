defmodule PactEx.ProviderTest do
  use ExUnit.Case
  import PactEx
  alias PactEx.MockProvider

  # See https://docs.pact.io/implementation_guides/rust/pact_verifier_cli#verifying-message-pacts
  describe "provider verification" do
    test "success when providers match pacts" do
      # Start a mock provider on an unused port
      {:ok, pid} = Bandit.start_link(plug: MockProvider, port: 0)
      # Get the port of the mock provider
      {:ok, {_address, port}} = ThousandIsland.listener_info(pid)

      # Ensure the server is up
      assert {:ok, _} = Tesla.get("http://localhost:#{port}")
      assert {:ok, _} = Tesla.post("http://localhost:#{port}/message", "{}")

      # Verify pacts against the mock provider
      verifier =
        verifier_new_for_application("tests", "1.0.0")
        |> verifier_set_provider_info("Provider", "http", "localhost", port)
        |> verifier_add_custom_header("Authorization", "Bearer 123")
        |> verifier_add_provider_transport("message", port, "/message")
        |> verifier_add_directory_source("test/pacts")

      assert verifier_execute(verifier), "Verification failed"

      Process.exit(pid, :normal)

      verifier_shutdown(verifier)
    end
  end
end
