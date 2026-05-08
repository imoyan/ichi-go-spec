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

## Client expectations

- Clients must preserve the HTTP status code.
- Clients must preserve a bounded response body summary for diagnostics.
- Clients may expose `code` when it is a non-empty string.
- Clients may expose `message` when it is a non-empty string.
- Clients must not require an error response to be valid JSON.
