# SPEC-008: Send Message

Status: draft
Feature profile: messaging
Canonical: yes

## Purpose

Define the MVP text-message send operation.

## Request

```text
POST /_chawan/client/rooms/{room_id}/messages
Authorization: Bearer token-1
```

```json
{
  "msgtype": "chawan.text",
  "body": "hello"
}
```

## Response

```json
{
  "event_id": "$event:example.test"
}
```

## Client expectations

- Clients must attach bearer tokens in the `Authorization` header.
- Clients must not add transaction IDs until a contract defines idempotency.
- `event_id` must be a non-empty string.
