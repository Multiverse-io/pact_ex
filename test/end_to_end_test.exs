defmodule PactEx.EndToEndTest do
  @moduledoc """
  Expects the Pact Broker to be running at http://localhost:9292.
  Publishes a contract to the Pact Broker, then verifies it.
  """

  use ExUnit.Case
  import PactEx
  alias PactEx.MockProvider

  @tag :requires_broker
  test "publishes and verifies a contract" do
    pact = File.read!("test/pacts/Consumer-Provider.json")

    # Publish the contract to the Pact Broker
    assert {:ok, %{status: 200}} =
             PactEx.BrokerClient.client("http://localhost:9292")
             |> PactEx.BrokerClient.publish_contracts("Consumer", [{"Provider", pact}])

    # Verify the contract

    # Start a mock provider on an unused port
    {:ok, pid} = Bandit.start_link(plug: MockProvider, port: 0)
    # Get the port of the mock provider
    {:ok, {_address, port}} = ThousandIsland.listener_info(pid)

    version = PactEx.Git.get_hash!()
    branch = PactEx.Git.get_branch!()

    verifier =
      verifier_new_for_application("Provider", version)
      |> verifier_set_provider_info("Provider", "http", "localhost", port)
      |> verifier_set_publish_options(version, "", [], branch)
      |> verifier_add_provider_transport("message", port, "/message")
      |> verifier_add_custom_header("Authorization", "Bearer 123")
      |> verifier_broker_source("http://localhost:9292", "", "", "")

    assert verifier_execute(verifier), "Verification failed"

    verifier_shutdown(verifier)
  end
end
