# SPEC-002: Error Model

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Define the minimal structured error shape clients may read from non-success
HTTP responses.

## MVP response fields

Servers may return any JSON body for an error response, but clients should read
these fields when present:

```json
{
  "code": "HOURA_UNAVAILABLE",
  "message": "Service unavailable."
}
```

## MVP error vocabulary

The MVP recognises the following Houra-owned `code` values. Servers should use
the matching HTTP status when a structured error body is available; clients
should treat unknown `code` values as opaque diagnostic strings without
remapping them.

| `code` | HTTP status | Meaning | Example contracts |
|---|---|---|---|
| `HOURA_BAD_REQUEST` | `400` | Request body or query is malformed for a public contract. | `SPEC-004`, `SPEC-010`, `SPEC-020` |
| `HOURA_UNAUTHORIZED` | `401` | Request authentication failed, including missing or rejected bearer tokens and invalid credential attempts. | `SPEC-004`, `SPEC-020` |
| `HOURA_NOT_FOUND` | `404` | Targeted resource does not exist or is not available through the requested public contract. | `SPEC-020` |
| `HOURA_CONFLICT` | `409` | Request conflicts with existing public state, including reused idempotency keys with different content and duplicate localpart registration. | `SPEC-004`, `SPEC-008` |
| `HOURA_UNAVAILABLE` | `503` | Server cannot fulfil the request right now and clients should retry later. | `SPEC-002` baseline diagnostic |

This list is the Pre-1.0 MVP baseline. New `code` values must land in this
contract before any other `SPEC-*` references them.

## Client expectations

- Clients must preserve the HTTP status code.
- Clients must preserve a bounded response body summary for diagnostics.
- Clients may expose `code` when it is a non-empty string.
- Clients may expose `message` when it is a non-empty string.
- Clients must not require an error response to be valid JSON.
- Clients must not infer recovery behavior from unknown `code` values; HTTP
  status remains the routing signal when `code` is absent or unrecognised.
