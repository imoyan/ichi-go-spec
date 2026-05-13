# SPEC-073: Matrix Client-Server Full-Breadth Gap Inventory

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Define the current Matrix v1.18 Client-Server full-breadth gap inventory before
Houra widens any Matrix support claim beyond the adopted subset.

This contract records a fail-closed decomposition decision. It intentionally
does not add endpoint behavior, widen `GET /_matrix/client/versions`, or turn
representative Client-Server evidence into a full Matrix Client-Server API
claim.

## Scope

This contract is the bridge between the adopted Client-Server subset in
`SPEC-030` through `SPEC-039`, `SPEC-045` through `SPEC-049`, `SPEC-068`, and
`SPEC-069`, and the broader Matrix v1.18 Client-Server API.

The current release candidate keeps Client-Server API out of the advertised
Matrix support scope. Full-breadth work must be split into explicit follow-up
contracts or implementation issues before `houra-server`, `houra-client`, or
`houra-labs` can cite it as release evidence.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/>
- Checked at: 2026-05-14T07:36:37+09:00
- Timezone: Asia/Tokyo

## Current decision

Client-Server API remains excluded from the current publishable Matrix support
claim.

The current release evidence may cite adopted subset gates as representative
implementation evidence, but it must also cite `imoyan/houra-server#135` as the
open Client-Server full-breadth scope decision until all gap lanes below have
their own passing evidence or explicit release exclusion.

Servers and clients must fail closed:

- do not advertise `v1.18` or Client-Server API support from representative
  subset evidence alone;
- do not infer full Client-Server support from `SPEC-039` live e2e evidence,
  `SPEC-045` through `SPEC-049` breadth endpoints, or `SPEC-068`/`SPEC-069`
  boundary contracts;
- keep Matrix `/versions` empty for the current blocked release candidate
  unless a later release bundle shows included-domain evidence and matching
  release notes;
- keep Product MVP behavior under `/_houra/client/**` compatible unless a
  separate deprecation contract changes it.

## Covered subset

The current adopted subset is useful implementation evidence but not a full
Client-Server claim:

- `SPEC-030` through `SPEC-039`: versions, common rules, auth/session,
  registration, devices, room lifecycle/state MVP, send/messages MVP, sync MVP,
  media MVP, and live server/client MVP e2e gate.
- `SPEC-045` through `SPEC-049`: profile/account data/tags, receipts/typing/read
  markers, filters/presence/capabilities, room directory/aliases/invites, and
  moderation/reporting/admin controls.
- `SPEC-068`: OAuth-aware account-management and device-deletion redirect
  boundary.
- `SPEC-069`: device-key query-only boundary.

## Required gap lanes

Future Client-Server full-breadth work must be split into at least these lanes.
Each lane needs either a narrower spec contract with vectors, an implementation
issue with explicit non-advertisement, or both.

### Discovery, support, and policy well-known

Track client discovery and public metadata beyond the current versions gate:

- `GET /.well-known/matrix/client`
- `GET /.well-known/matrix/support`
- `GET /.well-known/matrix/policy_server`

This lane must define cache/error behavior and whether the route is served by
the homeserver, another web server, or a policy-server deployment component.

### Auth, refresh, fallback, and account lifecycle

Track auth breadth not covered by the password-session subset:

- `POST /_matrix/client/v1/login/get_token`
- `POST /_matrix/client/v3/refresh`
- fallback login and OAuth-aware compatibility behavior not already adopted by
  `SPEC-068`
- account deactivation and account-data removal semantics

This lane must preserve the bearer-token ownership and host-owned storage
boundaries already recorded for Houra clients.

### Event retrieval, membership history, and deprecated compatibility

Track historical Client-Server endpoints and event lookup breadth not covered
by MVP sync/messages:

- `GET /_matrix/client/v3/events`
- `GET /_matrix/client/v3/events/{eventId}`
- `GET /_matrix/client/v3/initialSync`
- `GET /_matrix/client/v3/rooms/{roomId}/initialSync`
- `GET /_matrix/client/v3/rooms/{roomId}/event/{eventId}`
- `GET /_matrix/client/v3/rooms/{roomId}/joined_members`
- `GET /_matrix/client/v3/rooms/{roomId}/members`
- `GET /_matrix/client/v1/rooms/{roomId}/timestamp_to_event`

Deprecated endpoints may remain unsupported, but the release evidence must say
so explicitly instead of treating them as covered by MVP sync.

### Room lifecycle, state, relations, and user-visible room breadth

Track room behavior beyond the current representative lifecycle and breadth
contracts:

- complete state event PUT/GET semantics for all adopted state event types;
- joined-room list and membership detail behavior;
- relations, edits, replies, threads, reactions, and redaction edge cases;
- room upgrade semantics outside the representative persistence gate;
- knocks, restricted joins, and invite variants if adopted for Client-Server
  release claims.

This lane overlaps Room Versions where auth/state-resolution algorithms decide
whether a request is valid.

### Sync breadth and extensions

Track `/sync` behavior beyond the MVP and endpoint-family smoke vectors:

- `full_state`, `filter`, `set_presence`, and `use_state_after` semantics;
- lazy-loading and membership-list behavior;
- invites, leaves, knocks, to-device, device lists, and E2EE sync sections;
- presence and receipt fan-out across restart and multi-device scenarios.

This lane must not claim E2EE readiness unless the relevant `SPEC-050` through
`SPEC-054` evidence passes.

### Media repository breadth

Track Matrix media behavior beyond upload/download MVP:

- `GET /_matrix/client/v1/media/config`
- `GET /_matrix/client/v1/media/preview_url`
- `GET /_matrix/client/v1/media/thumbnail/{serverName}/{mediaId}`
- `POST /_matrix/media/v1/create`
- `POST /_matrix/media/v3/upload`
- `PUT /_matrix/media/v3/upload/{serverName}/{mediaId}`
- deprecated `/_matrix/media/v3/*` compatibility and remote media behavior

This lane must align with `SPEC-071` and `SPEC-072` before Product MVP media or
encrypted attachment claims are widened.

### E2EE, keys, backup, verification, and cross-signing breadth

Track Client-Server encryption breadth beyond query-only or representative
gates:

- device key upload, one-time key upload/claim, fallback keys;
- to-device message delivery;
- encrypted room event send/receive;
- server-side key backup lifecycle and room key restore;
- SAS verification, cross-signing key upload/query, and signature upload.

This lane remains tied to `imoyan/houra-server#141` and must use a maintained
Matrix crypto stack where cryptographic behavior is required.

## Adoption decision checklist

After this contract merges:

- `houra-server#135` may cite `SPEC-073` as the Client-Server full-breadth gap
  inventory for the current blocked release candidate.
- Future `houra-server` child issues should map one gap lane to one focused
  implementation or release-scope decision.
- `houra-client` work should be created only for lanes that need client request
  descriptors, parser behavior, UI, or SDK surface.
- `houra-labs` work should be created only when a shared parser or protocol
  helper is intentionally scoped.
- Release evidence must keep `advertisement_allowed=false` for Client-Server
  API until every included lane has passing evidence or is explicitly excluded
  from that release candidate.

## Compatibility boundaries

- `SPEC-039` remains an integrated Product MVP-equivalent live e2e gate, not a
  full Client-Server conformance gate.
- `SPEC-064`, `SPEC-065`, and `SPEC-066` continue to own advertisement,
  release notes, and release-readiness decisions.
- This contract does not widen Matrix version advertisement.
- This contract does not close `imoyan/houra-spec#97`, `imoyan/houra-spec#99`,
  `imoyan/houra-server#135`, or `imoyan/houra-spec#95` by itself.
