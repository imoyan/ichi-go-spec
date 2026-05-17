# SPEC-120: Matrix Application Service CS Extension Sync, Device, and Cross-Signing Breadth

Status: draft
Feature profile: core
Contract type: boundary
Matrix domain: Application Service API
Canonical: yes

## Purpose

Define the parser-only Application Service Client-Server extension boundary for
virtual user sync, room directory listing, device creation and deletion without
UIA, and cross-signing key upload without UIA, promoted from the `SPEC-075`
`client-server-extension-sync-directory-device-cross-signing-breadth` lane.

This contract lets implementation repositories record parser-only descriptors
and policy boundaries for these surfaces without claiming runtime sync delivery
for virtual users, actual room directory update behavior, production device or
cross-signing key storage, or any widening of Matrix version advertisement.

## Scope

This contract covers the following surfaces as parser-only descriptors:

- `/sync` and `/events` use through virtual users via `as_token` and `user_id`
  assertion: descriptor shape only;
- `PUT /_matrix/client/v3/directory/list/appservice/{networkId}/{roomId}` —
  room directory listing for a third-party network: request and response parser
  shape only;
- Appservice device creation without user-interactive auth: descriptor shape;
- Appservice device deletion without user-interactive auth: descriptor shape;
- Appservice cross-signing key upload without user-interactive auth: descriptor
  shape;
- OAuth-only homeserver interaction policy: OAuth-only homeservers must still
  support `as_token` for appservice routes (non-runtime boundary);
- E2EE evidence gate linkage: appservice device and cross-signing adoption
  depends on `SPEC-050` through `SPEC-054` evidence.

This contract does not cover:

- runtime sync delivery for virtual users (requires full sync semantics from
  `SPEC-037` and `SPEC-093`);
- actual room directory update runtime behavior;
- production device or cross-signing key storage;
- E2EE key distribution, room key sessions, or Megolm encryption for virtual
  users;
- bridge protocol behaviors.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/application-service-api/#server-admin-style-permissions>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3sync>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#put_matrixclientv3directorylistappservicenetworkidroomid>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3keys_signingupload>
- Parent contracts: `SPEC-058`, `SPEC-105`, `SPEC-093`, `SPEC-050`
- Gap inventory: `SPEC-075`
- Checked at: 2026-05-17T12:00:00+09:00
- Timezone: Asia/Tokyo

## Parser-Only Descriptors

Implementations may record parser-only descriptors for the following surfaces.
None of these descriptors implies runtime execution.

**`virtual_user_sync` descriptor** — records that an `as_token` bearer with a
`user_id` query parameter may call `/sync` or `/events` as a virtual user. The
descriptor normalizes the asserted `user_id`, the `filter` shape, and the
`timeout` parameter. Runtime sync delivery for virtual users is not adopted
(gated on `SPEC-037` and `SPEC-093`).

**`room_directory_list_appservice` descriptor** — records the request shape for
`PUT /_matrix/client/v3/directory/list/appservice/{networkId}/{roomId}`. The
descriptor normalizes `networkId`, `roomId`, and the `visibility` body field
(`public` or `private`). Runtime directory update is not adopted.

**`device_create_without_uia` descriptor** — records that an appservice bearer
may create a device for a virtual user without user-interactive authentication.
The descriptor normalizes `deviceId` and the absence of a UIA challenge. No
device key generation or storage is adopted.

**`device_delete_without_uia` descriptor** — records that an appservice bearer
may delete a device for a virtual user without user-interactive authentication.
The descriptor normalizes the `deviceId` targeted for deletion and the absence
of a UIA challenge.

**`cross_signing_upload_without_uia` descriptor** — records that an appservice
bearer may upload cross-signing keys for a virtual user without user-interactive
authentication via `POST /_matrix/client/v3/keys/device_signing/upload`. The
descriptor normalizes the key upload request shape. Actual key storage and
distribution are not adopted; E2EE evidence from `SPEC-050` through `SPEC-054`
must be satisfied before runtime adoption.

## Policy Entries

**`oauth_homeserver_must_support_as_token`** — A homeserver that enforces
OAuth-only authentication for regular Matrix users must nonetheless support
`as_token`-based authentication for registered application service routes. This
is a non-runtime boundary; it expresses that the policy must be documented in
any appservice adoption and must not be silently omitted from release evidence.

## E2EE Evidence Gate

Device creation and cross-signing adoption are gated on E2EE evidence:

- `SPEC-050`, `SPEC-051`, `SPEC-052`, `SPEC-053`, and `SPEC-054` must all have
  passing representative evidence before any device-creation or cross-signing
  runtime adoption issue may be opened for virtual users.
- Parser-only descriptors in this contract may be recorded before E2EE evidence
  is complete, but adopted_runtime_behavior remains false for all device and
  cross-signing surfaces until the gate is satisfied.

## Fail-Closed Behavior

Implementations must fail closed:

- do not adopt runtime virtual user sync from this contract; runtime sync
  requires `SPEC-037` and `SPEC-093` evidence;
- do not adopt runtime room directory update from this contract;
- do not generate or store device keys or cross-signing keys from parser-only
  descriptors;
- reject device creation or cross-signing upload attempts for virtual users
  before E2EE evidence is satisfied;
- do not advertise Application Service API, full Client-Server API, or E2EE
  device support from parser-only evidence in this contract;
- do not widen `GET /_matrix/client/versions`.

## Adoption Decision Checklist

After this contract merges:

- `houra-labs#135` may record parser-only descriptors for the adopted surfaces
  using this vector.
- `houra-server` runtime adoption of virtual user sync requires a separate issue
  gated on `SPEC-037` and `SPEC-093` evidence.
- `houra-server` runtime adoption of device creation or cross-signing for
  virtual users requires a separate issue gated on `SPEC-050` through
  `SPEC-054` evidence.
- Release evidence must keep `advertisement_allowed=false` for the Application
  Service API until all `SPEC-075` lanes are resolved.

## Compatibility Boundaries

- `SPEC-058` remains the representative registration, namespace, transaction,
  and query gate.
- `SPEC-105` remains the parser-only artifact breadth gate for the full
  Application Service surface.
- `SPEC-093` and `SPEC-037` remain the sync runtime gates; virtual user sync
  adoption must not be claimed from this contract.
- `SPEC-050` through `SPEC-054` remain the E2EE evidence gates required before
  device or cross-signing runtime adoption.
- `SPEC-119` owns the masquerade identity assertion and namespace admin policy
  lane.
- `SPEC-075` remains the Application Service full-breadth gap inventory.
- Passing this contract does not claim runtime sync for virtual users, actual
  room directory management, production device key storage, cross-signing
  correctness, E2EE for virtual users, bridge runtime support, or Matrix v1.18
  full compliance.
