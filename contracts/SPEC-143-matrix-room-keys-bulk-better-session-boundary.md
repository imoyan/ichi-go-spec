# Matrix v1.18 / Client-Server API / room_keys bulk session upload, restore, and better-session replacement boundary

Status: draft
Feature profile: messaging
Contract type: boundary
Matrix domain: Client-Server API
Primary reference: Matrix v1.18 / Client-Server API / room_keys bulk session upload, restore, and better-session replacement boundary
Repository anchor: SPEC-143 Matrix Room Keys Bulk Session Better-Replacement Boundary
Canonical: yes

## Purpose

Define the representative server-owned boundary for Matrix v1.18 server-side
key backup behavior beyond the basic single-session upload and restore in
`SPEC-053`: bulk session upload and restore across multiple rooms, the
better-session replacement ordering rule for re-uploads, and unknown-version
rejection.

This contract is a child gate of `SPEC-079`
`server-side-key-backup-recovery-secret-storage-breadth`. It narrows
`SPEC-053` without re-defining the basic version lifecycle or single-session
happy path, and it does not implement local Olm/Megolm cryptography, derive
backup secrets, decrypt `session_data`, or widen
`GET /_matrix/client/versions`.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#put_matrixclientv3room_keyskeys>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3room_keyskeys>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#put_matrixclientv3room_keyskeysroomid>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#put_matrixclientv3room_keyskeysroomidsessionid>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#server-side-key-backups>
- Checked at: 2026-05-18T18:00:00+09:00
- Timezone: Asia/Tokyo

## Scope

Servers accept and persist encrypted Megolm session backup data across
multiple rooms and sessions through:

```text
PUT /_matrix/client/v3/room_keys/keys?version={version}
GET /_matrix/client/v3/room_keys/keys?version={version}
PUT /_matrix/client/v3/room_keys/keys/{roomId}?version={version}
PUT /_matrix/client/v3/room_keys/keys/{roomId}/{sessionId}?version={version}
GET /_matrix/client/v3/room_keys/keys/{roomId}/{sessionId}?version={version}
```

The representative algorithm is `m.megolm_backup.v1.curve25519-aes-sha2`.
`session_data` is an opaque encrypted object. The server validates the
public envelope shape and the active backup version ownership. The server
must not decrypt `session_data`, must not derive backup secrets, and must
not record decrypted session keys, recovery keys, or plaintext.

## Bulk Session Upload and Restore

A bulk upload request body has the shape:

```text
{
  "rooms": {
    "!room1:example.test": {
      "sessions": {
        "session-A": { "first_message_index": 0, "forwarded_count": 0,
                       "is_verified": false, "session_data": { ... } },
        "session-B": { ... }
      }
    },
    "!room2:example.test": {
      "sessions": { "session-C": { ... } }
    }
  }
}
```

A successful upload returns `200` with `etag` and `count` fields. `count`
must equal the total number of sessions currently stored under the active
backup version after the upload settles. `etag` must change whenever the
stored backup state changes.

A bulk read returns the same shape under `rooms`, scoped to sessions stored
for the active backup version owned by the authenticated user. A per-room
bulk read scopes the response to that single room.

A bulk upload that targets an unknown or deleted version must return `404`
with `M_NOT_FOUND` and must not partially apply.

## Better-Session Replacement Ordering

When a session is re-uploaded for the same `(version, room_id, session_id)`,
the server must keep the better session and discard the worse session
according to Matrix ordering:

1. `is_verified: true` beats `is_verified: false`;
2. when verification status ties, lower `first_message_index` is better;
3. when verification status and `first_message_index` tie, lower
   `forwarded_count` is better.

The server must apply the ordering field-by-field independently of upload
order. The server must not silently replace a better stored session with a
worse incoming session, must not duplicate the stored entry, and must update
`etag` and `count` only when the stored entry actually changes.

The server must return the kept session on subsequent restore. The
discarded session must not be observable through any read endpoint.

## Cross-User Isolation

Bulk session upload and restore are scoped to the authenticated user and
the active backup version owner from `SPEC-053`. A token for another user
must not upload, restore, or replace another user's stored backup payloads;
the server must return `404` with `M_NOT_FOUND` and must leave the original
backup payload unchanged.

## Fail-Closed Behavior

Implementations must reject:

- non-object request bodies and non-object `rooms` maps;
- non-object per-room `sessions` maps;
- session entries missing `first_message_index`, `forwarded_count`,
  `is_verified`, or `session_data`;
- non-integer `first_message_index` or `forwarded_count`;
- non-boolean `is_verified`;
- non-object `session_data`;
- bulk operations targeting an unknown or deleted backup version;
- attempts to record decrypted plaintext, derived backup secrets, recovery
  material, or session-trust decisions on the server side.

Malformed bodies must return Matrix `M_*` error envelopes
(`M_BAD_JSON`, `M_NOT_JSON`, `M_MISSING_PARAM`, or `M_INVALID_PARAM`).
Missing bearer tokens must return `401` with `M_MISSING_TOKEN`. Invalid
bearer tokens must return `401` with `M_UNKNOWN_TOKEN`. Cross-user access
must return `404` with `M_NOT_FOUND`. Rate-limited requests may return
`429` with `M_LIMIT_EXCEEDED` and `retry_after_ms`.

## Claim Boundary

Passing this contract does not claim:

- local Olm or Megolm cryptography;
- recovery-key, passphrase, or secret-storage flows;
- backup auth signature verification beyond `auth_data` shape;
- automatic better-session merging across distinct `session_id` values;
- restore-time decryption or trust evaluation;
- logout/relogin recovery beyond `SPEC-053`;
- Matrix v1.18 full E2EE support or `/versions` advertisement widening.

## Japanese Guidance

この contract は `houra-server` の room_keys bulk endpoint と
better-session replacement の server boundary を広げ、bulk upload /
restore / per-room / unknown version 拒否 / cross-user isolation /
better-session 採択ルールを fail-closed に固定する。session_data の
復号、recovery 素材、secret storage、Matrix `/versions` の E2EE claim
は引き続き widen しない。

## Adoption Decision Checklist

After this contract merges:

- create or extend an `houra-server` adoption issue for the representative
  bulk room_keys behavior and better-session replacement against the
  pinned `houra-spec` ref;
- server adoption must include passing evidence for bulk upload across
  rooms, bulk read returning every stored session, better-session
  replacement when a verified session arrives after an unverified one,
  worse-session rejection (a higher `first_message_index` upload must not
  replace a lower one), unknown-version rejection, and cross-user
  isolation;
- README adoption evidence in `houra-server` must cite this contract,
  vector, implementation ref, verification commands, and a clean-room
  note;
- `SPEC-079` remains the full Olm & Megolm E2EE gap inventory until all
  child lanes provide runtime and release evidence;
- representative evidence from this contract must not widen Matrix
  `/versions`, release notes, or the publishable Matrix support claim.
