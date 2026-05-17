# SPEC-080: Matrix Room Versions Capabilities Advertisement Boundary

Status: draft
Feature profile: rooms
Contract type: boundary
Matrix domain: Room Versions
Canonical: yes

## Purpose

Define the child advertisement boundary for Matrix `m.room_versions.default`
and `m.room_versions.available` after `SPEC-078`.

This contract prevents the representative Room Versions subset from expanding
into a full Room Versions support claim through the Client-Server capabilities
surface. It is a fail-closed contract: implementations advertise only room
versions with current implementation evidence and do not infer availability
from the stable Matrix v1.18 version list.

## Scope

This contract covers only the `m.room_versions` capability inside:

```text
GET /_matrix/client/v3/capabilities
```

It is a child of `SPEC-078` and narrows the advertisement rule from `SPEC-042`
and `SPEC-047`. It does not define complete room-version algorithms, event
authorization, state resolution, federation, room upgrade breadth, or Matrix
version advertisement through `GET /_matrix/client/versions`.

The current representative subset may advertise room version `12` only when the
server has passing implementation evidence for the `SPEC-042` default version
and the `SPEC-043` representative room version 12 auth vectors. Stable room
versions `1` through `11` remain valid Matrix v1.18 identifiers, but they must
not appear in `m.room_versions.available` until each advertised version has
explicit passing evidence for the release being built.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3capabilities>
- Source: <https://spec.matrix.org/v1.18/rooms/>
- Source: <https://spec.matrix.org/v1.18/rooms/v12/>
- Checked at: 2026-05-14T09:08:00+09:00
- Timezone: Asia/Tokyo

## Advertisement rule

The capabilities response may include:

```json
{
  "capabilities": {
    "m.room_versions": {
      "default": "12",
      "available": {
        "12": "stable"
      }
    }
  }
}
```

The `default` value must be a key in `available`. The status value for a stable
Matrix room version is `stable`.

The current boundary intentionally does not list room versions `1` through `11`.
Those versions are part of the Matrix v1.18 stable set in `SPEC-042`, but
listing a version in `SPEC-042` is not enough to advertise it as available.
`m.room_versions.available` is an implementation-evidence boundary, not a copy
of the stable-version registry.

## Fail-closed behavior

Implementations must fail closed:

- do not advertise room versions `1` through `11` from the stable registry
  alone;
- do not advertise full Room Versions support from representative room version
  12 auth or state-resolution vectors;
- do not widen `GET /_matrix/client/versions` from this capabilities contract;
- remove a room version from `available` when its current implementation
  evidence is missing, stale, failed, or outside the release scope;
- keep `SPEC-078` as the parent full-algorithm gap inventory until every
  included Room Versions lane has passing evidence or an explicit release
  exclusion.

## Adoption decision checklist

After this contract merges:

- `houra-server` should treat `m.room_versions.available` as a release-time
  evidence list, not a static stable-version registry.
- `houra-client` may parse `m.room_versions.default` and `available`, but must
  not treat missing stable versions as client defects.
- `houra-labs` work should be created only if a shared capabilities parser or
  room-version advertisement validator is intentionally adopted.

## Compatibility boundaries

- `SPEC-042` remains the stable room-version set and default-version gate.
- `SPEC-043` remains representative room version 12 authorization evidence.
- `SPEC-047` remains the broader filters, presence, and capabilities endpoint
  family, but its representative capabilities vector must follow this boundary.
- Passing this contract does not claim full room-version algorithms, complete
  auth/state-resolution coverage, federation breadth, or Matrix v1.18 full
  compliance.
