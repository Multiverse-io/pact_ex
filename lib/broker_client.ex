defmodule PactEx.BrokerClient do
  @moduledoc """
  Client for interacting with the Pact Broker.
  """
  use Tesla

  def client(base_url) do
    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      {Tesla.Middleware.JSON, decode_content_types: ["application/hal+json"]}
    ]

    Tesla.client(middleware)
  end

  @type contract :: {provider_name :: String.t(), pact :: String.t()}

  @doc """
  Publish contracts to the Pact Broker.
  This function expects the `git` executable to be available in order
  to determine the current git commit hash and branch.
  """
  @spec publish_contracts(Tesla.Client.t(), String.t(), [contract]) :: Tesla.Env.result()
  def publish_contracts(client, consumer_name, contracts) do
    hash = PactEx.Git.get_hash!()
    branch = PactEx.Git.get_branch!()

    post(
      client,
      "/contracts/publish",
      %{
        "pacticipantName" => consumer_name,
        "pacticipantVersionNumber" => hash,
        "branch" => branch,
        "contracts" =>
          Enum.map(
            contracts,
            fn {provider_name, pact} ->
              %{
                "consumerName" => consumer_name,
                "providerName" => provider_name,
                "specification" => "pact",
                "contentType" => "application/json",
                "content" => Base.encode64(pact)
              }
            end
          )
      }
    )
    |> case do
      {:ok, %{status: 200, body: %{"notices" => notices}}} = res ->
        for %{"type" => type, "text" => text} <- notices do
          IO.puts(String.pad_trailing(type <> ":", 10) <> text)
        end

        res

      other ->
        other
    end
  end
end
