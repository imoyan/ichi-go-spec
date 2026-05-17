# Matrix v1.18 / Application Service API / registration and username availability endpoints

Status: draft
Feature profile: core
Contract type: endpoint
Matrix domain: Application Service API
Primary reference: Matrix v1.18 / Application Service API / registration and username availability endpoints
Repository anchor: SPEC-058 Matrix Application Service Registration and Transaction
Canonical: yes

## Purpose

Define the Matrix v1.18 Application Service registration, namespace ownership,
transaction, and query contract for Houra ecosystem API work.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds the application
service boundary used between a homeserver and an application service. It does
not change existing `/_houra/client/**`, `/_matrix/client/**`,
`/.well-known/**`, `/_matrix/key/**`, or `/_matrix/federation/**` behavior.

This contract covers registration file shape, exclusive namespace ownership,
homeserver-to-application-service authorization, pushed transactions, user
queries, room-alias queries, and sender localpart boundaries. It does not define
third-party network directories, appservice ping, bridge-specific protocol
semantics, UI, federation, identity, or push gateway behavior.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/application-service-api/#application-services>
- Source: <https://spec.matrix.org/v1.18/application-service-api/#registration>
- Source: <https://spec.matrix.org/v1.18/application-service-api/#put_matrixappv1transactionstxnid>
- Source: <https://spec.matrix.org/v1.18/application-service-api/#get_matrixappv1usersuserid>
- Source: <https://spec.matrix.org/v1.18/application-service-api/#get_matrixappv1roomsroomalias>
- Source: <https://spec.matrix.org/v1.18/application-service-api/#authorization>
- Checked at: 2026-05-10T21:03:30+09:00
- Timezone: Asia/Tokyo

## Registration

Application services are registered by homeserver configuration, normally as a
YAML object. The registration includes:

- `id`, unique per application service;
- `url`, the application service base URL;
- `as_token`, used when the application service calls the homeserver;
- `hs_token`, used by the homeserver when calling the application service;
- `sender_localpart`, the localpart for the application service sender user;
- `namespaces`, containing `users`, `aliases`, and `rooms` namespace entries.

Each namespace entry contains `exclusive` and `regex`. Exclusive namespaces
prevent humans and other application services from creating or deleting entities
inside the namespace. Exclusive user and alias namespaces should use underscore
prefixes after the sigil to reduce collisions.

## Homeserver to application service

Homeservers call application services with:

```text
PUT /_matrix/app/v1/transactions/{txnId}
GET /_matrix/app/v1/users/{userId}
GET /_matrix/app/v1/rooms/{roomAlias}
```

Homeservers must include `Authorization: Bearer <hs_token>` when making these
requests. Application services verify the bearer token and return Matrix
`M_FORBIDDEN` on mismatch.

Transactions are idempotent by transaction ID. If the homeserver retries the
same transaction because an acknowledgement was lost, the application service
must be able to no-op an already processed transaction.

## Namespace queries

The homeserver only queries user IDs inside the application service's `users`
namespace and only queries room aliases inside its `aliases` namespace. The
application service may create the queried entity during the query.

Events are pushed to the application service when they match user, alias, or
room namespace interest. Local users are considered for user namespaces; remote
users are not sent solely because their user ID matches a user namespace unless
the room is interesting for another reason.

## Sender localpart and masquerading boundary

`sender_localpart` identifies the application service sender user. When the
application service later calls Client-Server APIs with `as_token`, optional
masquerading via `user_id` or `device_id` remains bounded by registered
namespaces. This contract records the boundary but does not add Client-Server
masquerading route vectors.

## Compatibility boundaries

- Existing Houra and Matrix client/federation behavior stays available.
- `as_token` and `hs_token` are secrets and must never be logged in full or
  stored in public evidence.
- This contract introduces application service boundary contracts only. It does
  not claim third-party network APIs, ping, bridge protocol behavior, identity,
  push gateway, or Matrix v1.18 full ecosystem compliance.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create an adoption issue for `houra-server`.
  Do not create `houra-client` work unless a later user-facing appservice
  management surface is intentionally added. Create an `houra-labs` issue only
  if parser-only helpers for registration or namespace matching are
  intentionally adopted.
