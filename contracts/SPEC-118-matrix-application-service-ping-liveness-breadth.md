# SPEC-118: Matrix Application Service Ping and Liveness Breadth

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Define the focused Application Service ping and liveness runtime boundary
promoted from the `SPEC-075` `ping-and-liveness-breadth` lane after `SPEC-058`
established representative Application Service registration and transaction
behavior.

This contract lets implementation repositories adopt representative runtime
behavior for homeserver-to-appservice ping and client-triggered ping without
claiming general appservice availability monitoring, push delivery liveness
beyond a single ping, virtual user session liveness, or full Application Service
API support.

## Scope

This contract covers representative runtime behavior for:

```text
POST /_matrix/app/v1/ping
POST /_matrix/client/v1/appservice/{appserviceId}/ping
```

Only these public behaviors are adopted:

- homeserver pings an appservice to check liveness via `POST /_matrix/app/v1/ping`;
- client triggers homeserver-to-appservice ping via
  `POST /_matrix/client/v1/appservice/{appserviceId}/ping`;
- optional `transaction_id` passthrough in the ping request body;
- optional `duration_ms` reporting in the ping response body;
- non-2xx response from appservice propagated as an error to the client;
- connection failure, timeout, or unreachable appservice propagated as a gateway
  error to the client;
- URL-not-set error when the appservice registration has a null URL;
- token or appservice mismatch errors for wrong `hs_token` or unknown
  `appserviceId`;
- health-check evidence with tokens and appservice URLs redacted from artifacts.

This contract does not define general appservice availability monitoring, push
delivery liveness beyond a single representative ping, virtual user session
liveness, or any appservice metric collection behavior.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/application-service-api/#post_matrixappv1ping>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv1appserviceappserviceidping>
- Parent contract: `SPEC-058`, `SPEC-105`
- Gap inventory: `SPEC-075`
- Checked at: 2026-05-17T12:00:00+09:00
- Timezone: Asia/Tokyo

## Runtime Behavior

Servers adopting this contract MUST serve the representative endpoint family
from local server state without making persistent external connections for test
purposes.

Homeserver ping to appservice MUST preserve:

- `transaction_id` forwarded from request body to the appservice when present;
- HTTP 200 with optional `duration_ms` in the response body on appservice
  acknowledgement;
- propagation of any non-2xx appservice HTTP status as an error returned to the
  caller;
- propagation of connection failure or timeout as a gateway-class error to the
  caller.

Client-triggered ping MUST preserve:

- a valid `appserviceId` path parameter matched against registered appservices;
- HTTP 404 with `M_NOT_FOUND` for an unknown `appserviceId`;
- immediate error for a registered appservice with null URL without attempting
  a connection;
- token or `hs_token` mismatch propagated as an auth error to the caller;
- the same `duration_ms` and error propagation behavior as homeserver-originated
  pings.

Health-check artifact requirements MUST preserve:

- `hs_token` values MUST NOT appear in ping request or response artifacts;
- appservice base URL MUST NOT appear in ping artifacts;
- `duration_ms`, when present, MUST be a non-negative integer.

## Resource Bounds

Runtime adoption is bounded:

- request authorization required: true;
- token redaction in artifacts required: true;
- appservice URL redaction in artifacts required: true;
- general appservice availability monitoring claimed: false;
- push delivery liveness beyond single ping claimed: false;
- virtual user session liveness claimed: false;
- metric collection claimed: false;
- outbound federation execution: false;
- versions advertisement widened: false.

Implementations MUST fail closed when these bounds are missing or weakened.

## Fail-Closed Behavior

Implementations must reject:

- appservice ping attempts where the registered URL is null or absent;
- client-triggered pings for an unknown `appserviceId` without returning 404;
- invalid or mismatched `hs_token` without returning an auth error;
- `hs_token` or appservice URL appearing in any ping artifact or log entry;
- `duration_ms` values that are negative;
- non-2xx appservice responses silently treated as success;
- connection timeouts silently treated as success;
- route methods outside the adopted endpoint family.

## Adoption Decision Checklist

After this contract merges:

- `houra-server#256` may adopt representative runtime behavior using this
  vector.
- `houra-server#137` remains the owner for Application Service full-breadth
  scope until all gap lanes have passing evidence or explicit release exclusion.
- `houra-server#137` must keep `advertisement_allowed=false` for Application
  Service API until the broader `SPEC-075` lanes are resolved for the release.
- General appservice availability monitoring and metric collection adoption
  remain out of scope unless a later contract explicitly scopes them.
- Virtual user session liveness adoption remains out of scope unless a later
  contract explicitly scopes it.

## Compatibility Boundaries

- `SPEC-058` remains the representative Application Service registration,
  transaction, user-query, and room-alias-query gate.
- `SPEC-105` remains the parser-only Application Service artifact breadth
  contract.
- `SPEC-075` remains the Application Service full-breadth gap inventory.
- `SPEC-116` owns the user and room-alias query runtime boundary.
- `SPEC-117` owns the third-party network directory parser-only boundary.
- Passing this contract does not claim availability monitoring, push delivery
  liveness breadth, virtual user session liveness, Complement full-breadth, or
  Matrix v1.18 full compliance.
