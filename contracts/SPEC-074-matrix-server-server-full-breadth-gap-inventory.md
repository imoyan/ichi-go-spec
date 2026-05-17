# Matrix v1.18 / Server-Server API / full-breadth gap inventory

Status: draft
Feature profile: core
Contract type: gap-inventory
Matrix domain: Server-Server API
Primary reference: Matrix v1.18 / Server-Server API / full-breadth gap inventory
Repository anchor: SPEC-074 Matrix Server-Server Full-Breadth Gap Inventory
Canonical: yes

## Purpose

Define the current Matrix v1.18 Server-Server full-breadth gap inventory before
Houra widens any federation or Complement-based Matrix support claim beyond
the adopted representative subset.

This contract records a fail-closed decomposition decision. It intentionally
does not add federation endpoint behavior, mark Complement full-breadth as
passing, widen `GET /_matrix/client/versions`, or turn representative
federation smoke evidence into a full Matrix federation claim.

## Scope

This contract is the bridge between the adopted Server-Server subset in
`SPEC-055`, `SPEC-056`, `SPEC-057`, `SPEC-061`, and the broader Matrix v1.18
Server-Server API.

The current release candidate keeps Server-Server API out of the advertised
Matrix support scope. Full federation work must be split into explicit
follow-up contracts or implementation issues before `houra-server` can cite it
as release evidence.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/server-server-api/>
- Checked at: 2026-05-14T07:36:37+09:00
- Timezone: Asia/Tokyo

## Current decision

Server-Server API remains excluded from the current publishable Matrix support
claim.

The current release evidence may cite `SPEC-061` interop smoke and the
`SPEC-055` through `SPEC-057` representative gates as implementation evidence,
but it must also cite `imoyan/houra-server#136` as the open Server-Server
full-breadth scope decision until all gap lanes below have their own passing
evidence or explicit release exclusion.

Servers must fail closed:

- do not advertise Server-Server API or full federation support from
  representative discovery, transaction, join/invite, backfill, or state
  vectors alone;
- keep Complement full-breadth failure issue refs open while unsupported
  federation breadth remains excluded;
- keep Matrix `/versions` empty for the current blocked release candidate
  unless a later release bundle shows included-domain evidence and matching
  release notes;
- keep unsafe federation destination controls from `SPEC-055` intact for every
  follow-up lane that performs outbound federation requests.

## Covered subset

The current adopted subset is useful implementation evidence but not a full
Server-Server claim:

- `SPEC-055`: server discovery, delegated well-known handling, signing-key
  publication/query, destination resolution failure, and outbound destination
  controls.
- `SPEC-056`: transaction send/receive, representative PDU/EDU delivery,
  make/send join, and v2 invite signing.
- `SPEC-057`: representative backfill, event_auth, state_ids, and
  cross-server state-resolution interop.
- `SPEC-061`: two-Houra homeserver smoke, reference-homeserver smoke checklist,
  and Docker Compose or Complement-compatible federation smoke evidence.

## Required gap lanes

Future Server-Server full-breadth work must be split into at least these lanes.
Each lane needs either a narrower spec contract with vectors, an implementation
issue with explicit non-advertisement, or both.

### Federation discovery, version, key lifecycle, and request auth breadth

Track server metadata, key, TLS, and request-auth behavior beyond the current
discovery/signing-key subset:

- `GET /_matrix/federation/v1/version`
- complete key query/notary behavior for `/_matrix/key/v2/query`
- key rotation, old key validity, cache expiry, and multiple verify keys
- request and response authentication edge cases
- TLS/SNI, unsupported endpoint, unsupported method, and JSON content handling

This lane must preserve SSRF and unsafe outbound destination controls.

### Transaction, PDU, EDU, and event validation breadth

Track federation transaction processing beyond the representative send/join
contract:

- full `PUT /_matrix/federation/v1/send/{txnId}` idempotency, retry, and
  per-PDU response semantics;
- PDU auth checks, rejection, soft failure, event hash validation, and signature
  validation;
- EDU breadth including typing, receipts, presence, device list updates, and
  to-device behavior;
- transaction ordering, duplicate detection, and partial failure artifacts.

This lane overlaps Room Versions where auth/state-resolution algorithms decide
whether a received PDU is valid.

### Event retrieval, missing events, backfill, and state response breadth

Track historical event and state recovery beyond the representative
`SPEC-057` vectors:

- `GET /_matrix/federation/v1/event/{eventId}`
- `POST /_matrix/federation/v1/get_missing_events/{roomId}`
- complete `GET /_matrix/federation/v1/backfill/{roomId}` behavior
- complete `GET /_matrix/federation/v1/state/{roomId}` response bodies
- `GET /_matrix/federation/v1/state_ids/{roomId}`
- `GET /_matrix/federation/v1/timestamp_to_event/{roomId}`

This lane must define redaction, visibility, auth-chain, and state-set recovery
behavior across restart and partial history.

### Join, knock, leave, invite, and third-party invite breadth

Track membership handshakes beyond representative join and v2 invite:

- restricted joins and join rule variants;
- `GET /_matrix/federation/v1/make_knock/{roomId}/{userId}`
- `PUT /_matrix/federation/v1/send_knock/{roomId}/{eventId}`
- `GET /_matrix/federation/v1/make_leave/{roomId}/{userId}`
- `PUT /_matrix/federation/v2/send_leave/{roomId}/{eventId}`
- `PUT /_matrix/federation/v1/3pid/onbind`
- `PUT /_matrix/federation/v1/exchange_third_party_invite/{roomId}`

This lane must include auth-event selection, stripped-state validation, and
signature validation for remote membership changes.

### Directory, spaces, query, OpenID, and profile breadth

Track federation queries and discovery surfaces outside the current
representative room handshakes:

- `GET /_matrix/federation/v1/publicRooms`
- `POST /_matrix/federation/v1/publicRooms`
- `GET /_matrix/federation/v1/hierarchy/{roomId}`
- `GET /_matrix/federation/v1/query/directory`
- `GET /_matrix/federation/v1/query/profile`
- `GET /_matrix/federation/v1/query/{queryType}`
- `GET /_matrix/federation/v1/openid/userinfo`

This lane must define privacy, rate-limit, and remote-query failure behavior.

### Federation E2EE, device, send-to-device, and media breadth

Track federation-adjacent E2EE and media behavior beyond local Client-Server
representative gates:

- `GET /_matrix/federation/v1/user/devices/{userId}`
- `POST /_matrix/federation/v1/user/keys/claim`
- `POST /_matrix/federation/v1/user/keys/query`
- federation send-to-device delivery
- `GET /_matrix/federation/v1/media/download/{mediaId}`
- `GET /_matrix/federation/v1/media/thumbnail/{mediaId}`

This lane remains tied to `imoyan/houra-server#141` and must not claim E2EE
readiness unless the relevant `SPEC-050` through `SPEC-054` evidence passes.

### Server ACL, policy server, and event signing breadth

Track federation policy and event-signing behavior added or emphasized by
v1.18:

- Server ACL enforcement on protected federation endpoints;
- policy-server discovery and room policy state integration;
- `POST /_matrix/policy/v1/sign`;
- event hash/signature calculation and validation;
- policy-server signature validation and failure artifacts.

This lane must preserve fail-closed behavior for unsupported policy-server
deployments.

### Complement full-breadth and reference interop breadth

Track the runnable federation conformance breadth:

- Complement stable-spec-only pass/fail reports;
- reference homeserver interop artifacts;
- failure issue refs for unsupported federation tests;
- secret and local-path redaction in federation artifacts;
- release-bundle linkage to `SPEC-063`, `SPEC-064`, `SPEC-065`, and
  `SPEC-066`.

This lane is the place to close the `complement-breadth/full-server-server-api`
gap when every included federation behavior either passes or is explicitly
excluded for the release candidate.

## Adoption decision checklist

After this contract merges:

- `houra-server#136` may cite `SPEC-074` as the Server-Server full-breadth gap
  inventory for the current blocked release candidate.
- Future `houra-server` child issues should map one gap lane to one focused
  implementation or release-scope decision.
- `houra-client` work should not be created for federation internals unless a
  later client-visible surface is explicitly scoped.
- `houra-labs` work should be created only when a shared parser, event
  validator, or room-version helper is intentionally scoped.
- Release evidence must keep `advertisement_allowed=false` for Server-Server
  API until every included lane has passing evidence or is explicitly excluded
  from that release candidate.

## Compatibility boundaries

- `SPEC-061` remains a federation smoke gate, not a full Complement or full
  Server-Server conformance gate.
- `SPEC-063` owns the Complement-compatible CI lane shape and failure issue
  linkage.
- `SPEC-064`, `SPEC-065`, and `SPEC-066` continue to own advertisement,
  release notes, and release-readiness decisions.
- This contract does not widen Matrix version advertisement.
- This contract does not close `imoyan/houra-server#136` or
  `imoyan/houra-spec#95` by itself.
