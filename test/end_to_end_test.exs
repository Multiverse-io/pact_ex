defmodule PactEx.EndToEndTest do
  @moduledoc """
  Expects the Pact Broker to be running at http://localhost:9292.
  Publishes a contract to the Pact Broker, then verifies it.
  """

  use ExUnit.Case
  import PactEx
  alias PactEx.{MockProvider, MockMessageProvider}

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

    # Ensure the server is up
    assert {:ok, _} =
             Tesla.get("http://localhost:#{port}/", headers: [{"Authorization", "Bearer 123"}])

    # Start a mock provider on an unused port for messages
    {:ok, pid} = Bandit.start_link(plug: MockMessageProvider, port: 0)

    # Get the port of the mock provider for messages
    {:ok, {_address, message_port}} = ThousandIsland.listener_info(pid)

    # Ensure the server is up for messages
    assert {:ok, _} = Tesla.get("http://localhost:#{message_port}/")

    version = PactEx.Git.get_hash!()
    branch = PactEx.Git.get_branch!()

    assert verifier_new_for_application("Provider", version)
           |> verifier_set_provider_info("Provider", "http", "localhost", port, "")
           |> verifier_set_publish_options(version, "", [], branch)
           |> verifier_add_provider_transport("message", message_port, "", "")
           |> verifier_add_custom_header("Authorization", "Bearer 123")
           |> verifier_broker_source("http://localhost:9292", "", "", "")
           |> verifier_execute()
  end
end
