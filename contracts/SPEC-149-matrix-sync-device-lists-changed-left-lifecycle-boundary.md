# Matrix v1.18 / Client-Server API / sync device_lists changed and left tracked-user lifecycle boundary

Status: draft
Feature profile: sync
Contract type: boundary
Matrix domain: Client-Server API
Primary reference: Matrix v1.18 / Client-Server API / sync device_lists changed and left tracked-user lifecycle boundary
Repository anchor: SPEC-149 Matrix Sync Device Lists Changed Left Lifecycle Boundary
Canonical: yes

## Purpose

Define the representative server-owned runtime boundary for the
Matrix v1.18 `GET /_matrix/client/v3/sync` `device_lists.changed` and
`device_lists.left` sections beyond the basic shape coverage in
`SPEC-093`: which tracked users appear in these sections, in what order
the server populates them, and how acknowledgement through `next_batch`
clears the queues.

This contract is a child gate of `SPEC-079`
`device-keys-one-time-fallback-device-list-breadth`. It narrows
`SPEC-093` without re-defining the generic sync extension shape, and it
does not implement Olm/Megolm cryptography, derive trust, or widen
`GET /_matrix/client/versions`.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3sync>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#tracking-the-device-list-for-a-user>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#extensions-to-sync>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3keysupload>
- Checked at: 2026-05-18T22:30:00+09:00
- Timezone: Asia/Tokyo

## Scope

Servers populate the device-list tracking sections of:

```text
GET /_matrix/client/v3/sync
```

A tracked user, from the perspective of the authenticated client, is any
remote or local Matrix user who currently shares an end-to-end encrypted
room with the client, or who started sharing an encrypted room with the
client between the previous `since` token and the new `next_batch`
token.

The server populates two sections under `device_lists`:

- `changed`: a list of user IDs whose device identity or cross-signing
  keys updated, or who newly became a tracked user, since the previous
  `since` token;
- `left`: a list of user IDs who were tracked but who no longer share
  any encrypted room with the client since the previous `since` token.

## Initial Sync

A `/sync` request without a `since` parameter (initial sync) must not
populate `device_lists.changed` or `device_lists.left` with arbitrary
historical entries. The server may omit `device_lists` entirely or
return empty `changed` and `left` lists. The next `next_batch` token
becomes the baseline for tracked-user lifecycle reporting.

## Tracked-User Lifecycle Reporting

For an incremental `/sync` whose `since` token is `T0` and whose
`next_batch` token is `T1`, the server must include a user `U` in
`device_lists.changed` if any of the following happened between `T0`
and `T1`:

- `U` published or replaced `device_keys` via `keys/upload`;
- `U` published or replaced cross-signing keys via
  `keys/device_signing/upload`;
- `U` newly joined an encrypted room that the authenticated client is
  also a member of;
- `U` rotated a tracked device's signed key material in a way that
  changes the public device key identity.

The server must include a user `U` in `device_lists.left` if between
`T0` and `T1`, `U` was a tracked user at `T0` and is not in any shared
encrypted room with the client at `T1`.

A user `U` must not appear in both `changed` and `left` in the same
sync response.

Each tracked user must appear at most once in `changed` and at most
once in `left` per sync response, even if multiple changes occurred
between `T0` and `T1`. Multiple updates collapse to one entry.

## Acknowledgement and No-Replay

Once a sync response carries `device_lists.changed` containing `U` and
the client makes a subsequent `/sync` request with `since` set to the
`next_batch` that included `U`, the new response must not include `U`
in `changed` again unless a fresh change happened after that
`next_batch`.

The same rule applies to `device_lists.left`: an acknowledged `left`
entry must not reappear after the `next_batch` advances.

A `/sync` request that reuses an older `since` token is not required to
resurrect already-acknowledged `changed` or `left` entries.

## Unchanged Sync

A `/sync` response that observes no tracked-user lifecycle change must
either omit the `device_lists` object, or return it with `changed` and
`left` set to empty lists. The server must not synthesise spurious
entries to satisfy clients that always expect a populated section.

## Boundaries with Federated Tracked Users

When a tracked user is on a remote homeserver and the local server
observes that remote homeserver's `m.device_list_update` EDU (via
`SPEC-145`), the local server must reflect the corresponding user into
`changed` on the next eligible sync. Federation propagation failures do
not produce spurious `left` entries; they may produce missing-update
gaps that are reconcilable through `keys/query`.

Federation propagation correctness, fanout completeness across
multiple destination servers, and remote signature trust remain out of
scope.

## Fail-Closed Behavior

Implementations must reject or fail-close:

- malformed `since` tokens with a Matrix `M_INVALID_PARAM` envelope;
- requests by an unauthenticated client with `M_MISSING_TOKEN` or
  `M_UNKNOWN_TOKEN` per `SPEC-037`;
- internal mis-tracking that would surface a user in `changed` who
  shares no encrypted room with the authenticated client (such an
  entry leaks the existence of a non-tracked user; servers must
  redact the entry or, when not feasible, omit it entirely);
- internal mis-tracking that would resurrect an acknowledged `left`
  entry without a fresh tracked-user lifecycle event in between.

The server must not log raw access tokens, refresh tokens, device
secrets, or private signing keys alongside the tracked-user table or
`since`-token bookkeeping.

## Claim Boundary

Passing this contract does not claim:

- federated device-list fanout correctness across multiple
  destination servers;
- remote signature trust for cross-signing key updates;
- key backup or recovery-key behavior beyond `SPEC-053`;
- one-time-key depletion semantics beyond `SPEC-153`;
- device key self-signature verification beyond `SPEC-147`;
- to-device delivery beyond `SPEC-052`;
- Matrix v1.18 full E2EE support or `/versions` advertisement
  widening.

## Japanese Guidance

この contract は Matrix v1.18 `/sync` の `device_lists.changed` /
`device_lists.left` の tracked-user lifecycle を server-runtime gate
として固定する。`SPEC-093` が shape のみだったところを、device key /
cross-signing key 更新、暗号化ルームの join / leave、`next_batch` 認知後
の no-replay の挙動まで narrow する。Olm/Megolm 暗号、federation fanout
の正しさ、Matrix `/versions` の E2EE 広告は引き続き広げない。

## Adoption Decision Checklist

After this contract merges:

- create or extend an `houra-server` adoption issue for representative
  tracked-user lifecycle reporting in `/sync` against the pinned
  `houra-spec` ref;
- server adoption must include passing evidence for an initial-sync
  empty section, an incremental sync that lists a user who updated
  device keys in `changed`, an incremental sync that lists a user who
  left the last shared encrypted room in `left`, an acknowledged sync
  that does not replay either section, and an unchanged sync that
  omits or empties the section;
- README adoption evidence in `houra-server` must cite this contract,
  vector, implementation ref, verification commands, and a clean-room
  note;
- `SPEC-079` remains the full Olm & Megolm E2EE gap inventory until
  all child lanes provide runtime and release evidence;
- representative evidence from this contract must not widen Matrix
  `/versions`, release notes, or the publishable Matrix support
  claim.

## Compatibility Boundaries

- `SPEC-037` remains the basic `/sync` MVP boundary.
- `SPEC-093` remains the generic sync extensions shape (device_lists,
  device_one_time_keys_count, account_data extension, etc.).
- `SPEC-051` and the cross-signing endpoints remain the source-of-change
  surfaces that drive lifecycle reporting.
