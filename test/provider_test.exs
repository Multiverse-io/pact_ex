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

      # Verify pacts against the mock provider
      verifier =
        verifier_new_for_application("tests", "1.0.0")
        |> verifier_set_provider_info("Provider", "http", "localhost", port)
        |> verifier_add_custom_header("Authorization", "Bearer 123")
        |> verifier_add_provider_transport("message", port, "/message")
        |> verifier_add_directory_source("test/pacts")

      assert verifier_execute(verifier), "Verification failed"

      verifier_shutdown(verifier)
    end

    test "failure when server returns a response that doesn't match" do
      # Start a mock provider on an unused port
      {:ok, pid} = Bandit.start_link(plug: MockProvider, port: 0)

      # Get the port of the mock provider
      {:ok, {_address, port}} = ThousandIsland.listener_info(pid)

      # Verify pacts against the mock provider
      verifier =
        verifier_new_for_application("tests", "1.0.0")
        |> verifier_set_provider_info("Provider", "http", "localhost", port)
        |> verifier_add_provider_transport("message", port, "/message")
        |> verifier_add_directory_source("test/pacts")

      refute verifier_execute(verifier)

      assert verifier_output(verifier, 1) =~
               """
               1) Verifying a pact between Consumer and Provider Given a user named John - a request
                   1.1) has a matching body
                          $ -> Actual map is missing the following keys: name
                   {
                   -  \"name\": \"John\"
                   +  \"error\": \"Unauthorized\"
                   }

                   1.2) has status code 200
                          expected 200 but was 401
               """

      verifier_shutdown(verifier)
    end

    test "failure when provider is not running" do
      # Verify pacts against the mock provider
      verifier =
        verifier_new_for_application("tests", "1.0.0")
        |> verifier_set_provider_info("Provider", "http", "localhost", 9999)
        |> verifier_add_provider_transport("message", 9999, "/message")
        |> verifier_add_directory_source("test/pacts")

      refute verifier_execute(verifier)

      assert %{
               "errors" => [
                 %{
                   "interaction" =>
                     "Verifying a pact between Consumer and Provider Given a user named John - a payload containing info about the user",
                   "mismatch" => %{
                     "message" => "error sending request for url (http://localhost:9999/message)",
                     "type" => "error"
                   }
                 },
                 %{
                   "interaction" =>
                     "Verifying a pact between Consumer and Provider Given a user named John - a request",
                   "mismatch" => %{
                     "message" =>
                       "error sending request for url (http://localhost:9999/?name=John)",
                     "type" => "error"
                   }
                 }
               ],
               "notices" => [],
               "pendingErrors" => [],
               "result" => false
             } = Jason.decode!(verifier_json(verifier))

      verifier_shutdown(verifier)
    end
  end
end
