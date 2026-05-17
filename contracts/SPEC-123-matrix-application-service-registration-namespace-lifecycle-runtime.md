# SPEC-123: Matrix Application Service Registration Namespace Lifecycle Runtime

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Define the focused Application Service registration lifecycle, exclusive
namespace enforcement, and secret-redaction runtime boundary promoted from the
`SPEC-075` `registration-namespace-token-lifecycle-breadth` lane.

`SPEC-105` established parser-only artifact coverage for the same lane. This
contract adds representative runtime behavior: the server must load and validate
multiple registration files, enforce exclusive namespace exclusivity, validate
tokens on inbound requests, enforce the sender localpart boundary, and redact
tokens from logs and artifacts.

This contract lets implementation repositories adopt registration runtime
validation without claiming rate-limited throttle enforcement, ephemeral event
batching, third-party network protocol metadata, or a widened Application
Service API advertisement.

## Scope

This contract covers representative runtime behavior for:

- multiple application service registration loading from configuration and
  unique `id` + `as_token` enforcement;
- exclusive namespace conflict detection across users, aliases, and rooms;
- `hs_token` and `as_token` validation on inbound homeserver-to-appservice
  and appservice-to-homeserver requests;
- `sender_localpart` boundary enforcement — the appservice-reserved localpart
  must not be usable as a regular user account;
- token redaction in logs and release artifacts;
- malformed registration file rejection when required fields are missing;
- restart reload: registrations must be re-read from file on server restart,
  not reconstructed from runtime state.

This contract does not define `rate_limited` throttle enforcement, ephemeral
event batching driven by `receive_ephemeral` (that is `SPEC-115`), third-party
network `protocols` metadata (that is `SPEC-117`), or token rotation at runtime.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/application-service-api/#registration>
- Source: <https://spec.matrix.org/v1.18/application-service-api/#namespaces>
- Source: <https://spec.matrix.org/v1.18/application-service-api/#homeserver---application-service-authorization>
- Source: <https://spec.matrix.org/v1.18/application-service-api/#application-service---homeserver-authorization>
- Parent contract: `SPEC-058`
- Parser artifact contract: `SPEC-105`
- Gap inventory: `SPEC-075`
- Checked at: 2026-05-17T12:00:00+09:00
- Timezone: Asia/Tokyo

## Runtime Behavior

### Multiple Registration Loading

Servers adopting this contract MUST load all configured application service
registration files on startup and validate:

- every registration has a non-empty `id` field;
- every registration has a non-empty `as_token` field;
- every `id` is unique across all loaded registrations;
- every `as_token` is unique across all loaded registrations.

If any registration is missing a required field or has a duplicate `id` or
`as_token`, the server MUST reject the entire registration set and fail to
start. It must not accept a partial registration set.

### Exclusive Namespace Conflict Detection

For each exclusive namespace entry across `users`, `aliases`, and `rooms`, the
server MUST:

- validate the namespace `regex` compiles as a valid regular expression;
- detect conflicts where two different appservices claim `exclusive: true`
  namespaces whose regexes overlap;
- reject any registration set where exclusive namespace overlap exists.

Conflict detection must cover cross-appservice overlap within the same namespace
type (users vs. users, aliases vs. aliases, rooms vs. rooms). Cross-type overlap
(users vs. aliases) is out of scope.

### Token Validation

Inbound requests from the homeserver to the appservice MUST carry a valid
`hs_token` via the `access_token` query parameter or `Authorization` header.
Requests without a valid `hs_token` must be rejected with HTTP `401`.

Inbound requests from the appservice to the homeserver MUST carry a valid
`as_token` via the `Authorization: Bearer` header. Requests without a valid
`as_token` must be rejected with HTTP `401 M_UNKNOWN_TOKEN`.

### Sender Localpart Boundary

The `sender_localpart` field reserves a Matrix user localpart for the
appservice sender identity. The server MUST enforce that no regular user
registration can claim a localpart equal to `sender_localpart` for any loaded
appservice. Attempts to register or use such a localpart as a regular user
account MUST fail with `M_EXCLUSIVE`.

### Token Redaction in Artifacts

Tokens (`as_token`, `hs_token`) MUST be redacted in all log lines and release
artifacts. Any evidence artifact that contains an unredacted token value MUST be
rejected. Token values in artifacts must be replaced with a placeholder such as
`[REDACTED]`.

### Malformed Registration Rejection

Registration files missing any of these required fields MUST be rejected on
load:

- `id`
- `url`
- `as_token`
- `hs_token`
- `sender_localpart`
- `namespaces`

Absence of `rate_limited` or `receive_ephemeral` is allowed; they default to
`true` and `false` respectively per the specification.

### Restart Reload

On server restart, the server MUST reload registration files from disk. It MUST
NOT reconstruct the registration set from any runtime state cache. This ensures
that registration file changes take effect on the next restart.

## Resource Bounds

Runtime adoption is bounded:

- maximum application services per server: 10;
- token redaction required: true;
- restart reload required: true;
- duplicate `id` rejection: true;
- duplicate `as_token` rejection: true;
- exclusive namespace conflict detection: true;
- `rate_limited` throttle enforcement: false;
- ephemeral batching (`receive_ephemeral`): false;
- third-party network protocols: false;
- token rotation at runtime: false;
- versions advertisement widened: false.

Implementations MUST fail closed when these bounds are missing or weakened.

## Fail-Closed Behavior

Implementations must reject:

- registration sets with duplicate `id` values;
- registration sets with duplicate `as_token` values;
- registration sets with overlapping exclusive namespace regexes;
- requests to the appservice with an invalid or missing `hs_token`;
- appservice requests to the homeserver with an invalid or missing `as_token`;
- `sender_localpart` bypass attempts where a regular user claims the reserved
  localpart;
- registration files missing required fields;
- log lines or artifacts that contain unredacted token values.

Implementations must not:

- advertise Application Service API support from runtime registration evidence
  alone;
- widen `GET /_matrix/client/versions` from this evidence;
- claim full Application Service API support.

## Adoption Decision Checklist

After this contract merges:

- `houra-server#253` may adopt representative registration lifecycle runtime
  behavior using this vector.
- `houra-server#253` is the runtime implementation gate for this lane.
- `SPEC-105` remains the parser-only artifact boundary for the same lane.
- `SPEC-115` is the runtime gate for transaction event delivery and ephemeral
  batching.
- Release evidence must keep `advertisement_allowed=false` for Application
  Service API until the broader `SPEC-075` lanes are resolved for the release.

## Compatibility Boundaries

- `SPEC-058` remains the representative registration, namespace, transaction,
  and query gate.
- `SPEC-105` remains the parser-only artifact breadth boundary.
- `SPEC-075` remains the Application Service full-breadth gap inventory.
- `SPEC-115` owns transaction event delivery and ephemeral batching runtime.
- `SPEC-117` owns third-party network protocol metadata runtime.
- Passing this contract does not claim `rate_limited` throttle enforcement,
  ephemeral batching correctness, third-party network support, token rotation
  at runtime, Application Service API full breadth, or Matrix v1.18 full
  compliance.
