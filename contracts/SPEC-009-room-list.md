# SPEC-009: Room List

Status: draft
Feature profile: sync
Contract type: endpoint
Matrix domain: none
Canonical: yes

## Purpose

Define a minimal authenticated room list query.

## Request

```text
GET /_houra/client/rooms
Authorization: Bearer token-1
```

## Response

```json
{
  "rooms": [
    {
      "room_id": "!room:example.test",
      "name": "General",
      "membership": "join"
    }
  ]
}
```

## Client expectations

- `rooms` must be an array of SPEC-006 room objects.
