# SPEC-078: Matrix Room Versions Full Algorithm Gap Inventory

Status: draft
Feature profile: rooms
Canonical: yes

## Purpose

Define the current Matrix v1.18 Room Versions full-algorithm gap inventory
before Houra widens any room-version, event authorization, state resolution,
room upgrade, or room-version advertisement claim beyond the adopted
representative subset.

This contract records a fail-closed decomposition decision. It intentionally
does not add full room-version algorithms, advertise every stable room version
as available, widen `GET /_matrix/client/versions`, or turn representative room
version 12 vectors into a domain-wide Room Versions claim.

## Scope

This contract is the bridge between the adopted Room Versions subset in
`SPEC-040`, `SPEC-041`, `SPEC-042`, `SPEC-043`, and `SPEC-044` and the broader
Matrix v1.18 Room Versions domain.

The current release candidate keeps Room Versions out of the advertised Matrix
support scope. Full room-version work must be split into explicit follow-up
contracts or implementation issues before `houra-server` can cite it as release
evidence.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/rooms/>
- Source: <https://spec.matrix.org/v1.18/rooms/v12/>
- Checked at: 2026-05-14T08:32:10+09:00
- Timezone: Asia/Tokyo

## Current decision

Room Versions remains excluded from the current publishable Matrix support
claim.

The current release evidence may cite `SPEC-040` through `SPEC-044` as
representative event DAG, state snapshot, stable version allowlist, room version
12 auth, alias, upgrade, and restart-persistence evidence, but it must also
cite `imoyan/houra-server#140` as the open Room Versions full-algorithm scope
decision until all gap lanes below have their own passing evidence or explicit
release exclusion.

Servers must fail closed:

- do not advertise domain-wide Room Versions support from representative event
  graph, state resolution, room-version allowlist, room version 12 auth, alias,
  or upgrade vectors alone;
- keep `houra-server#140` open while unsupported room-version algorithm breadth
  remains excluded from the release candidate;
- keep Matrix `/versions` empty for the current blocked release candidate
  unless a later release bundle shows included-domain evidence and matching
  release notes;
- keep capabilities room-version advertisement constrained to versions with
  passing implementation evidence.

## Covered subset

The current adopted subset is useful implementation evidence but not a full Room
Versions claim:

- `SPEC-040`: persisted Matrix event DAG and auth-event references.
- `SPEC-041`: state snapshots and representative state-resolution vectors.
- `SPEC-042`: Matrix v1.18 stable room-version set, default room version `12`,
  and create-room unsupported-version behavior.
- `SPEC-043`: representative room version 12 membership, power-level, and
  redaction authorization vectors.
- `SPEC-044`: representative room alias, room upgrade, and restart-persistence
  gate.

## Required gap lanes

Future Room Versions full-algorithm work must be split into at least these
lanes. Each lane needs either a narrower spec contract with vectors, an
implementation issue with explicit non-advertisement, or both.

### Stable version set, grammar, default, and capabilities breadth

Track support metadata and advertisement behavior beyond the stable allowlist:

- stable versions `1` through `12` from the dated Matrix v1.18 snapshot;
- room-version grammar, opaque identifier treatment, reserved identifiers, and
  unstable version exclusion;
- default room version `12`;
- create-room `room_version` validation and `M_UNSUPPORTED_ROOM_VERSION`;
- Client-Server capabilities `m.room_versions.default` and
  `m.room_versions.available` advertisement only for versions with evidence.

### Per-version event format, ID, hash, signature, and limit breadth

Track event format differences across stable room versions:

- event ID and room ID formats across versions, including room version 12 room
  IDs as hashes of create events;
- `auth_events`, `prev_events`, depth, hash, signature, unsigned, and content
  shape differences;
- canonical JSON, event hash, signing-key validity, reference hashes, and event
  size limits;
- version-specific redacted event content retention.

### Authorization rules breadth

Track complete room-version authorization behavior beyond representative
vectors:

- create, member, join rules, power levels, third-party invite, redaction, and
  generic state-event auth rules;
- knocking, restricted joins, `knock_restricted`, additional room creators, and
  creator infinite power in room version 12;
- auth event selection, duplicate auth event rejection, rejected-auth-event
  handling, `m.federate=false`, and server signature checks;
- allow/deny evidence for each supported room version.

### State resolution algorithm breadth

Track complete state-resolution algorithms beyond representative vectors:

- state resolution version 1 and version 2 behavior where applicable;
- unconflicted state map, conflicted state set, auth chain, power events,
  mainline ordering, and iterative auth checks;
- rejected events, soft-failed events, partial history, restart recovery, and
  performance bounds for conflicted state;
- parity vectors for every supported room version.

### Event acceptance, rejection, soft-fail, and visibility breadth

Track runtime event decision behavior tied to room versions:

- PDU receipt checks, event auth result, rejected event storage, soft-fail
  handling, and redaction application;
- timeline visibility, auth-chain visibility, state-at-event, backfill, and
  get-missing-events behavior;
- local Client-Server send decisions and remote Server-Server receive decisions;
- artifacts that record accepted, rejected, soft-failed, and redacted outcomes.

### Room upgrade and migration breadth

Track room-version changes beyond the representative upgrade vector:

- `POST /_matrix/client/v3/rooms/{roomId}/upgrade`;
- tombstone events, predecessor links, alias transfer, room directory
  visibility transfer, power-level copy, invite/member migration, and partial
  failure behavior;
- upgrade from and to each supported stable version, including downgrade-like
  moves where Matrix permits opaque room versions;
- restart recovery of upgrade records.

### Federation and cross-domain room-version breadth

Track room-version behavior that crosses into Server-Server API:

- make/send join, invite, knock, leave, backfill, event_auth, state/state_ids,
  timestamp lookup, and missing events with version-specific auth;
- room-version-aware event validation for federation transactions;
- signature, hash, event ID, room ID, and auth-chain behavior in remote PDUs;
- linkage to `SPEC-055`, `SPEC-056`, `SPEC-057`, `SPEC-061`, and `SPEC-074`.

### Shared parser, helper, and test-harness breadth

Track reusable implementation support:

- room-version grammar and allowlist helpers;
- event format parser, canonical JSON helper, hash/signature helper, auth-rule
  fixture runner, and state-resolution fixture runner;
- labs/shared-core adoption boundaries and performance gates;
- clean-room evidence that helpers are derived from this repository's contracts
  and Matrix specification snapshots, not existing implementation code.

### Release evidence and non-advertisement breadth

Track release-bundle linkage for Room Versions:

- release evidence linkage to `SPEC-062`, `SPEC-064`, `SPEC-065`, and
  `SPEC-066`;
- included-domain pass/fail artifacts for every supported room-version lane;
- explicit release-note exclusions for full algorithms, unsupported stable
  versions, federation version breadth, and helper/test-harness gaps;
- proof that representative `SPEC-040` through `SPEC-044` evidence does not
  widen Matrix version or domain advertisement.

## Adoption decision checklist

After this contract merges:

- `houra-server#140` may cite `SPEC-078` as the Room Versions full-algorithm
  gap inventory for the current blocked release candidate.
- Future `houra-server` child issues should map one gap lane to one focused
  implementation or release-scope decision.
- `houra-client` work should be created only when capabilities parsing,
  room-version selection, upgrade UI, or user-visible room-version behavior is
  explicitly scoped.
- `houra-labs` work should be created only when parser, canonical JSON,
  hash/signature, auth-rule, or state-resolution helpers are intentionally
  scoped.
- Release evidence must keep `advertisement_allowed=false` for Room Versions
  until every included lane has passing evidence or is explicitly excluded from
  that release candidate.

## Compatibility boundaries

- `SPEC-040` through `SPEC-044` remain representative Room Versions gates, not
  full room-version algorithm, federation, upgrade, or advertisement gates.
- Room Versions support remains separate from Client-Server endpoint breadth,
  Server-Server federation breadth, Application Service, Push Gateway, and Olm
  & Megolm unless a later contract explicitly links the domains.
