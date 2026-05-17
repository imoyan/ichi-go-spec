# SPEC-115: Matrix Application Service Masquerade and Timestamp Runtime

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Define the focused server-runtime adoption boundary promoted from the
`SPEC-075` `client-server-extension-masquerade-timestamp-admin-breadth` lane.

This contract lets implementation repositories adopt representative
Application Service Client-Server extension behavior for `as_token` identity
assertion, `user_id` / `device_id` masquerading, and `ts` timestamp massaging
without claiming full Application Service API support, bridge administration,
normal user authentication bypass, Room Version authorization changes, or
Matrix v1.18 domain advertisement.

## Scope

This contract covers representative runtime behavior for Application Service
calls to these Client-Server routes:

```text
PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}
PUT /_matrix/client/v3/rooms/{roomId}/state/{eventType}/{stateKey}
```

Only these public behaviors are adopted:

- `as_token` identity assertion for a registered application service;
- `user_id` masquerading for users inside the registered `users` namespace;
- `device_id` masquerading when paired with a valid namespaced `user_id`;
- `ts` query-parameter timestamp massaging on representative event send and
  state event writes;
- Matrix-compatible failures for missing appservice tokens, unknown tokens,
  namespace misses, invalid masquerade devices, invalid timestamps, and normal
  user tokens attempting appservice-only extensions.

This contract does not define bridge management UI, third-party network
protocol metadata, appservice ping, application-service login as an adopted
runtime path, appservice device lifecycle, appservice cross-signing bypass,
normal user admin controls, complete Room Version authorization, production
history visibility, or Matrix version advertisement.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/application-service-api/#client-server-api-extensions>
- Source: <https://spec.matrix.org/v1.18/application-service-api/#identity-assertion>
- Source: <https://spec.matrix.org/v1.18/application-service-api/#timestamp-massaging>
- Parser-helper contract: `SPEC-105`
- Gap inventory: `SPEC-075`
- Checked at: 2026-05-17T08:50:00+09:00
- Timezone: Asia/Tokyo

## Runtime Behavior

Servers adopting this contract MUST treat `as_token` as an application-service
credential, not as a normal user access token. The appservice token may assert
identity for the registered sender user or for a `user_id` inside the
registered appservice `users` namespace.

Masquerading is bounded:

- the asserted `user_id` MUST be a valid Matrix user ID;
- the asserted `user_id` MUST match the registered appservice `users`
  namespace;
- if `device_id` is supplied, the request MUST also supply a valid
  namespaced `user_id`;
- `device_id` MUST be a bounded opaque Matrix device ID string and MUST NOT
  create or delete devices outside this representative request;
- application services MUST NOT use masquerading to bypass normal user auth,
  account moderation, user-interactive auth, or admin-only routes.

Timestamp massaging is bounded:

- `ts` is accepted only for appservice-authenticated representative send and
  state writes;
- `ts` MUST be a non-negative integer millisecond timestamp;
- accepted `ts` values become the emitted event's `origin_server_ts`;
- invalid, missing-numeric, negative, fractional, or unbounded timestamp values
  fail closed with Matrix-compatible errors;
- timestamp massaging MUST NOT change event authorization, state resolution,
  room-version auth rules, timeline visibility, or transaction idempotency.

## Application-Service Login Decision

This contract does not adopt `m.login.application_service` registration or
legacy login as runtime behavior. Implementations may expose a fail-closed
login-flow descriptor only when it is explicitly marked unsupported for the
current release candidate.

A future contract must be opened before Houra treats
`m.login.application_service` registration or legacy login as supported.

## Resource and Security Bounds

Runtime adoption is bounded:

- maximum `user_id` length: 255 bytes after UTF-8 encoding;
- maximum `device_id` length: 255 bytes after UTF-8 encoding;
- `ts` maximum: `9007199254740991`;
- raw `as_token` values in logs or evidence: forbidden;
- appservice namespace lookup: local configured registrations only;
- remote bridge lookup: false;
- appservice device lifecycle mutation: false;
- appservice cross-signing bypass: false;
- versions advertisement widened: false.

Implementations MUST fail closed when these bounds are missing or weakened.

## Fail-Closed Behavior

Implementations must reject:

- missing appservice token on appservice-only masquerade or timestamp requests;
- unknown `as_token`;
- normal user bearer tokens using `user_id`, `device_id`, or `ts` appservice
  extension parameters;
- masqueraded `user_id` values outside the registered namespace;
- `device_id` without a valid appservice-masqueraded `user_id`;
- malformed or oversized `device_id` values;
- malformed, fractional, negative, or too-large `ts` values;
- `m.login.application_service` registration and legacy login when unsupported;
- appservice attempts to use this contract as an admin-control or Room Version
  authorization bypass.

## Adoption Decision Checklist

After this contract merges:

- `houra-server#238` may adopt representative runtime behavior using this
  vector.
- `houra-server#137` remains the Application Service full-breadth owner until
  all `SPEC-075` lanes are resolved or explicitly excluded.
- Release evidence must keep `advertisement_allowed=false` for Application
  Service API until the broader `SPEC-075` lanes are resolved for the release.
- `houra-client` work should not be created for this appservice-internal
  runtime boundary unless a later user-facing appservice management surface is
  explicitly scoped.

## Compatibility Boundaries

- `SPEC-058` remains the representative registration, namespace, transaction,
  and query gate.
- `SPEC-075` remains the Application Service full-breadth gap inventory.
- `SPEC-105` remains the parser-only Application Service artifact boundary.
- `SPEC-049` remains the normal user moderation and admin-control boundary.
- `SPEC-078`, `SPEC-080`, `SPEC-083`, and `SPEC-084` remain Room Versions
  evidence boundaries; timestamp massaging does not change room-version
  authorization.
- Passing this contract does not claim bridge protocol behavior, third-party
  network support, application-service login support, full Application Service
  API support, or Matrix v1.18 full compliance.
