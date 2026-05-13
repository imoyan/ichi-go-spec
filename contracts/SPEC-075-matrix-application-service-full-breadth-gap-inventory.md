# SPEC-075: Matrix Application Service Full-Breadth Gap Inventory

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Define the current Matrix v1.18 Application Service API full-breadth gap
inventory before Houra widens any bridge, appservice, or Matrix ecosystem
support claim beyond the adopted representative subset.

This contract records a fail-closed decomposition decision. It intentionally
does not add Application Service endpoint behavior, mark bridge protocols as
supported, widen `GET /_matrix/client/versions`, or turn representative
registration and transaction smoke evidence into a full Application Service
claim.

## Scope

This contract is the bridge between the adopted Application Service subset in
`SPEC-058` and the broader Matrix v1.18 Application Service API.

The current release candidate keeps Application Service API out of the
advertised Matrix support scope. Full appservice and bridge work must be split
into explicit follow-up contracts or implementation issues before
`houra-server` can cite it as release evidence.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/application-service-api/>
- Checked at: 2026-05-14T08:08:07+09:00
- Timezone: Asia/Tokyo

## Current decision

Application Service API remains excluded from the current publishable Matrix
support claim.

The current release evidence may cite `SPEC-058` registration, namespace,
transaction, user-query, and room-alias-query gates as implementation evidence,
but it must also cite `imoyan/houra-server#137` as the open Application Service
full-breadth scope decision until all gap lanes below have their own passing
evidence or explicit release exclusion.

Servers must fail closed:

- do not advertise Application Service API, bridge, or third-party network
  support from representative registration, namespace, transaction, or query
  vectors alone;
- keep `houra-server#137` open while unsupported appservice breadth remains
  excluded from the release candidate;
- keep Matrix `/versions` empty for the current blocked release candidate
  unless a later release bundle shows included-domain evidence and matching
  release notes;
- preserve token redaction, appservice namespace boundaries, and fail-closed
  unsupported-route behavior in every follow-up lane.

## Covered subset

The current adopted subset is useful implementation evidence but not a full
Application Service claim:

- `SPEC-058`: registration file shape, exclusive namespace ownership,
  homeserver-to-appservice authorization, transaction push, user query,
  room-alias query, and sender localpart boundary.

## Required gap lanes

Future Application Service full-breadth work must be split into at least these
lanes. Each lane needs either a narrower spec contract with vectors, an
implementation issue with explicit non-advertisement, or both.

### Registration, namespace, token, and lifecycle breadth

Track registration and namespace behavior beyond the representative
registration vector:

- multiple application service registrations and unique `id` / `as_token`
  enforcement;
- `hs_token`, `as_token`, URL, null URL, `sender_localpart`, `rate_limited`,
  `receive_ephemeral`, and `protocols` parsing;
- namespace regex validation for `users`, `aliases`, and `rooms`;
- exclusive namespace conflicts across users, aliases, rooms, and other
  appservices;
- token rotation, secret redaction, malformed registration files, and restart
  reload behavior.

### Transaction, event delivery, legacy route, and unknown route breadth

Track homeserver-to-appservice event push behavior beyond the representative
transaction vector:

- `PUT /_matrix/app/v1/transactions/{txnId}`;
- event and ephemeral data batches, including typing, receipts, and presence
  payloads when `receive_ephemeral` is enabled;
- retry, backoff, timeout, duplicate transaction, and idempotency behavior;
- legacy route fallback for transaction, user query, room query, and
  third-party network endpoints;
- 404 / 405 `M_UNRECOGNIZED` behavior for unsupported routes and methods.

### Query, user, room-alias, and namespace ownership breadth

Track appservice query behavior beyond the representative user and room-alias
query vector:

- `GET /_matrix/app/v1/users/{userId}`;
- `GET /_matrix/app/v1/rooms/{roomAlias}`;
- authorization failures, missing mappings, namespace misses, and malformed
  identifiers;
- interaction between exclusive namespaces, local users, room aliases, and
  appservice-created entities;
- release evidence for 200, 401, 403, and 404 outcomes.

### Third-party network directory breadth

Track third-party network lookup and protocol metadata surfaces:

- `GET /_matrix/app/v1/thirdparty/location`;
- `GET /_matrix/app/v1/thirdparty/location/{protocol}`;
- `GET /_matrix/app/v1/thirdparty/protocol/{protocol}`;
- `GET /_matrix/app/v1/thirdparty/user`;
- `GET /_matrix/app/v1/thirdparty/user/{protocol}`;
- protocol metadata, instance metadata, location fields, user fields, legacy
  fallback routes, and auth failure artifacts.

### Ping and liveness breadth

Track both appservice-facing and client-server appservice ping behavior:

- `POST /_matrix/app/v1/ping`;
- `POST /_matrix/client/v1/appservice/{appserviceId}/ping`;
- `transaction_id` passthrough, duration reporting, bad status, connection
  failure, timeout, URL-not-set, and token/appservice mismatch errors;
- health-check evidence that does not leak tokens or appservice URLs.

### Client-Server extension masquerade, timestamp, and admin-permission breadth

Track appservice-only Client-Server API extension behavior:

- appservice `as_token` identity assertion through the Client-Server API;
- `user_id` masquerading and v1.17 `device_id` masquerading;
- timestamp massaging through `ts` on event send and state endpoints;
- `m.login.application_service` registration and legacy login boundaries;
- namespace-controlled room alias and user management permissions.

### Client-Server extension sync, directory, device, and cross-signing breadth

Track appservice Client-Server extensions that interact with broader Matrix
domains:

- `/sync` and `/events` use only through virtual users;
- `PUT /_matrix/client/v3/directory/list/appservice/{networkId}/{roomId}`;
- appservice device creation and deletion without user-interactive auth;
- appservice cross-signing key upload without user-interactive auth;
- interactions with OAuth-only homeserver deployments and E2EE evidence gates.

### Bridge external URL, security, observability, and release evidence breadth

Track bridge-facing behavior that should not be implied by the representative
subset:

- `external_url` handling for messages bridged from third-party networks;
- client-visible URL scheme safety and non-trust of arbitrary event URLs;
- token, registration, and outbound request redaction in logs and artifacts;
- metrics, audit logs, trace IDs, and release-bundle linkage to `SPEC-062`,
  `SPEC-064`, `SPEC-065`, and `SPEC-066`;
- issue refs for intentionally excluded bridge protocol behavior.

## Adoption decision checklist

After this contract merges:

- `houra-server#137` may cite `SPEC-075` as the Application Service
  full-breadth gap inventory for the current blocked release candidate.
- Future `houra-server` child issues should map one gap lane to one focused
  implementation or release-scope decision.
- `houra-client` work should not be created for Application Service internals
  unless a later user-facing appservice or bridge-management surface is
  explicitly scoped.
- `houra-labs` work should be created only when parser-only registration,
  namespace, protocol metadata, or evidence-artifact helpers are intentionally
  scoped.
- Release evidence must keep `advertisement_allowed=false` for Application
  Service API until every included lane has passing evidence or is explicitly
  excluded from that release candidate.

## Compatibility boundaries

- `SPEC-058` remains a representative Application Service gate, not a full
  Application Service API, third-party network, or bridge protocol conformance
  gate.
- Application Service support remains separate from Identity Service, Push
  Gateway, Room Versions, Olm & Megolm, and full Client-Server API breadth
  unless a later contract explicitly links the domains.
