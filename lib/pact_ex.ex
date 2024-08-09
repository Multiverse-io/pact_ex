defmodule PactEx do
  @moduledoc """
  A module for interacting with the FFI bindings for Pact.
  See https://docs.rs/pact_ffi/0.4.22/pact_ffi/ for more information.

  See [`PactEx.ConsumerTest`] and [`PactEx.ProviderTest`] for examples.
  """

  version = Mix.Project.config()[:version]

  use RustlerPrecompiled,
    otp_app: :pact_ex,
    crate: "pact_ex",
    base_url: "https://github.com/Multiverse-io/pact_ex/releases/download/v#{version}",
    version: version,
    mode: System.get_env("RUSTLER_PACT_EX_MODE", "release") |> String.to_existing_atom(),
    force_build:
      System.get_env("RUSTLER_PRECOMPILATION_PACT_EX_BUILD") in ["1", "true"] ||
        System.get_env("MIX_ENV") == "test",
    targets: [
      "aarch64-apple-darwin",
      "aarch64-unknown-linux-musl",
      "x86_64-unknown-linux-musl"
    ]

  @type pact :: reference()
  @type interaction :: reference()
  @type verifier :: reference()

  @type part :: :request | :response

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/handles/fn.pactffi_new_pact.html"
  @spec new_pact(String.t(), String.t()) :: pact()
  def new_pact(_consumer, _provider), do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/handles/fn.pactffi_with_specification.html"
  @spec with_specification(pact(), String.t()) :: pact()
  def with_specification(_pact, _version), do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/handles/fn.pactffi_new_interaction.html"
  @spec new_interaction(reference(), String.t()) :: interaction()
  def new_interaction(_pact_, _description), do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/handles/fn.pactffi_given.html"
  @spec given(interaction(), String.t()) :: interaction()
  def given(_interaction, _description), do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/handles/fn.pactffi_given_with_params.html"
  @spec given_with_params(interaction(), String.t(), String.t()) :: interaction()
  def given_with_params(_interaction, _description, _params),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/handles/fn.pactffi_upon_receiving.html"
  @spec upon_receiving(interaction(), String.t()) :: interaction()
  def upon_receiving(_interaction, _description), do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/handles/fn.pactffi_with_request.html"
  @spec with_request(interaction(), String.t(), String.t()) :: interaction()
  def with_request(_interaction, _method, _path_matcher), do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/handles/fn.pactffi_with_header.html"
  @spec with_header(interaction(), part(), String.t(), String.t()) :: interaction()
  @spec with_header(interaction(), part(), String.t(), integer(), String.t()) :: interaction()
  def with_header(_interaction, _part, _name, _index \\ 0, _value),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/handles/fn.pactffi_with_query_parameter.html"
  @spec with_query_parameter(interaction(), String.t(), String.t()) :: interaction()
  @spec with_query_parameter(interaction(), String.t(), integer(), String.t()) ::
          interaction()
  def with_query_parameter(_interaction, _name, _index \\ 0, _value),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/handles/fn.pactffi_with_body.html"
  @spec with_body(interaction(), part(), String.t(), String.t()) :: interaction()
  def with_body(_interaction, _part, _content_type, _body), do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/handles/fn.pactffi_response_status.html"
  @spec response_status(interaction(), integer()) :: interaction()
  def response_status(_interaction, _status), do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/handles/fn.pactffi_new_message_pact.html"
  @spec new_message_pact(String.t(), String.t()) :: pact()
  def new_message_pact(_consumer, _provider), do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/handles/fn.pactffi_new_message.html"
  @spec new_message(pact(), String.t()) :: interaction()
  def new_message(_pact, _description), do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/handles/fn.pactffi_message_given.html"
  @spec message_given(interaction(), String.t()) :: interaction()
  def message_given(_message, _description), do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/handles/fn.pactffi_message_given_with_param.html"
  @spec message_given_with_param(interaction(), String.t(), String.t(), String.t()) ::
          interaction()
  def message_given_with_param(_message, _description, _name_, _value),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/handles/fn.pactffi_message_expects_to_receive.html"
  @spec message_expects_to_receive(interaction(), String.t()) :: interaction()
  def message_expects_to_receive(_message, _description), do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/handles/fn.pactffi_message_with_contents.html"
  @spec message_with_contents(interaction(), String.t(), String.t()) :: interaction()
  @spec message_with_contents(interaction(), String.t(), String.t(), integer()) :: interaction()
  def message_with_contents(_message, _content_type, _body, _size \\ 0),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/handles/fn.pactffi_with_metadata.html"
  @spec message_with_metadata(interaction(), String.t(), String.t()) :: interaction()
  @spec message_with_metadata(interaction(), String.t(), String.t(), part()) :: interaction()
  def message_with_metadata(_message, _key, _value, _part \\ :request),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/handles/fn.pactffi_message_reify.html"
  @spec message_reify(interaction()) :: String.t()
  def message_reify(_message), do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/handles/fn.pactffi_write_message_pact_file.html"
  @spec write_message_pact_file(pact(), String.t()) :: integer()
  @spec write_message_pact_file(pact(), String.t(), boolean()) :: integer()
  def write_message_pact_file(_pact, _directory, _overwrite \\ true),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/fn.pactffi_create_mock_server_for_transport.html"
  @spec create_mock_server_for_transport(reference(), String.t()) :: integer()
  @spec create_mock_server_for_transport(reference(), String.t(), integer()) :: integer()
  @spec create_mock_server_for_transport(reference(), String.t(), integer(), String.t()) ::
          integer()
  @spec create_mock_server_for_transport(
          reference(),
          String.t(),
          integer(),
          String.t(),
          String.t()
        ) :: integer()
  def create_mock_server_for_transport(
        _pact,
        _addr \\ "127.0.0.1",
        _port \\ 0,
        _transport \\ "http",
        _transport_config \\ ""
      ),
      do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/fn.pactffi_mock_server_mismatches.html"
  @spec mock_server_mismatches(integer()) :: String.t()
  def mock_server_mismatches(_port), do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/fn.pactffi_write_pact_file.html"
  @spec write_pact_file(integer(), String.t()) :: boolean()
  @spec write_pact_file(integer(), String.t(), boolean()) :: boolean()
  def write_pact_file(_port, _file_path, _overwrite \\ true),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/mock_server/fn.pactffi_cleanup_mock_server.html"
  @spec cleanup_mock_server(integer()) :: boolean()
  def cleanup_mock_server(_port), do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/verifier/fn.pactffi_verifier_new_for_application.html"
  @spec verifier_new_for_application(String.t(), String.t()) :: verifier()
  def verifier_new_for_application(_name, _version), do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/verifier/fn.pactffi_verifier_set_publish_options.html"
  @spec verifier_set_publish_options(
          verifier(),
          String.t(),
          String.t(),
          [String.t()],
          String.t()
        ) :: verifier()
  def verifier_set_publish_options(
        _verifier,
        _provider_version,
        _build_url,
        _provider_tags,
        _provider_branch
      ),
      do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/verifier/fn.pactffi_verifier_broker_source.html"
  @spec verifier_broker_source(verifier(), String.t(), String.t(), String.t(), String.t()) ::
          verifier()
  def verifier_broker_source(_verifier, _url, _username, _password, _token),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/verifier/fn.pactffi_verifier_set_provider_info.html"
  @spec verifier_set_provider_info(
          verifier(),
          String.t(),
          String.t(),
          String.t(),
          integer()
        ) :: verifier()
  @spec verifier_set_provider_info(
          verifier(),
          String.t(),
          String.t(),
          String.t(),
          integer(),
          String.t()
        ) :: verifier()
  def verifier_set_provider_info(_verifier, _name, _scheme, _host, _port, _path \\ ""),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/verifier/fn.pactffi_verifier_set_provider_state.html"
  @spec verifier_set_provider_state(verifier(), String.t(), boolean(), boolean()) :: verifier()
  def verifier_set_provider_state(_verifier, _url, _teardown, _body),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/verifier/fn.pactffi_verifier_add_provider_transport.html"
  @spec verifier_add_provider_transport(verifier(), String.t(), integer(), String.t()) ::
          verifier()
  @spec verifier_add_provider_transport(verifier(), String.t(), integer(), String.t(), String.t()) ::
          verifier()
  def verifier_add_provider_transport(_verifier, _protocol, _port, _path, _scheme \\ ""),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/verifier/fn.pactffi_verifier_add_directory_source.html"
  @spec verifier_add_directory_source(verifier(), String.t()) :: verifier()
  def verifier_add_directory_source(_verifier, _directory), do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/verifier/fn.pactffi_verifier_add_custom_header.html"
  @spec verifier_add_custom_header(verifier(), String.t(), String.t()) :: verifier()
  def verifier_add_custom_header(_verifier, _name, _value), do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/verifier/fn.pactffi_verifier_execute.html"
  @spec verifier_execute(verifier()) :: boolean()
  def verifier_execute(_verifier), do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/verifier/fn.pactffi_verifier_output.html"
  @spec verifier_output(verifier()) :: String.t()
  @spec verifier_output(verifier(), integer()) :: String.t()
  def verifier_output(_verifier, _strip_ansi \\ 0), do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/verifier/fn.pactffi_verifier_json.html"
  @spec verifier_json(verifier()) :: String.t()
  def verifier_json(_verifier), do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/verifier/fn.pactffi_verifier_shutdown.html"
  @spec verifier_shutdown(verifier()) :: term()
  def verifier_shutdown(_verifier), do: :erlang.nif_error(:nif_not_loaded)

  @doc "See https://docs.rs/pact_ffi/0.4.22/pact_ffi/fn.pactffi_init_with_log_level.html"
  @spec init_with_log_level(String.t()) :: term()
  def init_with_log_level(_log_level), do: :erlang.nif_error(:nif_not_loaded)
end
