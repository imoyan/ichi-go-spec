# SPEC-053: Matrix Key Backup and Restore Gate

Status: draft
Feature profile: messaging
Canonical: yes

## Purpose

Define the Matrix v1.18 Client-Server key backup and restore gate, including
logout/relogin recovery evidence.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds `/_matrix/**`
server-side key backup behavior without changing existing `/_houra/client/**`
routes.

This endpoint family builds on `SPEC-050` crypto adapter ownership and
`SPEC-052` encrypted room send/receive. It covers backup version create/read
and metadata update, room key upload, room key restore, wrong-version failures,
missing-session restore failures, and logout/relogin recovery evidence. It does
not define local Megolm implementation, secret storage UX, verification,
cross-signing, backup deletion, federation, or complete backup trust policy.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#server-side-key-backups>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3room_keysversion>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3room_keysversion>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#put_matrixclientv3room_keysversionversion>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#put_matrixclientv3room_keyskeysroomidsessionid>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3room_keyskeysroomidsessionid>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#backup-algorithm-mmegolm_backupv1curve25519-aes-sha2>
- Checked at: 2026-05-10T20:52:18+09:00
- Timezone: Asia/Tokyo

## Backup versions

Clients create a backup with:

```text
POST /_matrix/client/v3/room_keys/version
```

The request requires authentication and includes `algorithm` and `auth_data`.
This contract covers `m.megolm_backup.v1.curve25519-aes-sha2`. `auth_data`
contains public backup metadata such as `public_key` and signatures. The server
must store `auth_data` as public backup metadata and must not store or infer
private recovery keys.

The current backup is read with:

```text
GET /_matrix/client/v3/room_keys/version
```

A specific backup version is read or updated with:

```text
GET /_matrix/client/v3/room_keys/version/{version}
PUT /_matrix/client/v3/room_keys/version/{version}
```

Only `auth_data` can be modified by the update endpoint, and the algorithm must
match the backup version's algorithm.

Backup versions are scoped to the authenticated user. Version identifiers are
not global capability handles. A token for another user must not read or update
a backup version owned by the original user; servers must return `404` with
`M_NOT_FOUND` and must not mutate the original user's backup metadata.

## Key upload and restore

Clients upload encrypted Megolm session backup data with:

```text
PUT /_matrix/client/v3/room_keys/keys/{roomId}/{sessionId}?version={version}
```

The request body contains:

- `first_message_index`;
- `forwarded_count`;
- `is_verified`;
- `session_data`, an opaque encrypted object produced by the maintained crypto
  adapter for the active backup version.

Servers store and return `session_data` as opaque encrypted data. They must not
decrypt, inspect, or transform it.

Clients restore a session with:

```text
GET /_matrix/client/v3/room_keys/keys/{roomId}/{sessionId}?version={version}
```

Successful restore returns the stored backup data for the room/session. If a
new upload replaces an existing session, implementations should keep the better
backup according to Matrix ordering: prefer verified sessions, then lower
`first_message_index`, then lower `forwarded_count`.

Room key backup sessions are also scoped to the authenticated user and backup
version owner. A token for another user must not restore or overwrite a room key
session from the original user's backup version; servers must return `404` with
`M_NOT_FOUND` and must leave the original encrypted backup payload unchanged.

## Logout/relogin recovery gate

A passing implementation must demonstrate:

- a client creates or discovers a trusted backup version;
- an encrypted room session is uploaded through the backup endpoints;
- the client logs out and clears local encrypted-room session state according
  to host-owned storage policy from `SPEC-050`;
- after relogin, the client reads the backup version, downloads the backed-up
  session, passes it to the maintained crypto adapter, and can decrypt a
  previously received encrypted room event from `SPEC-052`;
- the smoke records the spec ref, server ref, client ref, crypto stack name and
  version, backup version, commands, and per-step pass/fail evidence.

## Authentication and errors

Missing bearer tokens must return `401` with `M_MISSING_TOKEN`. Invalid bearer
tokens must return `401` with `M_UNKNOWN_TOKEN`.

Malformed request bodies, unsupported backup algorithms, invalid `auth_data`,
invalid room IDs, invalid session IDs, missing backup versions, missing
sessions, and invalid backup data shapes must return Matrix `M_*` error
envelopes appropriate to the failure (`M_BAD_JSON`, `M_NOT_JSON`,
`M_MISSING_PARAM`, `M_INVALID_PARAM`, or `M_NOT_FOUND`).

Uploading keys to a stale backup version must return `403` with
`M_WRONG_ROOM_KEYS_VERSION` and enough response detail for the client to retry
against the current version.

Rate-limited endpoints may return `429` with `M_LIMIT_EXCEEDED` and
`retry_after_ms`.

## Compatibility boundaries

- Existing `/_houra/client/**` behavior stays available.
- Matrix key backup endpoints must use Matrix `M_*` error envelopes, not Houra
  `code` envelopes.
- This contract stores and returns opaque encrypted backup payloads but does
  not implement Megolm locally.
- This contract does not claim verification, cross-signing, secret storage,
  backup deletion, federation, or Matrix v1.18 full compliance.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for backup version metadata or room key
  backup payload shape validation.
