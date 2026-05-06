# SPEC-010: Timeline

Status: draft
Feature profile: sync
Canonical: yes

## Purpose

Define a minimal room timeline page.

## Request

```text
GET /_chawan/client/rooms/{room_id}/timeline?from=t1&limit=20
Authorization: Bearer token-1
```

`from` is optional. `limit` is optional.

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
- `start` must be a non-empty string.
- `end` is optional.
