# Matrix v1.18 / Server-Server API / federation E2EE device and media runtime

Status: draft
Feature profile: core
Contract type: boundary
Matrix domain: Server-Server API
Primary reference: Matrix v1.18 / Server-Server API / federation E2EE device and media runtime
Repository anchor: SPEC-109 Matrix Federation E2EE Device and Media Runtime
Canonical: yes

## Purpose

Define the focused server-runtime adoption boundary promoted from the
`SPEC-074` `federation-e2ee-device-send-to-device-media-breadth` lane after
`SPEC-102` established parser-only E2EE artifacts.

This contract lets implementation repositories adopt representative runtime
behavior for federation device list, key query, key claim, opaque to-device
delivery, and bounded local media download without claiming Olm/Megolm crypto,
remote media fetch, encrypted attachment decryption, complete device-list
fanout, or full Server-Server API support.

## Scope

This contract covers representative runtime behavior for:

```text
GET  /_matrix/federation/v1/user/devices/{userId}
POST /_matrix/federation/v1/user/keys/query
POST /_matrix/federation/v1/user/keys/claim
PUT  /_matrix/federation/v1/sendToDevice/{eventType}/{txnId}
GET  /_matrix/federation/v1/media/download/{mediaId}
GET  /_matrix/federation/v1/media/thumbnail/{mediaId}
```

Only these public behaviors are adopted:

- local device list responses for known local Matrix users;
- local device-key query responses with cross-signing public key fields when
  available;
- local one-time-key claim responses for known devices and algorithms;
- opaque federated to-device payload acceptance for encrypted event content;
- local media download for representative in-repository media metadata;
- fail-closed thumbnail and missing-media responses.

This contract does not define local Olm/Megolm primitives, client-side crypto
state, device-list fanout correctness, remote federation fanout, remote media
fetch, media cache persistence, encrypted attachment decryption, thumbnail
generation, range requests, malware scanning, rate limiting, or Matrix version
advertisement.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/server-server-api/#device-management>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#end-to-end-encryption>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#put_matrixfederationv1sendtodeviceeventtypetxnid>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#get_matrixfederationv1mediadownloadmediaid>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#get_matrixfederationv1mediathumbnailmediaid>
- Parser artifact contract: `SPEC-102`
- Gap inventory: `SPEC-074`
- Checked at: 2026-05-16T21:50:00+09:00
- Timezone: Asia/Tokyo

## Runtime Behavior

Servers adopting this contract MUST serve the representative endpoint family
from local in-memory or persisted server state without making remote network
requests.

Device list responses MUST preserve:

- `user_id`;
- `stream_id`;
- `devices` entries with `device_id`, optional `display_name`, and public
  `keys` metadata when available.

Key query responses MUST preserve:

- `failures`;
- `device_keys` grouped by user ID and device ID;
- optional `master_keys`, `self_signing_keys`, and `user_signing_keys` fields
  when local public cross-signing keys are available.

Key claim responses MUST preserve:

- `failures`;
- `one_time_keys` grouped by user ID, device ID, and key ID;
- omission for unknown users, unknown devices, or unavailable algorithms.

Federated to-device responses MUST preserve:

- acceptance of opaque `m.room.encrypted` payloads with object message maps;
- idempotent response shape for a representative transaction ID;
- no local crypto, decryption, trust decision, or outbound fanout claim.

Media responses MUST preserve:

- local media download status, content type, and content disposition for the
  representative media ID;
- Matrix-compatible not-found failure for missing media;
- fail-closed thumbnail behavior when thumbnail generation is not implemented.

## Resource Bounds

Runtime adoption is bounded:

- maximum device count per user: 50;
- maximum queried user count: 20;
- maximum queried device count per user: 50;
- maximum claimed user count: 20;
- maximum claimed device count per user: 50;
- maximum to-device recipient users: 20;
- maximum to-device recipient devices per user: 50;
- maximum local media response bytes: 10485760;
- remote network fetch: false;
- Olm/Megolm primitive implementation: false;
- encrypted attachment decryption: false;
- thumbnail generation required: false;
- cache persistence: false;
- versions advertisement widened: false.

Implementations MUST fail closed when these bounds are missing or weakened.

## Fail-Closed Behavior

Implementations must reject:

- federation requests with missing or invalid request authorization;
- device list requests for invalid or unknown Matrix user IDs;
- key query bodies that are not objects or have invalid `device_keys`;
- key claim bodies that are not objects or have invalid `one_time_keys`;
- to-device requests with invalid event types, empty transaction IDs, or
  malformed message maps;
- media download requests for unknown media IDs;
- thumbnail requests when thumbnail generation is not implemented;
- any implementation path that would fetch remote media or decrypt encrypted
  attachment content.

## Adoption Decision Checklist

After this contract merges:

- `houra-server#233` may adopt representative runtime behavior using this
  vector.
- `houra-server#141` remains the owner for Olm/Megolm full E2EE breadth.
- `houra-server#160` remains the owner for remaining federation media breadth
  and remote media behavior.
- Release evidence must keep `advertisement_allowed=false` for Server-Server
  API and E2EE until the broader `SPEC-074` and `SPEC-079` lanes are resolved
  for the release.

## Compatibility Boundaries

- `SPEC-051` remains the Client-Server device/one-time/fallback key contract.
- `SPEC-052` remains the Client-Server to-device and encrypted-room gate.
- `SPEC-072` remains the Product MVP encrypted media attachment boundary.
- `SPEC-079` remains the full Olm & Megolm gap inventory.
- `SPEC-095` remains the media repository breadth parser boundary.
- `SPEC-102` remains the parser-only E2EE artifact breadth boundary.
- Passing this contract does not claim local E2EE support, remote media
  federation, encrypted media decryption, Complement full-breadth, or Matrix
  v1.18 full compliance.
