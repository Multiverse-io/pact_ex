# PactEx

Elixir implementation of Consumer + Verifier for [Pact](https://docs.pact.io/)

## How to use

### Consumer test example

```elixir
defmodule Sample.AppTest do
  import PactEx
  import PactEx.Matchers
  use ExUnit.Case

  test "http request consumer" do
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

    # Invoke your function that would send a HTTP request.
    # You'll need to modify your HTTP client to point to "http://localhost:#{port}"
    Sample.App.call_endpoint()

    # Assert there were no mismatches
    assert "[]" = mock_server_mismatches(port)

    # Write the pact file, and cleanup the mock server.
    assert write_pact_file(port, "test/pacts", false)
    assert cleanup_mock_server(port)

    # Optionally, publish your pact to a broker
    assert {:ok, %{status: 200}} =
            PactEx.BrokerClient.client("http://localhost:9292")
              |> PactEx.BrokerClient.publish_contracts("Consumer", [{"Provider", pact}])
  end
end
```

Messages are also supported, see [Consumer Tests](test/consumer_test.exs) for an example.

### Provider test example

```elixir
defmodule Sample.PactVerifier do
  import PactEx
  use ExUnit.Case

  test "verify pacts" do
    # The port that your application is listening on
    port = 4000
    application_name = "Provider"

    # Utility functions that call out to git to get your current commit hash/branch
    version = PactEx.Git.get_hash!()
    branch = PactEx.Git.get_branch!()

    # Fetch the build URL from CI env if available
    build_url = System.get_env("CIRCLE_BUILD_URL", "")

    verifier =
      verifier_new_for_application(application_name, version)
      |> verifier_set_provider_info(application_name, "http", "localhost", port)
      |> verifier_set_publish_options(version, build_url, [], branch)
      |> verifier_add_provider_transport("message", port, "/message")
      |> verifier_add_custom_header("Authorization", "Bearer 123")
      |> verifier_broker_source("http://localhost:9292", "", "", "")

    assert verifier_execute(verifier), "Verification failed"

    verifier_shutdown(verifier)
  end
end
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `pact_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pact_ex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/pact_ex>.
