use core::panic;
use rustler::{Atom, Resource, ResourceArc};
use std::ffi::{CStr, CString};
use std::sync::atomic::{AtomicPtr, Ordering};

use pact_ffi::{
    mock_server::{
        handles::{
            pactffi_given, pactffi_given_with_params, pactffi_message_expects_to_receive,
            pactffi_message_given, pactffi_message_given_with_param, pactffi_message_reify,
            pactffi_message_with_contents, pactffi_new_interaction, pactffi_new_message,
            pactffi_new_message_pact, pactffi_new_pact, pactffi_response_status_v2,
            pactffi_upon_receiving, pactffi_with_body, pactffi_with_header_v2,
            pactffi_with_metadata, pactffi_with_query_parameter_v2, pactffi_with_request,
            pactffi_with_specification, pactffi_write_message_pact_file, InteractionHandle,
            InteractionPart, MessageHandle, MessagePactHandle, PactHandle,
        },
        pactffi_cleanup_mock_server, pactffi_create_mock_server_for_transport,
        pactffi_mock_server_mismatches, pactffi_write_pact_file,
    },
    pactffi_init_with_log_level,
    verifier::{
        handle::VerifierHandle, pactffi_verifier_add_custom_header,
        pactffi_verifier_add_directory_source, pactffi_verifier_add_provider_transport,
        pactffi_verifier_broker_source, pactffi_verifier_execute,
        pactffi_verifier_new_for_application, pactffi_verifier_output,
        pactffi_verifier_set_provider_info, pactffi_verifier_set_provider_state,
        pactffi_verifier_set_publish_options, pactffi_verifier_shutdown,
    },
};

mod atoms {
    rustler::atoms! {
        request,
        response
    }
}

struct PactResource(PactHandle);
#[rustler::resource_impl]
impl Resource for PactResource {}

struct MessagePactResource(MessagePactHandle);
#[rustler::resource_impl]
impl Resource for MessagePactResource {}

struct InteractionResource(InteractionHandle);
#[rustler::resource_impl]
impl Resource for InteractionResource {}

struct MessageResource(MessageHandle);
#[rustler::resource_impl]
impl Resource for MessageResource {}

struct VerifierResource(AtomicPtr<VerifierHandle>);
#[rustler::resource_impl]
impl Resource for VerifierResource {}

#[rustler::nif]
fn new_pact(consumer: String, provider: String) -> ResourceArc<PactResource> {
    let consumer_name = CString::new(consumer).expect("invalid consumer");
    let provider_name = CString::new(provider).expect("invalid provider");
    let handle = pactffi_new_pact(consumer_name.as_ptr(), provider_name.as_ptr());
    ResourceArc::new(PactResource(handle))
}

#[rustler::nif]
fn with_specification(
    pact: ResourceArc<PactResource>,
    version: String,
) -> ResourceArc<PactResource> {
    let specification =
        pact_models::PactSpecification::parse_version(&version).expect("invalid version");
    pactffi_with_specification(pact.0, specification)
        .then(|| pact)
        .expect("pact cannot be modified")
}

#[rustler::nif]
fn new_interaction(
    pact: ResourceArc<PactResource>,
    description: String,
) -> ResourceArc<InteractionResource> {
    let description = CString::new(description).expect("invalid description");
    let interaction = pactffi_new_interaction(pact.0, description.as_ptr());
    ResourceArc::new(InteractionResource(interaction))
}

#[rustler::nif]
fn given(
    interaction: ResourceArc<InteractionResource>,
    description: String,
) -> ResourceArc<InteractionResource> {
    let description = CString::new(description).expect("invalid description");
    pactffi_given(interaction.0, description.as_ptr())
        .then(|| interaction)
        .expect("pact or interaction cannot be modified")
}

#[rustler::nif]
fn given_with_params(
    interaction: ResourceArc<InteractionResource>,
    description: String,
    params: String,
) -> ResourceArc<InteractionResource> {
    let description = CString::new(description).expect("invalid description");
    let params = CString::new(params).expect("invalid params");
    match pactffi_given_with_params(interaction.0, description.as_ptr(), params.as_ptr()) {
        0 => interaction,
        1 => panic!("pact or interaction cannot be modified"),
        2 => panic!("invalid params"),
        _ => panic!("invalid description or params"),
    }
}

#[rustler::nif]
fn upon_receiving(
    interaction: ResourceArc<InteractionResource>,
    description: String,
) -> ResourceArc<InteractionResource> {
    let description = CString::new(description).expect("invalid description");
    pactffi_upon_receiving(interaction.0, description.as_ptr())
        .then(|| interaction)
        .expect("pact or interaction cannot be modified")
}

#[rustler::nif]
fn with_request(
    interaction: ResourceArc<InteractionResource>,
    method: String,
    path_matcher: String,
) -> ResourceArc<InteractionResource> {
    let method = CString::new(method).expect("invalid method");
    let path_matcher = CString::new(path_matcher).expect("invalid path matcher");
    pactffi_with_request(interaction.0, method.as_ptr(), path_matcher.as_ptr())
        .then(|| interaction)
        .expect("pact or interaction cannot be modified")
}

#[rustler::nif]
fn with_header(
    interaction: ResourceArc<InteractionResource>,
    part: Atom,
    name: String,
    index: usize,
    value: String,
) -> ResourceArc<InteractionResource> {
    let part = match part {
        req if req == atoms::request() => InteractionPart::Request,
        res if res == atoms::response() => InteractionPart::Response,
        _ => panic!("invalid part"),
    };
    let name = CString::new(name).expect("invalid key");
    let value = CString::new(value).expect("invalid value");
    pactffi_with_header_v2(interaction.0, part, name.as_ptr(), index, value.as_ptr())
        .then(|| interaction)
        .expect("pact or interaction cannot be modified")
}

#[rustler::nif]
fn with_query_parameter(
    interaction: ResourceArc<InteractionResource>,
    name: String,
    index: usize,
    value: String,
) -> ResourceArc<InteractionResource> {
    let name = CString::new(name).expect("invalid key");
    let value = CString::new(value).expect("invalid value");
    pactffi_with_query_parameter_v2(interaction.0, name.as_ptr(), index, value.as_ptr())
        .then(|| interaction)
        .expect("pact or interaction cannot be modified")
}

#[rustler::nif]
fn with_body(
    interaction: ResourceArc<InteractionResource>,
    part: Atom,
    content_type: String,
    body: String,
) -> ResourceArc<InteractionResource> {
    let part = match part {
        req if req == atoms::request() => InteractionPart::Request,
        res if res == atoms::response() => InteractionPart::Response,
        _ => panic!("invalid part"),
    };
    let content_type = CString::new(content_type).expect("invalid content type");
    let body = CString::new(body).expect("invalid body");
    pactffi_with_body(interaction.0, part, content_type.as_ptr(), body.as_ptr())
        .then(|| interaction)
        .expect("pact or interaction cannot be modified")
}

#[rustler::nif]
fn response_status(
    interaction: ResourceArc<InteractionResource>,
    status: String,
) -> ResourceArc<InteractionResource> {
    let status = CString::new(status).expect("invalid status");
    pactffi_response_status_v2(interaction.0, status.as_ptr())
        .then(|| interaction)
        .expect("pact or interaction cannot be modified")
}

#[rustler::nif]
fn create_mock_server_for_transport(
    pact: ResourceArc<PactResource>,
    addr: String,
    port: u16,
    transport: String,
    transport_config: String,
) -> i32 {
    let addr = CString::new(addr).expect("invalid address");
    let transport = CString::new(transport).expect("invalid transport");
    let transport_config = CString::new(transport_config).expect("invalid transport config");
    pactffi_create_mock_server_for_transport(
        pact.0,
        addr.as_ptr(),
        port,
        transport.as_ptr(),
        transport_config.as_ptr(),
    )
}

#[rustler::nif]
fn new_message_pact(consumer: String, provider: String) -> ResourceArc<MessagePactResource> {
    let consumer = CString::new(consumer).expect("invalid consumer");
    let provider = CString::new(provider).expect("invalid provider");
    let pact = pactffi_new_message_pact(consumer.as_ptr(), provider.as_ptr());
    ResourceArc::new(MessagePactResource(pact))
}
#[rustler::nif]
fn new_message(
    pact: ResourceArc<MessagePactResource>,
    description: String,
) -> ResourceArc<MessageResource> {
    let description = CString::new(description).expect("invalid description");
    let message = pactffi_new_message(pact.0, description.as_ptr());
    ResourceArc::new(MessageResource(message))
}

#[rustler::nif]
fn message_given(
    message: ResourceArc<MessageResource>,
    description: String,
) -> ResourceArc<MessageResource> {
    let description = CString::new(description).expect("invalid description");
    pactffi_message_given(message.0, description.as_ptr());
    message
}

#[rustler::nif]
fn message_given_with_param(
    message: ResourceArc<MessageResource>,
    description: String,
    name: String,
    value: String,
) -> ResourceArc<MessageResource> {
    let description = CString::new(description).expect("invalid description");
    let name = CString::new(name).expect("invalid name");
    let value = CString::new(value).expect("invalid value");
    pactffi_message_given_with_param(
        message.0,
        description.as_ptr(),
        name.as_ptr(),
        value.as_ptr(),
    );
    message
}

#[rustler::nif]
fn message_expects_to_receive(
    message: ResourceArc<MessageResource>,
    description: String,
) -> ResourceArc<MessageResource> {
    let description = CString::new(description).expect("invalid description");
    pactffi_message_expects_to_receive(message.0, description.as_ptr());
    message
}

#[rustler::nif]
fn message_with_contents(
    message: ResourceArc<MessageResource>,
    content_type: String,
    body: String,
    size: usize,
) -> ResourceArc<MessageResource> {
    let content_type = CString::new(content_type).expect("invalid content type");
    let body = CString::new(body).expect("invalid body");
    pactffi_message_with_contents(
        message.0,
        content_type.as_ptr(),
        body.as_bytes().as_ptr(),
        size,
    );
    message
}

#[rustler::nif]
fn message_with_metadata(
    message: ResourceArc<MessageResource>,
    key: String,
    value: String,
    part: Atom,
) -> ResourceArc<MessageResource> {
    let key = CString::new(key).expect("invalid key");
    let value = CString::new(value).expect("invalid value");
    let part = match part {
        req if req == atoms::request() => InteractionPart::Request,
        res if res == atoms::response() => InteractionPart::Response,
        _ => panic!("invalid part"),
    };

    let interaction = unsafe { std::mem::transmute::<MessageHandle, InteractionHandle>(message.0) };
    pactffi_with_metadata(interaction, key.as_ptr(), value.as_ptr(), part)
        .then(|| message)
        .expect("failed to add metadata")
}

#[rustler::nif]
fn message_reify(message: ResourceArc<MessageResource>) -> String {
    let ptr = pactffi_message_reify(message.0);
    unsafe { CStr::from_ptr(ptr) }
        .to_string_lossy()
        .into_owned()
}

#[rustler::nif]
fn write_message_pact_file(
    pact: ResourceArc<MessagePactResource>,
    directory: String,
    overwrite: bool,
) -> i32 {
    let directory = CString::new(directory).expect("invalid directory");
    pactffi_write_message_pact_file(pact.0, directory.as_ptr(), overwrite)
}

#[rustler::nif]
fn mock_server_mismatches(port: i32) -> String {
    let mismatches = pactffi_mock_server_mismatches(port);
    unsafe { CStr::from_ptr(mismatches) }
        .to_string_lossy()
        .into_owned()
}

#[rustler::nif]
fn write_pact_file(port: i32, file_path: String, overwrite: bool) -> i32 {
    let file_path = CString::new(file_path).expect("invalid file path");
    pactffi_write_pact_file(port, file_path.as_ptr(), overwrite)
}

#[rustler::nif]
fn cleanup_mock_server(port: i32) -> bool {
    pactffi_cleanup_mock_server(port)
}

#[rustler::nif]
fn verifier_new_for_application(name: String, version: String) -> ResourceArc<VerifierResource> {
    let name = CString::new(name).expect("invalid name");
    let version = CString::new(version).expect("invalid version");
    let verifier = pactffi_verifier_new_for_application(name.as_ptr(), version.as_ptr());
    ResourceArc::new(VerifierResource(AtomicPtr::new(verifier)))
}

#[rustler::nif]
fn verifier_set_publish_options(
    verifier: ResourceArc<VerifierResource>,
    provider_version: String,
    build_url: String,
    provider_tags: Vec<String>,
    provider_branch: String,
) -> ResourceArc<VerifierResource> {
    let provider_version = CString::new(provider_version).expect("invalid provider version");
    let build_url = CString::new(build_url).expect("invalid build url");
    let provider_tags = provider_tags
        .into_iter()
        .map(|tag| CString::new(tag).expect("invalid tag"))
        .collect::<Vec<_>>();

    let provider_tag_ptrs = provider_tags
        .iter()
        .map(|tag| tag.as_ptr())
        .collect::<Vec<_>>();

    let provider_branch = CString::new(provider_branch).expect("invalid provider branch");
    let result = pactffi_verifier_set_publish_options(
        verifier.0.load(Ordering::SeqCst),
        provider_version.as_ptr(),
        build_url.as_ptr(),
        provider_tag_ptrs.as_ptr(),
        provider_tags.len() as u16,
        provider_branch.as_ptr(),
    );

    match result {
        0 => verifier,
        _ => panic!("failed to set publish options"),
    }
}

#[rustler::nif]
fn verifier_broker_source(
    verifier: ResourceArc<VerifierResource>,
    url: String,
    username: String,
    password: String,
    token: String,
) -> ResourceArc<VerifierResource> {
    let url = CString::new(url).expect("invalid url");
    let username = CString::new(username).expect("invalid username");
    let password = CString::new(password).expect("invalid password");
    let token = CString::new(token).expect("invalid token");
    pactffi_verifier_broker_source(
        verifier.0.load(Ordering::SeqCst),
        url.as_ptr(),
        username.as_ptr(),
        password.as_ptr(),
        token.as_ptr(),
    );
    verifier
}

#[rustler::nif]
fn verifier_set_provider_info(
    verifier: ResourceArc<VerifierResource>,
    name: String,
    scheme: String,
    host: String,
    port: u16,
    path: String,
) -> ResourceArc<VerifierResource> {
    let name = CString::new(name).expect("invalid name");
    let scheme = CString::new(scheme).expect("invalid scheme");
    let host = CString::new(host).expect("invalid host");
    let path = CString::new(path).expect("invalid path");
    pactffi_verifier_set_provider_info(
        verifier.0.load(Ordering::SeqCst),
        name.as_ptr(),
        scheme.as_ptr(),
        host.as_ptr(),
        port,
        path.as_ptr(),
    );
    verifier
}

#[rustler::nif]
fn verifier_set_provider_state(
    verifier: ResourceArc<VerifierResource>,
    url: String,
    teardown: bool,
    body: bool,
) -> ResourceArc<VerifierResource> {
    let url = CString::new(url).expect("invalid url");
    pactffi_verifier_set_provider_state(
        verifier.0.load(Ordering::SeqCst),
        url.as_ptr(),
        if teardown { 1 } else { 0 },
        if body { 1 } else { 0 },
    );
    verifier
}

#[rustler::nif]
fn verifier_add_provider_transport(
    verifier: ResourceArc<VerifierResource>,
    protocol: String,
    port: u16,
    path: String,
    scheme: String,
) -> ResourceArc<VerifierResource> {
    let protocol = CString::new(protocol).expect("invalid protocol");
    let path = CString::new(path).expect("invalid path");
    let scheme = CString::new(scheme).expect("invalid scheme");
    pactffi_verifier_add_provider_transport(
        verifier.0.load(Ordering::SeqCst),
        protocol.as_ptr(),
        port,
        path.as_ptr(),
        scheme.as_ptr(),
    );
    verifier
}

#[rustler::nif]
fn verifier_add_directory_source(
    verifier: ResourceArc<VerifierResource>,
    directory: String,
) -> ResourceArc<VerifierResource> {
    let directory = CString::new(directory).expect("invalid directory");
    pactffi_verifier_add_directory_source(verifier.0.load(Ordering::SeqCst), directory.as_ptr());
    verifier
}

#[rustler::nif]
fn verifier_add_custom_header(
    verifier: ResourceArc<VerifierResource>,
    name: String,
    value: String,
) -> ResourceArc<VerifierResource> {
    let name = CString::new(name).expect("invalid name");
    let value = CString::new(value).expect("invalid value");
    pactffi_verifier_add_custom_header(
        verifier.0.load(Ordering::SeqCst),
        name.as_ptr(),
        value.as_ptr(),
    );
    verifier
}

// The schedule argument must be set as this function can take some time
// We also need to spawn a new thread as usage of task_local seems to cause issues
// when called on the same thread
#[rustler::nif(schedule = "DirtyCpu")]
fn verifier_execute(verifier: ResourceArc<VerifierResource>) -> bool {
    std::thread::spawn(move || pactffi_verifier_execute(verifier.0.load(Ordering::SeqCst)) == 0)
        .join()
        .expect("verifier thread failed to complete")
}

#[rustler::nif]
fn verifier_output(verifier: ResourceArc<VerifierResource>, strip_ansi: u8) -> String {
    let output = pactffi_verifier_output(verifier.0.load(Ordering::SeqCst), strip_ansi);
    unsafe { CStr::from_ptr(output) }
        .to_string_lossy()
        .into_owned()
}

#[rustler::nif]
fn verifier_shutdown(verifier: ResourceArc<VerifierResource>) {
    pactffi_verifier_shutdown(verifier.0.load(Ordering::SeqCst));
}

#[rustler::nif]
fn init_with_log_level(level: String) {
    let level = CString::new(level).expect("invalid log level");
    unsafe { pactffi_init_with_log_level(level.as_ptr()) }
}

rustler::init!("Elixir.PactEx", load = load);

fn load(_env: rustler::Env, _info: rustler::Term) -> bool {
    std::env::set_var("PACT_DO_NOT_TRACK", "true");

    true
}
