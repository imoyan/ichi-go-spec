# SPEC-116: Matrix Application Service Virtual User Directory and Device Runtime

Status: draft
Feature profile: core
Contract type: boundary
Matrix domain: Application Service API
Canonical: yes

## Purpose

Define the focused server-runtime adoption boundary promoted from the
`SPEC-075` `client-server-extension-sync-directory-device-cross-signing-breadth`
lane.

This contract lets implementation repositories adopt representative
Application Service Client-Server extension behavior for virtual-user sync,
application-service network directory visibility, and virtual-user device
metadata lifecycle without claiming full sync semantics, appservice
cross-signing bypass, complete device-management breadth, bridge protocol
operation, or Matrix v1.18 domain advertisement.

## Scope

This contract covers representative runtime behavior for Application Service
calls to these Client-Server routes:

```text
GET /_matrix/client/v3/sync
PUT /_matrix/client/v3/directory/list/appservice/{networkId}/{roomId}
PUT /_matrix/client/v3/devices/{deviceId}
DELETE /_matrix/client/v3/devices/{deviceId}
POST /_matrix/client/v3/delete_devices
```

Only these public behaviors are adopted:

- `as_token` identity assertion for a registered application service;
- `user_id` masquerading for users inside the registered `users` namespace;
- representative virtual-user sync envelope access with bounded timeout
  handling and unchanged Matrix `/versions` advertisement;
- appservice-scoped network directory visibility writes for adopted room IDs;
- virtual-user device display-name update and device deletion for devices owned
  by the asserted namespace-owned virtual user;
- virtual-user bulk device deletion for devices owned by the asserted
  namespace-owned virtual user;
- Matrix-compatible failures for unknown appservice tokens, normal user tokens
  attempting appservice-only extensions, namespace misses, malformed network
  IDs, malformed room IDs, invalid device IDs, and unsupported cross-signing
  upload attempts.

This contract does not define full sync fan-out completeness, production
long-poll behavior, legacy `/events`, invite/leave/knock sync breadth, device-list
E2EE semantics, appservice cross-signing upload, appservice-created user
provisioning, bridge protocol metadata, third-party network lookup, appservice
admin controls, or Matrix version advertisement.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/application-service-api/#client-server-api-extensions>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#syncing>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#room-directory>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#device-management>
- Parser-helper contract: `SPEC-105`
- Gap inventory: `SPEC-075`
- Checked at: 2026-05-17T10:20:00+09:00
- Timezone: Asia/Tokyo

## Runtime Behavior

Servers adopting this contract MUST treat `as_token` as an
application-service credential, not as a normal user access token. The
appservice token may assert identity only for a `user_id` inside the registered
appservice `users` namespace.

Virtual-user sync is bounded:

- requests MUST include a valid namespace-owned `user_id`;
- `timeout` MUST use the same bounded integer parsing as the adopted normal
  Client-Server sync subset;
- accepted responses MUST use a Matrix-compatible sync envelope;
- accepted responses MAY be a deterministic empty or representative sync
  envelope when no virtual-user events are available;
- adoption MUST NOT claim full sync fan-out, long-poll production semantics,
  E2EE device-list sync, invite/leave/knock breadth, `/events`, or complete
  history visibility behavior.

Appservice network directory visibility is bounded:

- requests MUST include a valid namespace-owned `user_id`;
- `networkId` MUST be a bounded opaque appservice network identifier;
- `roomId` MUST be a valid Matrix room ID;
- accepted writes MUST store or expose only the room visibility value needed by
  the representative vector;
- accepted writes MUST NOT claim third-party network protocol lookup, bridge
  metadata, remote network discovery, or full public-rooms federation behavior.

Virtual-user device lifecycle is bounded:

- requests MUST include a valid namespace-owned `user_id`;
- `deviceId` MUST be a bounded opaque Matrix device ID string;
- display-name updates MAY create or update representative metadata for the
  virtual user's device;
- device deletion MUST affect only the asserted virtual user's device;
- bulk device deletion MUST affect only listed devices owned by the asserted
  virtual user and MUST NOT delete another local user's devices;
- device lifecycle behavior MUST NOT bypass normal-user UIA, cross-user
  ownership checks, account moderation, or admin-only controls.

## Legacy Events Decision

This contract does not adopt legacy `/events` for application services.
Implementations MUST keep `/events` fail-closed unless a future contract
defines a compatibility requirement, sync-token interaction, history visibility
rules, and release evidence separate from the adopted `/sync` envelope.

## Cross-Signing Decision

This contract does not adopt
`POST /_matrix/client/v3/keys/device_signing/upload` for application services.
Implementations MUST keep appservice cross-signing upload fail-closed until a
future contract defines the security model, key ownership, device trust impact,
and Olm/Megolm boundary.

## Resource and Security Bounds

Runtime adoption is bounded:

- maximum `user_id` length: 255 bytes after UTF-8 encoding;
- maximum `deviceId` length: 255 bytes after UTF-8 encoding;
- maximum `networkId` length: 255 bytes after UTF-8 encoding;
- sync timeout maximum: the adopted normal sync timeout bound;
- raw `as_token` values in logs or evidence: forbidden;
- appservice namespace lookup: local configured registrations only;
- appservice-created user provisioning side effects: false;
- appservice cross-signing upload: false;
- bridge protocol lookup or remote connector I/O: false;
- versions advertisement widened: false.

Implementations MUST fail closed when these bounds are missing or weakened.

## Fail-Closed Behavior

Implementations must reject:

- missing appservice token on appservice-only virtual-user extension requests;
- unknown `as_token`;
- normal user bearer tokens using appservice-only `user_id` extension
  parameters;
- virtual `user_id` values outside the registered namespace;
- malformed or oversized `networkId` values;
- malformed `roomId` values on appservice directory visibility writes;
- malformed or oversized `deviceId` values;
- virtual-user device lifecycle attempts without a valid appservice
  `user_id`;
- virtual-user bulk device deletion attempts without a valid appservice
  `user_id`;
- legacy `/events` requests for application services;
- appservice cross-signing upload attempts;
- attempts to use this contract as an admin-control, bridge protocol, E2EE
  trust, or Room Version authorization bypass.

## Adoption Decision Checklist

After this contract merges:

- `houra-server#239` may adopt representative runtime behavior using this
  vector.
- `houra-server#137` remains the Application Service full-breadth owner until
  all `SPEC-075` lanes are resolved or explicitly excluded.
- Release evidence must keep `advertisement_allowed=false` for Application
  Service API until the broader `SPEC-075` lanes are resolved for the release.
- `houra-client` work should not be created for this appservice-internal
  runtime boundary unless a later user-facing appservice management surface is
  explicitly scoped.

## Compatibility Boundaries

- `SPEC-037` and `SPEC-093` remain the normal Client-Server sync boundaries.
- `SPEC-034` remains the normal user device-management boundary.
- `SPEC-048` remains the normal room directory and alias boundary.
- `SPEC-058` remains the representative Application Service registration,
  namespace, transaction, and query gate.
- `SPEC-075` remains the Application Service full-breadth gap inventory.
- `SPEC-105` remains the parser-only Application Service artifact boundary.
- `SPEC-079` remains the Olm & Megolm full-E2EE gap inventory; appservice
  device metadata adoption does not claim cross-signing or device trust.
- Passing this contract does not claim bridge protocol behavior, third-party
  network support, appservice cross-signing support, full Application Service
  API support, or Matrix v1.18 full compliance.
