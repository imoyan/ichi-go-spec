# SPEC-055: Matrix Federation Discovery and Signing Keys

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Define the Matrix v1.18 Server-Server discovery and signing-key bootstrap
contract for Houra federation work.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds `/.well-known/**`
and `/_matrix/key/**` federation bootstrap behavior without changing existing
`/_houra/client/**` or `/_matrix/client/**` routes.

This contract covers server-name resolution inputs, delegated
`/.well-known/matrix/server` discovery, local signing-key publication,
notary-style signing-key query, destination resolution failure handling, and
key-cache evidence. It does not define federation transactions, PDUs, EDUs,
make/send join, invites, backfill, event authorization, or state resolution.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/server-server-api/#server-discovery>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#resolving-server-names>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#getwell-knownmatrixserver>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#retrieving-server-keys>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#get_matrixkeyv2server>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#post_matrixkeyv2query>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#get_matrixkeyv2queryserverkeyid>
- Checked at: 2026-05-10T20:00:21+09:00
- Timezone: Asia/Tokyo

## Server-name discovery

Each homeserver is identified by a Matrix server name. A server name can include
an optional port. When a remote server name is not an IP literal, the requesting
server first requests:

```text
GET https://<hostname>/.well-known/matrix/server
```

The successful JSON response contains:

```json
{
  "m.server": "delegated.example.test:8448"
}
```

The `m.server` value is parsed as a delegated hostname and optional port, then
used for subsequent federation requests according to Matrix server-name
resolution rules. Requesting servers should follow 30x redirects while avoiding
redirection loops. Responses to the well-known endpoint should be cached with
Cache-Control when available, with sensible defaults for success and failure
responses.

If well-known lookup is invalid or unavailable, implementations follow Matrix
resolution fallback order: `_matrix-fed._tcp` SRV, deprecated `_matrix._tcp`
SRV, then CNAME/AAAA/A records with port 8448. This contract records that
fallback order but does not require a production DNS resolver implementation in
`houra-spec`.

## Signing-key publication

Homeservers publish their public signing keys with:

```text
GET /_matrix/key/v2/server
```

The response is a signed server-key object containing:

- `server_name`;
- `verify_keys`, keyed by key ID such as `ed25519:abc123`;
- `old_verify_keys` for expired keys;
- `valid_until_ts`;
- `signatures`.

`valid_until_ts` is cache metadata. Implementations must cap effective key
validity at the lesser of the returned timestamp and seven days in the future.
Private signing keys must never be exposed through this endpoint or any vector.

## Signing-key query

Servers query key material from notaries or remote servers with:

```text
POST /_matrix/key/v2/query
GET /_matrix/key/v2/query/{serverName}/{keyId}
```

The batch query request body contains `server_keys`, mapping server names to key
IDs and optional `minimum_valid_until_ts` requirements. Successful responses
return `server_keys`, with each returned key signed by the source server and by
the notary when a notary is involved.

If a remote server cannot be reached and no cached keys are available, a notary
query may return `200` with an empty `server_keys` array. This is not the same
as a destination resolution success.

## Destination resolution failure

A passing implementation must demonstrate that an invalid delegated server name,
missing SRV records, and unavailable address records do not result in a
federation request to an unverified destination. The failure gate records:

- the original Matrix server name;
- attempted well-known / SRV / address resolution stages;
- cache or backoff decision for the failed destination;
- no signed federation request being emitted;
- Matrix-compatible error evidence for operator-facing diagnostics.

## Authentication and errors

The server-key endpoints do not require client authentication. Federation
requests that later use the resolved destination are authenticated by server
signatures; that request-signing contract is intentionally left to later
federation transaction issues.

Malformed well-known bodies, invalid delegated server names, invalid key IDs,
malformed key objects, invalid signatures, and destination resolution failures
must be represented as Matrix-compatible `M_*` errors or operator-facing
diagnostic evidence appropriate to the failure. `M_UNRECOGNIZED` is used for
unknown endpoints or unsupported methods where applicable.

Rate-limited endpoints may return `429` with `M_LIMIT_EXCEEDED` and
`retry_after_ms`.

## Compatibility boundaries

- Existing `/_houra/client/**` and `/_matrix/client/**` behavior stays
  available.
- This contract introduces `/.well-known/matrix/server` and `/_matrix/key/**`
  surfaces only; it does not add federation transaction APIs.
- Private signing keys are implementation-owned secrets and must never appear
  in contracts, vectors, logs, or adoption evidence.
- This contract does not claim make/send join, invite, transaction, backfill,
  event auth, state resolution, appservice, identity, push, or Matrix v1.18 full
  federation compliance.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create an adoption issue for `houra-server`.
  Do not create `houra-client` work unless a later client-visible federation
  configuration surface is intentionally added. Create an `houra-labs` issue
  only if parser-only helpers for server names, well-known bodies, or server-key
  objects are intentionally adopted.
