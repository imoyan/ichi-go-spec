# SPEC-125: Matrix Application Service Query User Room Namespace Runtime

Status: draft
Feature profile: core
Contract type: boundary
Matrix domain: Application Service API
Canonical: yes

## Purpose

Define the focused homeserver-to-appservice query runtime boundary promoted from
the `SPEC-075` `query-user-room-alias-and-namespace-ownership-breadth` lane after
`SPEC-058` established representative user and room-alias query behavior.

This contract lets implementation repositories adopt representative runtime
behavior for homeserver-initiated user and room-alias existence queries without
claiming virtual user creation, third-party network queries, appservice ping,
complete namespace correctness, outbound federation, or full Application Service
API support.

## Scope

This contract covers representative runtime behavior for:

```text
GET /_matrix/app/v1/users/{userId}
GET /_matrix/app/v1/rooms/{roomAlias}
```

Only these public behaviors are adopted:

- `Authorization: Bearer <hs_token>` validation for every adopted query route;
- representative user existence query response for a user within the exclusive
  namespace;
- representative room-alias existence query response for an alias within the
  exclusive namespace;
- Matrix-compatible failures for missing or invalid `hs_token`, namespace misses,
  and malformed identifiers;
- release evidence for 200, 401, 403, and 404 outcome artifacts;
- exclusive namespace checked before local user or alias lookup order.

This contract does not define virtual user creation, third-party network protocol
queries, appservice ping or liveness, complete namespace conflict resolution,
Client-Server masquerading, outbound federation, or Matrix version advertisement.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/application-service-api/#get_matrixappv1usersuserid>
- Source: <https://spec.matrix.org/v1.18/application-service-api/#get_matrixappv1roomsroomalias>
- Source: <https://spec.matrix.org/v1.18/application-service-api/#authorization>
- Parent contract: `SPEC-058`, `SPEC-105`
- Gap inventory: `SPEC-075`
- Checked at: 2026-05-17T12:00:00+09:00
- Timezone: Asia/Tokyo

## Runtime Behavior

Servers adopting this contract MUST serve the representative endpoint family
from local server state without making remote network requests.

User query responses MUST preserve:

- HTTP 200 with an empty JSON object `{}` when the queried `userId` is within
  the appservice's exclusive `users` namespace;
- HTTP 404 with `M_NOT_FOUND` when the `userId` is outside the exclusive
  namespace;
- HTTP 401 with `M_UNAUTHORIZED` when the `Authorization` header is absent;
- HTTP 403 with `M_FORBIDDEN` when the `hs_token` value is invalid or does not
  match the registered token;
- HTTP 400 with `M_INVALID_PARAM` when the `userId` path parameter is not a
  well-formed Matrix user ID.

Room-alias query responses MUST preserve:

- HTTP 200 with an empty JSON object `{}` when the queried `roomAlias` is within
  the appservice's exclusive `aliases` namespace;
- HTTP 404 with `M_NOT_FOUND` when the `roomAlias` is outside the exclusive
  namespace;
- the same authorization failure responses as user queries;
- HTTP 400 with `M_INVALID_PARAM` when the `roomAlias` path parameter is not a
  well-formed Matrix room alias.

Namespace resolution order MUST preserve:

- exclusive namespace membership check before any local user or alias resolution;
- a user or alias owned by the exclusive namespace must not expose the existence
  of a local entity with the same identifier.

## Resource Bounds

Runtime adoption is bounded:

- request authorization required: true;
- exclusive namespace check before local resolution: true;
- virtual user creation during query: false;
- third-party network queries claimed: false;
- appservice ping claimed: false;
- outbound federation execution: false;
- complete namespace conflict resolution claimed: false;
- Client-Server masquerading claimed: false;
- versions advertisement widened: false.

Implementations MUST fail closed when these bounds are missing or weakened.

## Fail-Closed Behavior

Implementations must reject:

- missing or absent `Authorization` header;
- invalid or mismatched `hs_token` bearer tokens;
- `userId` values that are not well-formed Matrix user IDs;
- `roomAlias` values that are not well-formed Matrix room aliases;
- users outside the exclusive `users` namespace with a 404, not a 200;
- aliases outside the exclusive `aliases` namespace with a 404, not a 200;
- local user or alias existence leaking through a namespace-miss 404 path;
- route methods outside the adopted endpoint family.

## Adoption Decision Checklist

After this contract merges:

- `houra-server#255` may adopt representative runtime behavior using this
  vector.
- `houra-server#137` remains the owner for Application Service full-breadth
  scope until all gap lanes have passing evidence or explicit release exclusion.
- `houra-server#137` must keep `advertisement_allowed=false` for Application
  Service API until the broader `SPEC-075` lanes are resolved for the release.
- Third-party network query adoption is owned by the follow-up contract
  promoted from the SPEC-075 third-party-network-directory lane.
- Virtual user creation adoption remains scoped to a separate implementation
  issue and must not be inferred from passing this contract.

## Compatibility Boundaries

- `SPEC-058` remains the representative Application Service registration,
  transaction, user-query, and room-alias-query gate.
- `SPEC-105` remains the parser-only Application Service artifact breadth
  contract.
- `SPEC-075` remains the Application Service full-breadth gap inventory.
- `SPEC-117` owns the third-party network directory parser-only boundary.
- `SPEC-118` owns the appservice ping and liveness runtime boundary.
- Passing this contract does not claim virtual user creation, complete namespace
  correctness, third-party network queries, Complement full-breadth, or Matrix
  v1.18 full compliance.
