# SPEC-042: Matrix Room Versions 1-12 and Default Version Gate

Status: draft
Feature profile: rooms
Canonical: yes

## Purpose

Define the Matrix v1.18 stable room-version support gate for Houra room
creation and future room-version advertisement.

This contract records the stable room-version set, the default room version for
new rooms, and the representative unsupported-version behavior required before
implementation repositories can claim room-version coverage.

## Scope

This contract is Matrix-defined, not Houra-defined. It builds on `SPEC-035`
room creation and the server/storage-facing room data model from `SPEC-040` and
`SPEC-041`.

The contract covers:

- stable room versions `1` through `12` from Matrix v1.18
- default room version `12` for new rooms
- room-version grammar and opaque identifier treatment
- `POST /_matrix/client/v3/createRoom` default room-version behavior
- `POST /_matrix/client/v3/createRoom` unsupported room-version error behavior
- room-version capability advertisement handoff to `SPEC-080`

This contract does not implement per-version auth rules, state resolution
completeness, room upgrades, federation joins, redactions, or full room-version
interoperability. Those remain separate Room Versions and Federation gates.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/rooms/>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3createroom>
- Checked at: 2026-05-10T15:15:00+09:00
- Timezone: Asia/Tokyo

## Stable room-version set

For Matrix v1.18, Houra's stable room-version gate uses this exact set:

```json
["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
```

Room versions must be treated as opaque strings, not numeric ranges. The list
above is an allowlist for this dated Matrix v1.18 snapshot. A later Matrix
release must update this contract and vectors before implementations widen the
supported set.

Unstable MSC room versions are excluded unless a later issue explicitly opts in.
This contract does not mark any v1.18 stable room version as deprecated.

## Default room version

New Matrix rooms must default to room version `12` when the client does not
provide `room_version`.

If `creation_content.room_version` is present, the server must overwrite it with
the selected room version. The selected version comes from the top-level
`room_version` request field when supported, otherwise from the server default.
The server also owns any room-version-specific create-event shape, such as room
version 12 room IDs and creator handling.

## Unsupported room versions

If `POST /_matrix/client/v3/createRoom` requests a room version outside the
stable allowlist, the representative Matrix error is:

```json
{
  "errcode": "M_UNSUPPORTED_ROOM_VERSION"
}
```

Invalid room-version grammar must not be silently coerced into a supported
version. Implementations may reject invalid grammar before support lookup, but
the public Matrix error envelope must remain `M_*` shaped.

## Advertisement rule

`GET /_matrix/client/versions` must not be used to advertise room-version
support. Matrix room-version advertisement belongs to the Client-Server
capabilities surface when that endpoint family is added. Until that later
contract exists, this repository's vectors and adoption evidence are the only
room-version support record.

`m.room_versions.default` and `m.room_versions.available` advertisement is
defined by `SPEC-080`. Stable versions without implementation evidence must not
be advertised as available merely because they are listed in this contract.

## Adoption issue creation

After this spec PR is merged:

- create an `houra-server` adoption issue for stable room-version allowlist
  handling, default room version `12`, create-room unsupported-version errors,
  room-version persistence, and no premature `/versions` advertisement
- create an `houra-client` adoption issue only if the UI-free client core begins
  exposing room-version selection or capabilities parsing from this contract
- create an `houra-labs` adoption issue only if a shared room-version grammar or
  allowlist helper is intentionally adopted

Do not create implementation adoption issues before this contract is merged.

## Compatibility boundaries

- Existing `/_houra/client/**` room creation behavior stays available.
- Passing this contract does not claim full Matrix room-version auth, state
  resolution, redaction, federation, or room-upgrade support.
- Passing this contract must not widen `GET /_matrix/client/versions`
  advertisement.
