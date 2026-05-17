# Matrix v1.18 / Server-Server API / federation ACL, policy, and signing runtime

Status: draft
Feature profile: core
Contract type: boundary
Matrix domain: Server-Server API
Primary reference: Matrix v1.18 / Server-Server API / federation ACL, policy, and signing runtime
Repository anchor: SPEC-110 Matrix Federation ACL, Policy, and Signing Runtime
Canonical: yes

## Purpose

Define the focused server-runtime adoption boundary promoted from the
`SPEC-074` `server-acl-policy-server-event-signing-breadth` lane after
`SPEC-103` established parser/helper descriptors for event hash and signature
inputs.

This contract lets implementation repositories adopt representative
fail-closed behavior for federation Server ACL enforcement, policy-server
signing, and bounded public event hash/signature validation without claiming a
production policy server deployment, full room-version event authorization,
remote key lookup, complete event signature verification, or full
Server-Server API support.

## Scope

This contract covers representative runtime behavior for:

```text
GET  /_matrix/federation/v1/event/{eventId}
POST /_matrix/policy/v1/sign
```

Only these public behaviors are adopted:

- protected federation event retrieval guarded by X-Matrix request
  authorization and a representative Server ACL decision;
- Matrix-compatible forbidden errors for ACL-denied federation origins;
- event envelope hash/signature material checks for returned local events;
- policy-signing request validation and a deterministic representative
  signature envelope;
- fail-closed policy-signing failures for malformed payloads, unsupported
  rooms, and invalid hash/signature material.

This contract does not define complete policy server discovery, complete room
policy state evaluation, production signing-key storage, remote key lookup,
canonical JSON cryptographic signing, complete event hash calculation, complete
event signature verification, room-version auth correctness, outbound policy
server calls, or Matrix version advertisement.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/server-server-api/#server-access-control-lists-acls-for-rooms>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#get_matrixfederationv1eventeventid>
- Source: <https://spec.matrix.org/v1.18/policy-servers/>
- Source: <https://spec.matrix.org/v1.18/rooms/v12/#event-format>
- Parser/helper contract: `SPEC-103`
- Gap inventory: `SPEC-074`
- Checked at: 2026-05-16T21:25:00+09:00
- Timezone: Asia/Tokyo

## Runtime Behavior

Servers adopting this contract MUST enforce request authorization and a bounded
Server ACL decision before serving the representative federation event.

Federation event retrieval responses MUST preserve:

- `event_id`, `type`, `room_id`, `sender`, `origin_server_ts`, and `depth`;
- `prev_events` and `auth_events`;
- public `content`;
- `hashes.sha256`;
- server signature material using an `ed25519:*` key ID.

Policy signing responses MUST preserve:

- `room_id`;
- `policy_id`;
- `policy_signature`;
- a signed event envelope with `hashes` and `signatures`;
- no private key, raw signing secret, local filesystem path, or unredacted
  secret material.

## Resource Bounds

Runtime adoption is bounded:

- maximum ACL allow entries: 20;
- maximum ACL deny entries: 20;
- maximum policy-signing payload bytes: 65536;
- maximum signature servers per event: 8;
- maximum signing keys per server: 8;
- request authorization required: true;
- ACL fail-closed on denied origin: true;
- policy server deployed: false;
- outbound policy server calls: false;
- production signing-key storage: false;
- complete room policy state evaluation: false;
- cryptographic hash calculation claimed: false;
- cryptographic signature verification claimed: false;
- versions advertisement widened: false.

Implementations MUST fail closed when these bounds are missing or weakened.

## Fail-Closed Behavior

Implementations must reject:

- missing or invalid federation request authorization;
- ACL-denied federation origins;
- invalid or unknown federation event IDs;
- events missing `hashes.sha256`;
- events missing non-empty `signatures`;
- signature key IDs that are not `ed25519:*`;
- policy-signing bodies that are not JSON objects;
- policy-signing bodies missing `room_id`, `policy_id`, or `event`;
- policy-signing requests for unsupported rooms;
- policy-signing event envelopes with missing hash/signature material.

## Adoption Decision Checklist

After this contract merges:

- `houra-server#234` may adopt representative runtime behavior using this
  vector.
- `houra-server#140`, `houra-server#168`, and `houra-server#169` remain the
  owners for full room-version auth, state resolution, event format, and
  production hash/signature correctness.
- Policy server production deployment remains excluded until a dedicated
  policy-server adoption issue supplies discovery, key storage, policy state,
  and operational evidence.
- Release evidence must keep `advertisement_allowed=false` for Server-Server
  API until the broader `SPEC-074` lanes are resolved for the release.

## Compatibility Boundaries

- `SPEC-057` remains the representative event-auth and state interop contract.
- `SPEC-074` remains the Server-Server full-breadth gap inventory.
- `SPEC-083`, `SPEC-084`, `SPEC-101`, `SPEC-103`, and `SPEC-104` own
  room-version event decision, cross-domain validation, auth-rule fixture,
  event format/hash/signature helper, and state-resolution evidence.
- Passing this contract does not claim production policy server support,
  complete ACL policy correctness, complete event signing correctness,
  Complement full-breadth, or Matrix v1.18 full compliance.
