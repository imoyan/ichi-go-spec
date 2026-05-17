# Matrix v1.18 / Room Versions / Matrix Room Alias, Upgrade, and Restart Persistence Gate

Status: draft
Feature profile: rooms
Contract type: gate
Matrix domain: Room Versions
Primary reference: Matrix v1.18 / Room Versions / Matrix Room Alias, Upgrade, and Restart Persistence Gate
Repository anchor: SPEC-044 Matrix Room Alias, Upgrade, and Restart Persistence Gate
Canonical: yes

## Purpose

Define the Matrix v1.18 room alias, room upgrade, and restart persistence gate
that closes the first Matrix data-model phase.

This contract ties room aliases, representative room upgrades, event graph
persistence, state snapshots, and room-version records into one adoption gate.
It is a spec and vector gate only; it does not claim full Client-Server room
directory breadth or federation upgrade behavior.

## Scope

This contract is Matrix-defined, not Houra-defined. It builds on:

- `SPEC-035` for room create/join/leave/state MVP endpoints
- `SPEC-040` for event DAG and auth-event references
- `SPEC-041` for state snapshots and representative resolution vectors
- `SPEC-042` for stable room versions and default room version `12`
- `SPEC-043` for representative room authorization vectors

The contract covers:

- room alias create, resolve, and delete data-model behavior
- representative room upgrade output for room version `12`
- restart persistence evidence for event graph, state snapshot, room version,
  room alias, and upgrade-link records

It does not cover public room directory search, alias visibility rules, all
upgrade migration details, federation room upgrade interop, or full room
version auth/state-resolution completeness.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#room-directory>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3roomsroomidupgrade>
- Checked at: 2026-05-10T15:52:00+09:00
- Timezone: Asia/Tokyo

## Room alias gate

A conforming implementation must persist room aliases as unique mappings from a
Matrix room alias to a room ID.

The representative vector covers:

- creating an alias for a known room
- resolving that alias to the same room ID and server name
- deleting the alias
- resolving the deleted alias as `M_NOT_FOUND`

Alias creation must reject duplicate aliases unless the same request is defined
as idempotent by a later endpoint-family contract. Alias creation must not
silently create rooms.

## Room upgrade gate

The representative upgrade vector covers upgrading an existing room to room
version `12`.

A conforming implementation must persist:

- the old room ID
- the replacement room ID
- the selected replacement room version
- the predecessor link on the replacement room create event
- the tombstone event in the old room

Moving aliases, inviting users, copying power levels, and transferring room
directory visibility are implementation follow-up details unless a later
endpoint contract adds dedicated vectors.

## Restart persistence gate

After an implementation restarts, these records must be recoverable without
changing public behavior:

- event graph edges and depths from `SPEC-040`
- state snapshots from `SPEC-041`
- room-version records from `SPEC-042`
- representative auth evaluation input from `SPEC-043`
- room alias mappings
- room upgrade predecessor/tombstone links

The vector compares before-restart and after-restart records by logical key.
Storage layout is implementation-owned, but the observable recovered data must
match.

## Adoption issue creation

After this spec PR is merged:

- create an `houra-server` adoption issue for alias persistence, room upgrade
  records, and restart persistence evidence across event graph, state snapshot,
  room version, alias, and upgrade records
- create an `houra-client` adoption issue only if the UI-free client core adds
  alias or upgrade request helpers from this contract
- create an `houra-labs` adoption issue only if a shared alias/URI parser or
  room-upgrade helper is intentionally adopted

Do not create implementation adoption issues before this contract is merged.

## Compatibility boundaries

- Existing `/_houra/client/**` room behavior stays available.
- Passing this contract does not claim full room directory, full room upgrade,
  federation upgrade, or Matrix v1.18 full compliance.
- Passing this contract must not widen `GET /_matrix/client/versions`
  advertisement.
