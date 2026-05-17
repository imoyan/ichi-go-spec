# Matrix v1.18 / Room Versions / Matrix Event DAG and Auth Event References

Status: draft
Feature profile: events
Contract type: boundary
Matrix domain: Room Versions
Primary reference: Matrix v1.18 / Room Versions / Matrix Event DAG and Auth Event References
Repository anchor: SPEC-040 Matrix Event DAG and Auth Event References
Canonical: yes

## Purpose

Define the Matrix v1.18 room event graph contract needed before Houra can move
from MVP timeline events to Matrix-compatible room data storage.

This contract covers the persisted event envelope, `prev_events` DAG edges, and
`auth_events` reference integrity. It is a spec and vector gate only; it does
not add a new Client-Server endpoint.

## Scope

This contract is Matrix-defined, not Houra-defined. It extends the event model
from `SPEC-007` and the client-facing event shapes from `SPEC-035` through
`SPEC-037` with the server/storage-facing data required to preserve Matrix room
event graph structure.

The contract covers:

- a vector envelope that binds an event ID to a Matrix room-version event body
- `prev_events` as the parent edges that order room events in a DAG
- `auth_events` as references to the state events used to authorize a candidate
  event
- duplicate, missing, self-referential, cross-room, and cyclic reference
  rejection rules for accepted stored events
- adoption evidence required before server persistence can claim Matrix event
  graph support

Full room-version authorization decisions, state resolution, redaction
semantics, federation transaction exchange, signing-key discovery, event hash
verification, and stable support for room versions 1 through 12 are left to
later Room Versions and Federation contracts.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/rooms/v12/#event-format>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#pdus>
- Source: <https://spec.matrix.org/v1.18/appendices/#event-ids>
- Checked at: 2026-05-10T14:31:34+09:00
- Timezone: Asia/Tokyo

## Vector event set

The conformance vector uses an event set object rather than a public HTTP
request:

```json
{
  "matrix_spec_version": "v1.18",
  "room_version": "12",
  "room_id": "!roomVersion12CreateEventHash:example.test",
  "candidate_event_id": "$messageEventHash",
  "events": []
}
```

`event_id` is a vector/storage key for the event body. Implementations must not
assume that every signed PDU format includes `event_id` inside the signed event
content. Room-version-specific event ID derivation and canonical JSON signing
remain owned by later room-version and federation gates.

`room_id` is the room that owns the event set. For room version 12, the
`m.room.create` event body omits `room_id`; other events in the set must include
the same `room_id` as the vector root.

## Persisted event envelope

Every non-create persisted event in this contract must include:

- `event_id`: non-empty Matrix event ID used as the local storage key
- `room_id`: non-empty Matrix room ID equal to the event set room
- `type`: non-empty event type
- `sender`: non-empty Matrix user ID
- `content`: JSON object
- `origin_server_ts`: integer timestamp in milliseconds
- `depth`: integer equal to the maximum referenced `prev_events` depth plus one
- `prev_events`: array of event IDs, at most 20 entries
- `auth_events`: array of event IDs, at most 10 entries
- `hashes.sha256`: non-empty string
- `signatures`: non-empty object keyed by signing server name

State events additionally include `state_key` as a string. `m.room.create`
events are state events with `state_key: ""`, empty `prev_events`, and, for room
version 12, no `room_id` field in the event body.

## `prev_events` DAG rules

Accepted stored events must satisfy these reference rules:

- `prev_events` entries are Matrix event IDs.
- `prev_events` must not contain duplicate event IDs.
- `prev_events` must not contain the candidate event's own event ID.
- Every referenced previous event must be known in the same room before the
  candidate event is accepted as persisted.
- The directed graph formed by `prev_events` must be acyclic.
- A non-create event normally has at least one previous event. A missing parent
  is not silently repaired by treating the event as a new root.
- `depth` must match the maximum known previous-event depth plus one, capped by
  the Matrix integer limit. The vectors use exact, uncapped values.

Federation may later define quarantine or missing-event queues. Such queues
must not be counted as accepted event DAG persistence until the missing
references are resolved and this gate passes.

## `auth_events` reference rules

Accepted stored events must satisfy these authorization-reference rules before
later room-version-specific authorization is evaluated:

- `auth_events` entries are Matrix event IDs.
- `auth_events` must not contain duplicate event IDs.
- `auth_events` must not contain the candidate event's own event ID.
- Every referenced authorization event must be known in the same room.
- Referenced authorization events must be state events.
- A candidate's `auth_events` must not contain more than one event for the same
  `(type, state_key)` tuple.
- For the room version 12 vectors in this contract, `m.room.create` is implied
  by the room ID and must not be selected into `auth_events`.

This contract validates the shape and reference set. Whether the selected auth
events actually authorize a membership, power-level, redaction, or message
event is owned by the later room-version auth vector gate.

## Error mapping

The vectors use `M_INVALID_PARAM` for rejected local event-graph input. Public
endpoint contracts may map the same underlying validation failure to a more
specific Matrix status and error code when the endpoint semantics require it,
but they must preserve Matrix `M_*` error envelopes.

## Adoption issue creation

After this spec PR is merged:

- create an `houra-server` adoption issue for Matrix event DAG persistence,
  including event ID storage, room ID binding, `prev_events`, `auth_events`,
  `depth`, state tuple indexing, restart persistence, and vector evidence
- create an `houra-labs` adoption issue only if a shared Rust parser or event
  validation helper is intentionally adopted for these vectors
- do not create an `houra-client` adoption issue for this contract unless the
  UI-free client core begins parsing or validating server/storage-facing DAG
  envelopes

Do not create implementation adoption issues before this contract is merged.

## Compatibility boundaries

- Existing `/_houra/client/**` event and timeline behavior stays available.
- Client-facing Matrix event responses from `SPEC-035` through `SPEC-037` do
  not need to expose `prev_events`, `auth_events`, `hashes`, or `signatures`.
- Passing this contract does not claim room versions 1 through 12 support,
  state resolution support, federation support, redaction correctness, or
  Matrix v1.18 full compliance.
- Passing this contract must not widen `GET /_matrix/client/versions`
  advertisement without implementation evidence and the later release
  advertisement gate.
