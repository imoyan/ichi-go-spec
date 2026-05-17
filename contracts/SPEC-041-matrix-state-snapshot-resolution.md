# SPEC-041: Matrix State Snapshot and State Resolution Vectors

Status: draft
Feature profile: events
Contract type: boundary
Matrix domain: Room Versions
Canonical: yes

## Purpose

Define the Matrix v1.18 room state snapshot and representative state resolution
vectors needed after `SPEC-040` event DAG persistence.

This contract makes state snapshots and state-resolution inputs testable before
Houra claims full room-version algorithm support. It is a spec and vector gate
only; it does not add a new Client-Server endpoint.

## Scope

This contract is Matrix-defined, not Houra-defined. It builds on `SPEC-040`
event graph references and adds the state map data shape that server storage
and room-version helpers must preserve.

The contract covers:

- state snapshot entries keyed by `(event_type, state_key)`
- applying state events and message events to a snapshot
- unconflicted state map and conflicted state set classification
- representative state resolution vectors for identical state sets and a
  simple non-power state conflict
- adoption evidence required before server persistence can claim restart-safe
  state snapshot support

This contract does not implement the complete Matrix room version 12 state
resolution algorithm, room versions 1 through 12 support, full iterative auth
checks, redaction handling, power-level conflict completeness, federation
backfill, or signing-key validation. Those remain separate Room Versions and
Federation gates.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/rooms/v12/#state-resolution>
- Source: <https://spec.matrix.org/v1.18/rooms/v12/#definitions>
- Source: <https://spec.matrix.org/v1.18/rooms/v12/#algorithm>
- Checked at: 2026-05-10T14:58:00+09:00
- Timezone: Asia/Tokyo

## State entry format

State snapshots in this repository use structured entries instead of stringly
encoded map keys:

```json
{
  "type": "m.room.member",
  "state_key": "@alice:example.test",
  "event_id": "$memberAlice"
}
```

The tuple `(type, state_key)` is the state key. Each snapshot must contain at
most one entry for a tuple. `event_id` must reference an event in the vector's
`event_catalog`, and that event must be a state event whose `type` and
`state_key` match the entry.

## Snapshot application rules

The state after an event is defined by the event kind:

- A message event does not change the state snapshot.
- A state event replaces the snapshot entry for its `(type, state_key)` tuple.
- If the tuple does not exist yet, the state event adds it.

Snapshots are persistence artifacts. Implementations may store them as rows,
materialized JSON, or rebuildable indexes, but the observable vector result must
be the same after restart.

## State resolution vector rules

Resolution vectors contain multiple state sets. For these vectors:

- A tuple that is present in every state set with the same event ID belongs to
  the unconflicted state map.
- A tuple that is missing from any state set or has different event IDs across
  state sets contributes its referenced events to the conflicted state set.
- The `resolved_state` expected by the vector must contain one event per tuple.
- The simple non-power conflict vector orders allowed events by timestamp and
  event ID, then applies them in that order, so the later applied event replaces
  the earlier event for the same tuple.

The final bullet is a representative vector fixture, not a substitute for the
complete Matrix room version 12 algorithm. Full power-event ordering, mainline
ordering, conflicted state subgraph expansion, auth difference calculation, and
iterative auth completeness are intentionally left to later room-version auth
gates.

## Adoption issue creation

After this spec PR is merged:

- create an `houra-server` adoption issue for restart-safe state snapshots,
  state tuple indexing, state-set resolution vector coverage, and persistence
  evidence
- create an `houra-labs` adoption issue only if a shared Rust state map,
  resolution fixture runner, or room-version helper is intentionally adopted
- do not create an `houra-client` adoption issue for this contract unless the
  UI-free client core begins validating server/storage-facing state snapshots

Do not create implementation adoption issues before this contract is merged.

## Compatibility boundaries

- Existing `/_houra/client/**` room state behavior stays available.
- Client-facing Matrix state responses from `SPEC-035` do not need to expose
  storage snapshots or state-resolution internals.
- Passing this contract does not claim Matrix room versions 1 through 12
  support, full state resolution support, federation support, redaction
  correctness, or Matrix v1.18 full compliance.
- Passing this contract must not widen `GET /_matrix/client/versions`
  advertisement without implementation evidence and the later release
  advertisement gate.
