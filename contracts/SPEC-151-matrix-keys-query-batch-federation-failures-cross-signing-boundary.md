# Matrix v1.18 / Client-Server API / keys query batch, federation failures, and cross-signing key inclusion boundary

Status: draft
Feature profile: auth
Contract type: boundary
Matrix domain: Client-Server API
Primary reference: Matrix v1.18 / Client-Server API / keys query batch, federation failures, and cross-signing key inclusion boundary
Repository anchor: SPEC-151 Matrix Keys Query Batch Federation Failures Cross-Signing Boundary
Canonical: yes

## Purpose

Define the representative server-owned boundary for Matrix v1.18
`POST /_matrix/client/v3/keys/query` behavior beyond the adoption-only
boundary in `SPEC-069`: multi-user batch behavior, unknown user/device
omission, federated remote-server failure surfaces under `failures`,
inclusion of cross-signing public keys (`master_keys`,
`self_signing_keys`, `user_signing_keys`), and the rule that
`user_signing_keys` are only returned for the authenticated user.

This contract is a child gate of `SPEC-079`
`device-keys-one-time-fallback-device-list-breadth`. It narrows
`SPEC-069` and complements `SPEC-051` / `SPEC-054` without re-defining
the basic query happy path, and it does not implement local Olm/Megolm
cryptography, derive trust, or widen
`GET /_matrix/client/versions`.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3keysquery>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#device-keys>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#cross-signing>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#post_matrixfederationv1userkeysquery>
- Checked at: 2026-05-18T23:00:00+09:00
- Timezone: Asia/Tokyo

## Scope

Servers accept and respond to:

```text
POST /_matrix/client/v3/keys/query
```

The request body may contain:

- `device_keys`: an object keyed by Matrix user ID whose value is an
  array of device IDs. An empty array requests all devices for that
  user.
- `timeout`: an optional non-negative integer milliseconds; the server
  may use it to bound how long it waits for federated remote-server
  responses. Servers must apply a sensible upper bound regardless of
  the client value.
- `token`: an optional string token correlating the query with a
  `/sync` `device_lists` baseline.

The response must include:

- `device_keys`: an object keyed by user ID and device ID with
  device-key objects per `SPEC-051`;
- `failures`: an object keyed by federated server name with Matrix
  `M_*` error envelopes for remote queries that did not succeed;
- optional `master_keys`, `self_signing_keys`, and `user_signing_keys`
  for users whose cross-signing keys are available to the
  authenticated client (subject to the rules below).

The server validates the request envelope shape, the user identifier
syntax, and the device ID list syntax. The server must not return
private key material or signatures over private content.

## Batch Behavior

A request may name multiple users. The server processes each
`(user_id, device_id_list)` independently and merges the results into
the unified response. A failure to resolve one user's devices must not
abort the entire request.

When `device_keys.{userId}` is an empty array, the server returns every
known device for that user. When it is a non-empty array, the server
returns only the named devices, omitting unknown device IDs from the
response without surfacing them in `failures`.

A request that names an unknown local user must omit the user from
`device_keys` without surfacing the user in `failures` (the user is
locally absent, not a federated failure).

## Cross-Signing Key Inclusion

When the server has stored cross-signing public keys for a queried
user (per `SPEC-054` and `SPEC-144`), the response must include those
keys under the corresponding sections:

- `master_keys`: included for any queried user with a stored
  `master_key`. Returned to any authenticated requester.
- `self_signing_keys`: included for any queried user with a stored
  `self_signing_key`. Returned to any authenticated requester.
- `user_signing_keys`: included **only** when the queried user is the
  authenticated requester. The server must not return another user's
  `user_signing_key` to a different authenticated user, because the
  `user_signing_key` is private to its owner's signing decisions.

Each returned cross-signing key object preserves the same public shape
as the upload object from `SPEC-054` (with `user_id`, `usage`, `keys`,
and `signatures`).

## Federated Remote-Server Failures

When the request names users on a remote homeserver and the local
server queries that remote homeserver via
`POST /_matrix/federation/v1/user/keys/query`, the local server
surfaces failures by remote server name under `failures`:

- network unreachable, TLS failure, or HTTP error → Matrix `M_*`
  envelope appropriate to the failure (for example
  `M_UNRECOGNIZED`, `M_UNKNOWN`, or `M_FORBIDDEN`);
- federation request timeout exceeding the bounded timeout →
  `M_UNKNOWN` with a `error` string describing the timeout;
- malformed remote response → `M_BAD_JSON`.

The server must not put successful entries in `failures`, and must not
synthesise fake device or cross-signing key objects for users whose
remote query failed.

The `failures` object is keyed by server name, not by user ID, because
multiple users on the same remote server share the same federation
result.

## Bounded Timeout

The server must clamp the request `timeout` value to a server-owned
upper bound. A `timeout` larger than the bound must not extend the
response wait beyond the bound. A `timeout` of `0` or omitted must
fall back to a server default. A negative or non-integer `timeout`
must be rejected with `400` and `M_INVALID_PARAM`.

## Fail-Closed Behavior

Implementations must reject or fail-close:

- non-object request bodies and non-object `device_keys` maps;
- non-array `device_keys.{userId}` values;
- non-integer `timeout`;
- malformed user IDs or device IDs in the request;
- returning another user's `user_signing_key`;
- returning private key or signature material;
- recording the federated failure detail with raw access tokens,
  refresh tokens, or homeserver signing keys.

Malformed bodies must return Matrix `M_*` envelopes
(`M_BAD_JSON`, `M_NOT_JSON`, `M_MISSING_PARAM`, or
`M_INVALID_PARAM`). Missing bearer tokens must return `401` with
`M_MISSING_TOKEN`. Invalid bearer tokens must return `401` with
`M_UNKNOWN_TOKEN`. Rate-limited requests may return `429` with
`M_LIMIT_EXCEEDED` and `retry_after_ms`.

## Claim Boundary

Passing this contract does not claim:

- local Olm or Megolm cryptography;
- trust evaluation of returned device or cross-signing keys;
- federation fanout correctness across multiple destination servers;
- device-list `changed` / `left` runtime semantics beyond `SPEC-149`;
- device key self-signature verification beyond `SPEC-147`;
- one-time-key claim or depletion beyond `SPEC-141`;
- cross-signing signature upload partial-failure beyond `SPEC-144`;
- Matrix v1.18 full E2EE support or `/versions` advertisement
  widening.

## Japanese Guidance

この contract は `/_matrix/client/v3/keys/query` の server boundary を
広げ、複数 user の batch 処理、unknown 局所 user / device の omission、
federation 経由 remote-server failure を `failures` map に server 名で
落とし込み、cross-signing 公開鍵 (`master_keys`, `self_signing_keys`) を
任意の認証 requester に返し、`user_signing_keys` は本人にのみ返す境界を
fail-closed に固定する。local Olm/Megolm 暗号、Matrix `/versions` の
E2EE 広告は引き続き広げない。

## Adoption Decision Checklist

After this contract merges:

- create or extend an `houra-server` adoption issue for the
  representative batch/failures/cross-signing inclusion behavior
  against the pinned `houra-spec` ref;
- server adoption must include passing evidence for a multi-user batch
  query that mixes known local users, an unknown local user (omitted),
  an unknown device id (omitted), a remote-server failure (in
  `failures`), the inclusion of `master_keys` / `self_signing_keys`
  for queried users, the absence of `user_signing_keys` for other
  users, the presence of `user_signing_keys` for the authenticated
  user, and a malformed request rejection;
- README adoption evidence in `houra-server` must cite this contract,
  vector, implementation ref, verification commands, and a clean-room
  note;
- `SPEC-079` remains the full Olm & Megolm E2EE gap inventory until
  all child lanes provide runtime and release evidence;
- representative evidence from this contract must not widen Matrix
  `/versions`, release notes, or the publishable Matrix support
  claim.

## Compatibility Boundaries

- `SPEC-069` remains the adoption-tracking and parser-only request /
  response boundary for `/keys/query`; this contract narrows its
  server runtime breadth.
- `SPEC-051` remains the upload boundary that feeds the response.
- `SPEC-054` and `SPEC-144` remain the cross-signing publication and
  partial-failure boundaries.
- `SPEC-109` remains the federation server-server endpoint adoption
  boundary that this contract relies on for `failures` propagation.
- `SPEC-149` remains the `/sync` `device_lists` runtime boundary that
  triggers clients to call this endpoint.
