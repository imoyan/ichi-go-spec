# SPEC-007: Event Model

Status: draft
Feature profile: events
Contract type: boundary
Matrix domain: none
Canonical: yes

## Purpose

Define the minimal event object clients may parse.

## Event object

```json
{
  "event_id": "$event:example.test",
  "room_id": "!room:example.test",
  "sender": "@alice:example.test",
  "origin_server_ts": 1710000000000,
  "type": "houra.room.message",
  "content": {
    "msgtype": "houra.text",
    "body": "hello"
  }
}
```

## Client expectations

- `event_id`, `room_id`, `sender`, and `type` must be non-empty strings.
- `origin_server_ts` must be an integer.
- `content` must be a JSON object and must be treated as untrusted data.
- Text message event parsing requires `msgtype: houra.text` and non-empty `body`.
