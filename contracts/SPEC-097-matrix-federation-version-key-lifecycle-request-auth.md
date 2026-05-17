# Matrix v1.18 / Server-Server API / federation version, key lifecycle, and request auth

Status: draft
Feature profile: core
Contract type: boundary
Matrix domain: Server-Server API
Primary reference: Matrix v1.18 / Server-Server API / federation version, key lifecycle, and request auth
Repository anchor: SPEC-097 Matrix Federation Version, Key Lifecycle, and Request Auth
Canonical: yes

## Purpose

Define the focused parser and evidence boundary promoted from the `SPEC-074`
`federation-discovery-version-key-lifecycle-request-auth-breadth` lane.

This contract lets implementation repositories adopt parser-only descriptors
for federation version metadata, key query responses, server signing key
lifecycle metadata, and federation request authentication envelopes without
turning that parser evidence into DNS, TLS, outbound federation, key storage,
or full Server-Server API support.

## Scope

This contract covers parser and request-descriptor shape for:

```text
GET  /_matrix/federation/v1/version
POST /_matrix/key/v2/query
GET  /_matrix/key/v2/query/{serverName}/{keyId}
```

Only these public envelopes are adopted:

- federation version response metadata;
- batch and single-key query request descriptors;
- server signing key response objects with multiple `verify_keys`,
  `old_verify_keys`, `valid_until_ts`, and public signatures;
- parser-only federation request authentication descriptors for the
  `X-Matrix` authorization header shape;
- Matrix error envelopes for unsupported methods, unsupported endpoints,
  malformed JSON, malformed key IDs, missing signatures, and expired key
  metadata.

This contract does not define DNS lookup, TLS/SNI validation, outbound request
execution, private signing-key storage, cache persistence, notary selection,
event or PDU signature verification, transaction delivery, or a widened Matrix
`/versions` advertisement.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/server-server-api/#get_matrixfederationv1version>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#retrieving-server-keys>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#post_matrixkeyv2query>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#get_matrixkeyv2queryservernamekeyid>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#request-authentication>
- Parent contract: `SPEC-055`
- Gap inventory: `SPEC-074`
- Checked at: 2026-05-16T11:20:00+09:00
- Timezone: Asia/Tokyo

## Adopted Descriptors

Implementations may expose parser-only descriptors for the adopted federation
metadata and key lifecycle surface. Descriptors must keep path and body
variables typed and bounded:

```json
{
  "id": "federation-key-query-single",
  "method": "GET",
  "path": "/_matrix/key/v2/query/{serverName}/{keyId}",
  "path_params": {
    "serverName": "example.test",
    "keyId": "ed25519:auto1"
  },
  "query_params": {},
  "requires_auth": false,
  "adopted_runtime_behavior": false,
  "response_parser": "federation_key_query_response"
}
```

`serverName` must parse as a Matrix server name. `keyId` must be an `ed25519:*`
key ID. Parser-only adoption must preserve these values without performing
network lookup, cache writes, notary fallback, or signature verification.

Federation request-auth descriptors may parse the public envelope shape:

```json
{
  "scheme": "X-Matrix",
  "origin": "example.test",
  "destination": "remote.example.test",
  "key": "ed25519:auto1",
  "sig": "VGhpcyBpcyBhIHRlc3Qgc2lnbmF0dXJl",
  "signed_json_fields": ["method", "uri", "origin", "destination"]
}
```

The descriptor confirms only the normalized header shape. Signature checking,
canonical JSON generation, replay protection, clock skew policy, and request
execution remain implementation-owned.

## Adopted Response Metadata

Federation version parsers may expose the server metadata object:

```json
{
  "server": {
    "name": "Houra",
    "version": "0.1.0"
  }
}
```

Server signing key parsers may expose public key lifecycle metadata:

```json
{
  "server_name": "example.test",
  "verify_keys": {
    "ed25519:auto1": {
      "key": "VGhpcyBpcyBhIHRlc3QgcHVibGljIHZlcmlmeSBrZXk"
    }
  },
  "old_verify_keys": {
    "ed25519:old1": {
      "expired_ts": 1777801808000,
      "key": "VGhpcyBpcyBhbiBvbGQgdGVzdCBwdWJsaWMga2V5"
    }
  },
  "valid_until_ts": 1779011408000,
  "signatures": {
    "example.test": {
      "ed25519:auto1": "VGhpcyBpcyBhIHRlc3Qgc2lnbmF0dXJl"
    }
  }
}
```

`verify_keys` must be non-empty. `old_verify_keys` must preserve each
`expired_ts`. `valid_until_ts` is cache metadata; implementations must cap the
effective cache validity at the lesser of the returned timestamp and seven days
in the future. Private signing keys must never appear in contracts, vectors,
logs, parser return values, or adoption evidence.

## Fail-Closed Behavior

Implementations must fail closed:

- do not advertise full Server-Server API or full federation support from these
  descriptors or parsers;
- do not widen `GET /_matrix/client/versions`;
- reject unsupported methods and unsupported federation/key endpoints with
  Matrix-compatible unrecognized errors;
- reject malformed key IDs, empty server names, missing signatures, invalid
  `valid_until_ts`, and malformed old-key expiry metadata;
- reject request-auth envelopes that omit `origin`, `destination`, `key`, or
  `sig`;
- keep DNS, TLS/SNI, outbound request execution, notary fallback, cache
  persistence, private key storage, replay protection, and canonical JSON
  signing unclaimed unless later implementation evidence passes.

## Adoption Decision Checklist

After this contract merges:

- `houra-labs#123` may add parser-only helper coverage for the adopted
  descriptors, version metadata, key lifecycle metadata, and request-auth
  header shape.
- Server implementation work requires a separate adoption issue before runtime
  federation version endpoints, key query routing, key cache persistence,
  notary behavior, TLS/SNI validation, or request signature verification is
  added.
- Client work is needed only if a public SDK or UI surface intentionally exposes
  federation metadata for operators.
- Release evidence must keep `advertisement_allowed=false` for Server-Server
  API until the broader `SPEC-074` lanes are resolved for the release.

## Compatibility Boundaries

- `SPEC-055` remains the Server-Server discovery and signing-key bootstrap
  contract.
- `SPEC-056` remains the federation transaction, join, and invite contract.
- `SPEC-057` remains the federation backfill, event auth, and state interop
  contract.
- `SPEC-061` remains a federation smoke gate, not a full Complement or full
  Server-Server conformance gate.
- `SPEC-074` remains the Server-Server full-breadth gap inventory.
- Passing this contract does not claim DNS, TLS/SNI, outbound federation,
  key-cache persistence, request signature verification, transaction delivery,
  Complement full-breadth, or Matrix v1.18 full compliance.
