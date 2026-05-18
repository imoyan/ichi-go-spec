# Matrix v1.18 / Client-Server API / keys changes on-demand pull endpoint boundary

Status: draft
Feature profile: auth
Contract type: boundary
Matrix domain: Client-Server API
Primary reference: Matrix v1.18 / Client-Server API / keys changes on-demand pull endpoint boundary
Repository anchor: SPEC-150 Matrix Keys Changes On-Demand Pull Boundary
Canonical: yes

## Purpose

Define the representative server-owned boundary for the Matrix v1.18
`GET /_matrix/client/v3/keys/changes` endpoint: the on-demand pull
counterpart to `/sync` `device_lists.changed` / `device_lists.left`
push semantics.

This contract is a child gate of `SPEC-079`
`device-keys-one-time-fallback-device-list-breadth`. It complements
the `/sync` runtime gate from the device-list lifecycle child contract
without re-defining the push semantics, and it does not implement
Olm/Megolm cryptography, derive trust, or widen
`GET /_matrix/client/versions`.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3keyschanges>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#tracking-the-device-list-for-a-user>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3sync>
- Checked at: 2026-05-18T23:30:00+09:00
- Timezone: Asia/Tokyo

## Scope

Servers expose:

```text
GET /_matrix/client/v3/keys/changes?from={fromToken}&to={toToken}
```

The endpoint returns the set of tracked users whose device-list state
changed between two `/sync` tokens, without requiring the client to
replay `/sync` to recover that information.

Query parameters:

- `from`: a required sync token marking the start of the observation
  window (exclusive). The token must be a `/sync` `next_batch` value
  previously issued by this server for the authenticated device.
- `to`: an optional sync token marking the end of the observation
  window (inclusive). When omitted, the server treats the request as
  covering the open interval up to the current sync position.

Response body:

- `changed`: a list of user IDs whose device identity or cross-signing
  keys updated in the window, or who became tracked users in the
  window;
- `left`: a list of user IDs who were tracked at `from` but were no
  longer tracked at `to`.

A "tracked user" is the same set described by the `/sync` device-list
lifecycle child boundary in this domain: any user who currently shares
an end-to-end encrypted room with the authenticated client at the
respective token.

## Token Validation

The server must validate `from`:

- a missing `from` must return `400` with `M_MISSING_PARAM`;
- a malformed or non-`/sync`-issued token must return `400` with
  `M_INVALID_PARAM`;
- a token issued for a different device or user must be rejected with
  `400` with `M_INVALID_PARAM` (the server may also surface
  `M_FORBIDDEN` when the cross-device leak risk is salient).

The server must validate `to` when present:

- a malformed `to` must return `400` with `M_INVALID_PARAM`;
- a `to` that orders before `from` must return `400` with
  `M_INVALID_PARAM`;
- a `to` that the server has not issued yet must be treated as the
  current sync position (the server may also reject with
  `M_INVALID_PARAM` when stricter validation is preferred; consistent
  rejection is acceptable as long as the server does not silently
  invent future tokens).

## Response Invariants

The response must:

- only include tracked users in `changed` and `left`;
- exclude any user from both `changed` and `left` in the same response
  (a user appears in at most one section);
- coalesce multiple updates per user into a single entry;
- not duplicate user IDs within either list;
- preserve the same tracked-user definition as `/sync`
  `device_lists.changed` / `device_lists.left`.

The server must not synthesise entries for users who are not tracked
by the authenticated client, and must not leak the existence of
non-tracked users through this endpoint.

The server must not return entries that the authenticated client
already observed via `/sync` between `from` and `to` and acknowledged;
this endpoint reports the canonical window state, not a residual
queue. Idempotent requests within the same window must return the
same `changed` and `left` lists.

## Authentication and Errors

Missing bearer tokens must return `401` with `M_MISSING_TOKEN`.
Invalid bearer tokens must return `401` with `M_UNKNOWN_TOKEN`.
Rate-limited requests may return `429` with `M_LIMIT_EXCEEDED` and
`retry_after_ms`.

The server must not log raw access tokens, refresh tokens, or device
secrets alongside the token-window bookkeeping.

## Fail-Closed Behavior

Implementations must reject or fail-close:

- requests without `from`;
- requests with a malformed or foreign-device `from` or `to`;
- requests with `to` ordered before `from`;
- responses that would include users with whom the client shares no
  encrypted room;
- responses that resurrect entries from outside the requested
  window;
- internal mis-tracking that would surface a non-tracked user.

## Claim Boundary

Passing this contract does not claim:

- federation device-list fanout correctness across multiple
  destination servers;
- remote signature trust for cross-signing key updates;
- federated query timeouts and `failures` semantics beyond `SPEC-069`
  and the sibling `/keys/query` boundary;
- device key self-signature verification beyond `SPEC-147`;
- key backup, encrypted-room, or verification breadth beyond the
  respective child gates of `SPEC-079`;
- Matrix v1.18 full E2EE support or `/versions` advertisement
  widening.

## Japanese Guidance

この contract は Matrix v1.18 の `GET /_matrix/client/v3/keys/changes`
を server boundary として固定し、`/sync` device_lists の push
counterpart として on-demand pull を提供する。tracked user の定義 (暗号化
ルーム共有) と coalesce / 重複なし / `from` 必須 / 不整合 token 拒否 /
非 tracked user の漏洩防止を fail-closed に narrow する。local
Olm/Megolm 暗号、federation fanout の正しさ、remote signature の信用評価、
Matrix `/versions` の E2EE 広告は引き続き広げない。

## Adoption Decision Checklist

After this contract merges:

- create or extend an `houra-server` adoption issue for the
  representative `keys/changes` runtime against the pinned
  `houra-spec` ref;
- server adoption must include passing evidence for a happy-path
  `from`+`to` window returning the expected tracked users, an
  omitted-`from` rejection, a malformed-`from` rejection, a
  reversed-token rejection, an idempotent re-query returning the same
  result, and an attempt by a different-device token returning the
  appropriate Matrix `M_*` envelope;
- README adoption evidence in `houra-server` must cite this contract,
  vector, implementation ref, verification commands, and a clean-room
  note;
- representative evidence from this contract must not widen Matrix
  `/versions`, release notes, or the publishable Matrix support
  claim.

## Compatibility Boundaries

- `SPEC-037` remains the basic `/sync` MVP boundary.
- `SPEC-093` remains the generic sync extensions shape.
- The `/sync` device-list lifecycle child boundary in this domain
  remains the push-side runtime authority; this contract is the
  on-demand pull counterpart that must agree with it on the same
  window.
- The `/keys/query` child boundary in this domain remains the
  authority for the live keys-and-cross-signing response;
  `/keys/changes` only reports the set of users that changed.
