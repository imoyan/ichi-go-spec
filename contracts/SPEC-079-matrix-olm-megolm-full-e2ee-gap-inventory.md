# SPEC-079: Matrix Olm and Megolm Full E2EE Gap Inventory

Status: draft
Feature profile: messaging
Contract type: gap-inventory
Matrix domain: Olm & Megolm
Canonical: yes

## Purpose

Define the current Matrix v1.18 Olm & Megolm full E2EE gap inventory before
Houra widens any encrypted-room, device trust, key backup, verification,
cross-signing, secret storage, or local-crypto support claim beyond the adopted
representative boundary subset.

This contract records a fail-closed decomposition decision. It intentionally
does not add cryptographic behavior, select a production crypto stack, move
local Olm/Megolm state into the server, widen `GET /_matrix/client/versions`,
or turn representative E2EE endpoint evidence into a full E2EE claim.

## Scope

This contract is the bridge between the adopted E2EE subset in `SPEC-050`,
`SPEC-051`, `SPEC-052`, `SPEC-053`, `SPEC-054`, `SPEC-069`, and `SPEC-072`,
and the broader Matrix v1.18 Olm & Megolm domain.

The current release candidate keeps Olm & Megolm out of the advertised Matrix
support scope. Full E2EE work must be split into explicit follow-up contracts
or implementation issues before `houra-server` can cite it as release evidence.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/olm-megolm/>
- Source: <https://spec.matrix.org/v1.18/olm-megolm/olm/>
- Source: <https://spec.matrix.org/v1.18/olm-megolm/megolm/>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#end-to-end-encryption>
- Checked at: 2026-05-14T08:50:23+09:00
- Timezone: Asia/Tokyo

## Current decision

Olm & Megolm remains excluded from the current publishable Matrix support
claim.

The current release evidence may cite `SPEC-050` through `SPEC-054`,
`SPEC-069`, and `SPEC-072` as representative crypto-adapter, key endpoint,
to-device, encrypted-room, key-backup, verification, cross-signing,
device-key-query, and encrypted-media boundary evidence, but it must also cite
`imoyan/houra-server#141` as the open Olm & Megolm full E2EE scope decision
until all gap lanes below have their own passing evidence or explicit release
exclusion.

Systems must fail closed:

- do not advertise full E2EE, encrypted-room, key backup, verification,
  cross-signing, secret-storage, or local Olm/Megolm support from
  representative endpoint and boundary vectors alone;
- keep `houra-server#141` open while unsupported E2EE breadth remains excluded
  from the release candidate;
- keep Matrix `/versions` empty for the current blocked release candidate
  unless a later release bundle shows included-domain evidence and matching
  release notes;
- keep private keys, recovery keys, backup secrets, plaintext, session keys,
  device trust decisions, and platform secure-storage state out of server-owned
  evidence artifacts.

## Covered subset

The current adopted subset is useful implementation evidence but not a full E2EE
claim:

- `SPEC-050`: maintained Matrix crypto stack requirement and local
  Olm/Megolm/SAS/cross-signing/key-backup crypto prohibition.
- `SPEC-051`: device key, one-time key, and fallback key upload/claim endpoint
  family.
- `SPEC-052`: to-device delivery and encrypted-room envelope send/receive gate.
- `SPEC-053`: server-side key backup version lifecycle, opaque backup payload,
  restore, wrong-version, and logout/relogin recovery gate.
- `SPEC-054`: verification, cross-signing public key/signature, invalid
  signature, and wrong-device failure gate.
- `SPEC-069`: device-key query-only parser and request/response boundary.
- `SPEC-072`: Product MVP encrypted media attachment fail-closed boundary.

## Required gap lanes

Future Olm & Megolm full E2EE work must be split into at least these lanes. Each
lane needs either a narrower spec contract with vectors, an implementation issue
with explicit non-advertisement, or both.

### Maintained crypto stack and local state ownership breadth

Track crypto-stack selection and host-owned state boundaries:

- maintained Matrix crypto stack package, version, license, maintenance, and
  security update evidence;
- runtime/platform support for server, clients, and test harnesses;
- adapter API for Olm, Megolm, SAS, cross-signing, backup encryption, secret
  storage, import, and export operations;
- host-owned secure storage, recovery key storage, backup secret storage,
  platform keychain integration, logout, and local data deletion;
- proof that Houra repositories do not implement cryptographic primitives
  locally.

### Device keys, one-time keys, fallback keys, and device-list breadth

Track key endpoint and device-list behavior beyond the representative vectors:

- `POST /_matrix/client/v3/keys/upload`;
- `POST /_matrix/client/v3/keys/query`;
- `POST /_matrix/client/v3/keys/claim`;
- device list changed/left sync sections, fallback-key rotation, one-time key
  depletion, signed device key validation, and unknown-device omission;
- federation device-list and key query behavior where server-server evidence is
  intentionally included.

### Olm session, to-device, and withheld-key breadth

Track one-to-one encrypted session behavior:

- `PUT /_matrix/client/v3/sendToDevice/{eventType}/{txnId}`;
- `m.room.encrypted` Olm to-device payloads;
- pre-key message setup, normal Olm messages, replay handling, missing one-time
  keys, duplicate transaction IDs, out-of-order to-device delivery, and sync
  acknowledgement;
- key-share, withheld-key, key-request, and cancellation message handling.

### Megolm room session and encrypted-room event breadth

Track group-session behavior beyond the representative encrypted-room smoke:

- `m.room.encryption` state event handling;
- `m.room.encrypted` Megolm timeline events;
- outbound group session creation, rotation, sharing to devices, membership
  changes, removed-device handling, invite/join/leave behavior, replay
  detection, and message index gaps;
- server opacity to plaintext and session keys.

### Server-side key backup, recovery, and secret storage breadth

Track backup and recovery behavior beyond representative key backup vectors:

- key backup version create/read/update/delete;
- backup upload, restore, delete, and wrong-version behavior;
- encrypted backup payload storage, recovery-key/passphrase flow, backup trust,
  and logout/relogin recovery;
- secret storage, account data, backup secret, cross-signing secret, and
  platform secure-storage ownership boundaries.

### Verification, cross-signing, trust, and wrong-device breadth

Track device/user trust behavior beyond representative SAS and wrong-device
vectors:

- to-device and in-room verification flows;
- SAS, QR-code, cancellation, timeout, unsupported method, and out-of-sequence
  verification behavior;
- cross-signing key upload, signatures upload, keys query, key replacement,
  user-signing trust, self-signing trust, invalid signatures, and interactive
  auth replacement behavior;
- wrong-device, changed-fingerprint, and trust-reset recovery evidence.

### Encrypted media and attachment breadth

Track E2EE media behavior that must not be implied by encrypted-room support:

- encrypted attachment metadata, media keys, hashes, IVs, and file objects;
- upload/download integration with `mxc://` media and plaintext cache policy;
- thumbnail, range, resumable download, and encrypted preview boundaries;
- linkage to `SPEC-071` and `SPEC-072`.

### Federation, room-version, and push interaction breadth

Track E2EE behavior that crosses into other Matrix domains:

- federation device list updates, federation to-device delivery, encrypted
  federation EDUs, and remote key queries;
- room-version-aware encrypted event validation and redaction behavior;
- push notification privacy for encrypted rooms and event-id-only payloads;
- linkage to `SPEC-074`, `SPEC-078`, and `SPEC-077`.

### Shared parser, artifacts, security, and release evidence breadth

Track reusable helpers and release evidence:

- parser-only encrypted event envelope, key payload, backup payload,
  verification event, and cross-signing public key helpers;
- secret redaction, artifact manifest, local path redaction, crypto stack
  version, platform list, and per-step pass/fail evidence;
- release evidence linkage to `SPEC-062`, `SPEC-064`, `SPEC-065`, and
  `SPEC-066`;
- proof that representative `SPEC-050` through `SPEC-054`, `SPEC-069`, and
  `SPEC-072` evidence does not widen Matrix version or E2EE domain
  advertisement.

## Adoption decision checklist

After this contract merges:

- `houra-server#141` may cite `SPEC-079` as the Olm & Megolm full E2EE gap
  inventory for the current blocked release candidate.
- Future `houra-server` child issues should map one gap lane to one focused
  implementation or release-scope decision.
- `houra-client` work should be created for crypto stack selection, local state,
  trust UI, verification UX, backup UX, media decryption, or secure-storage
  behavior when explicitly scoped.
- `houra-labs` work should be created only when parser-only encrypted payload,
  key, backup, verification, cross-signing, or redaction helpers are
  intentionally scoped.
- Release evidence must keep `advertisement_allowed=false` for Olm & Megolm
  until every included lane has passing evidence or is explicitly excluded from
  that release candidate.

## Compatibility boundaries

- `SPEC-050` through `SPEC-054`, `SPEC-069`, and `SPEC-072` remain
  representative E2EE boundary gates, not a full local-crypto, encrypted-room,
  verification, cross-signing, backup, media, or device-trust support claim.
- Olm & Megolm support remains separate from Client-Server endpoint breadth,
  Server-Server federation breadth, Room Versions, Push Gateway, and Product
  MVP encrypted media attachment support unless a later contract explicitly
  links the domains.
