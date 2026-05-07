# SPEC-011: Basic Sync

Status: draft
Feature profile: sync
Canonical: yes

## Purpose

Define an incremental sync response for first-party clients.

## Request

```text
GET /_ichi-go/client/sync?since=s0&timeout=30000
Authorization: Bearer token-1
```

`since` is optional. `timeout` is optional and expressed in milliseconds.

## Response

```json
{
  "next_batch": "s1",
  "rooms": [
    {
      "room_id": "!room:example.test",
      "timeline": {
        "events": []
      }
    }
  ]
}
```

## Client expectations

- `next_batch` must be a non-empty string.
- `rooms` must be an array.
- Each room entry must contain a non-empty `room_id`.
- Timeline events must parse as SPEC-007 event objects.
- Persistence of `next_batch` is host-owned and injected into SDK helpers.
