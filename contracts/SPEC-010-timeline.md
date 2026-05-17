# SPEC-010: Timeline

Status: draft
Feature profile: sync
Contract type: endpoint
Matrix domain: none
Canonical: yes

## Purpose

Define a minimal room timeline page.

## Request

```text
GET /_houra/client/rooms/{room_id}/timeline?from=t1&limit=20
Authorization: Bearer token-1
```

`from` is optional. When present, it is a server-issued opaque token for
backward pagination. Clients must not parse, compare, or derive values from it.

`limit` is optional and is a requested maximum event count. Servers may return
fewer events than requested. When `limit` is omitted, the server chooses the
page size.

## Response

```json
{
  "events": [],
  "start": "t1",
  "end": "t0"
}
```

## Client expectations

- `events` must be an array of SPEC-007 event objects.
- Events must be ordered newest-first for backward pagination pages.
- `start` must be a non-empty opaque token for this response page. When the
  request includes `from`, `start` echoes that token.
- `end` is an optional opaque token for the next older page.
- To request the next older page, clients should pass the previous response's
  `end` value as the next request's `from`.
- If `end` is absent, clients should treat the room as having no older page.
- Empty pages are valid `200` responses with `events: []`. They may include
  `end` only when an older page may still be available.
- Invalid, malformed, or expired `from` tokens should return HTTP 400 with
  `HOURA_BAD_REQUEST` when a structured error body is available.
- Forward pagination, database pagination strategy, and sync protocol redesign
  are out of scope.
