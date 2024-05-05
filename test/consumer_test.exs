defmodule PactEx.ConsumerTest do
  import PactEx
  import PactEx.Matchers
  use ExUnit.Case

  describe "http consumer" do
    test "http request consumer (success)" do
      # Create a pact between a consumer and a provider
      pact = new_pact("Consumer", "Provider") |> with_specification("4")

      # Create a new interaction
      new_interaction(pact, "a request")
      |> given("a user named John")
      |> upon_receiving("a request")
      |> with_request("GET", "/")
      |> with_header(:request, "Accept", "application/json")
      |> with_query_parameter("name", like("John") |> Jason.encode!())
      |> with_header(:response, "Content-Type", "application/json")
      |> with_body(:response, "application/json", %{name: like("John")} |> Jason.encode!())
      |> response_status("200")

      # Start a mock server on an unused port
      port = create_mock_server_for_transport(pact)

      # Send a request to the mock server. In real tests, this would be
      # your actual code sending the request.
      assert {:ok, %{body: ~s({"name":"John"})}} =
               Tesla.get("http://localhost:#{port}/?name=John",
                 headers: [{"Accept", "application/json"}]
               )

      # Assert there were no mismatches
      assert "[]" = mock_server_mismatches(port)

      # Write the pact file, and cleanup the mock server
      assert write_pact_file(port, "test/pacts", false)
      assert cleanup_mock_server(port)
    end

    test "http request consumer (no request sent)" do
      # Create a pact between a consumer and a provider
      pact = new_pact("Consumer", "Provider") |> with_specification("4")

      # Create a new interaction
      new_interaction(pact, "a request")
      |> given("a user named John")
      |> upon_receiving("a request")
      |> with_request("GET", "/")
      |> with_header(:request, "Content-Type", "application/json")
      |> with_query_parameter("name", "John")
      |> with_header(:response, "Content-Type", "application/json")
      |> with_body(:response, "application/json", ~s({"name":"John"}))
      |> response_status("200")

      # Start a mock server on an unused port
      port = create_mock_server_for_transport(pact)

      # Don't send a request to the mock server

      # Assert there was a mismatch
      assert [
               %{
                 "method" => "GET",
                 "path" => "/",
                 "type" => "missing-request",
                 "request" => %{
                   "headers" => %{
                     "Content-Type" => "application/json"
                   },
                   "method" => "GET",
                   "path" => "/",
                   "query" => %{
                     "name" => [
                       "John"
                     ]
                   }
                 }
               }
             ] =
               mock_server_mismatches(port) |> Jason.decode!()

      # cleanup the mock server
      assert cleanup_mock_server(port)
    end
  end

  describe "message consumer" do
    test "async message consumer (success)" do
      # Create a pact between a consumer and a provider
      pact = new_message_pact("Consumer", "Provider")

      # Create a new message interaction
      message =
        new_message(pact, "a user added event")
        |> message_given("a user named John")
        |> message_expects_to_receive("a payload containing info about the user")
        |> message_with_contents("application/json", %{name: like("John")} |> Jason.encode!())
        |> message_with_metadata("routing_key", "user.added")

      # Get the reified contents from the message
      assert %{"contents" => %{"name" => "John"}} = message_reify(message) |> Jason.decode!()

      # In a real test, you would process the message through your consumer here

      # Write the pact file
      assert write_message_pact_file(pact, "test/pacts", false)
    end
  end
end
