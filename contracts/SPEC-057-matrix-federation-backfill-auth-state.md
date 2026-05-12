# SPEC-057: Matrix Federation Backfill, Event Auth, and State Interop

Status: draft
Feature profile: events
Canonical: yes

## Purpose

Define the Matrix v1.18 Server-Server backfill, event-auth, and
state-resolution interop gate for Houra federation work.

## Scope

This contract is Matrix-defined, not Houra-defined. It extends
`/_matrix/federation/**` behavior without changing existing `/_houra/client/**`
or `/_matrix/client/**` routes.

This contract builds on `SPEC-055` discovery/signing-key bootstrap and
`SPEC-056` transaction/join/invite exchange. It covers historical PDU backfill,
auth-chain retrieval, state/state ID retrieval at a known event, and
representative cross-server state-resolution evidence. It does not define full
room-version auth-rule completeness, complete state-resolution algorithm
coverage, get_missing_events, timestamp lookup, leave/knock flows, or reference
homeserver interop smoke.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/server-server-api/#backfilling-and-retrieving-missing-events>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#get_matrixfederationv1backfillroomid>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#get_matrixfederationv1event_authroomideventid>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#room-state-resolution>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#get_matrixfederationv1stateroomid>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#get_matrixfederationv1state_idsroomid>
- Source: <https://spec.matrix.org/v1.18/rooms/#state-resolution>
- Checked at: 2026-05-10T20:55:14+09:00
- Timezone: Asia/Tokyo

## Backfill

Servers request historical PDUs with:

```text
GET /_matrix/federation/v1/backfill/{roomId}
```

The request supplies one or more `v` event IDs to backfill from and a `limit`.
The response is a transaction-style object with `origin`, `origin_server_ts`,
and `pdus`. Returned PDUs are room-version-specific event objects and are still
subject to normal event validation after retrieval.

Backfill responses must not be rejected solely because historical `prev_events`
or `auth_events` counts exceed current room-version limits. Those events may
still fail normal auth or event validation later.

## Event auth

Servers retrieve the auth chain for an event with:

```text
GET /_matrix/federation/v1/event_auth/{roomId}/{eventId}
```

The response contains `auth_chain`, a list of PDUs needed to authorize the
requested event. The receiver verifies event signatures, hashes, room IDs,
sender/server relationships, and the room-version auth rules that are already
covered by `SPEC-040` through `SPEC-043`.

## State and state IDs

Servers retrieve state at a point in the room graph with:

```text
GET /_matrix/federation/v1/state/{roomId}?event_id={eventId}
GET /_matrix/federation/v1/state_ids/{roomId}?event_id={eventId}
```

`/state` returns `pdus` and `auth_chain`. `/state_ids` returns `pdu_ids` and
`auth_chain_ids`. This gate currently provides canonical vectors for
`/state_ids`; `/state` body-vector coverage is deferred until a later
federation state-response contract. Both endpoints remain part of the broader
Matrix behavior needed to recover enough room state to validate missing events
and continue federation.

## State-resolution interop gate

A passing implementation must demonstrate a two-homeserver interop smoke in
which one server:

- receives a federated event that references missing prev/auth state;
- backfills the missing PDU history from the resident server;
- retrieves event auth for the target event;
- retrieves state IDs at the target event;
- evaluates the representative room-version 12 state set using the existing
  `SPEC-041` and `SPEC-043` vectors;
- records whether the event is accepted, soft-failed, or rejected;
- records spec ref, local server ref, remote server ref, room version, commands,
  and per-step pass/fail evidence.

This gate is representative. It is not a full replacement for Complement or a
complete room-version state-resolution proof.

## Compatibility boundaries

- Existing `/_houra/client/**`, `/_matrix/client/**`, `/.well-known/**`,
  `/_matrix/key/**`, and existing `/_matrix/federation/**` behavior stays
  available.
- Server signing key discovery and request authentication come from `SPEC-055`.
- Transaction and join/invite exchange come from `SPEC-056`.
- This contract does not claim get_missing_events, timestamp lookup, full room
  auth/state-resolution completeness, federation E2EE EDU handling, reference
  homeserver interop, or Matrix v1.18 full federation compliance.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create an adoption issue for `houra-server`.
  Do not create `houra-client` work unless a later client-visible federation
  surface is intentionally added. Create an `houra-labs` issue only if
  parser-only or room-version-helper adoption is intentionally scoped with
  parity vectors and performance gates.
