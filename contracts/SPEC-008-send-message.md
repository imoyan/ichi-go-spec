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
  "client_transaction_id": "txn-1",
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
- `client_transaction_id` must be a client-generated non-empty string.
- Clients should reuse the same `client_transaction_id` when retrying the same
  send after a timeout or transport failure.
- If the same sender sends to the same room with the same
  `client_transaction_id`, `msgtype`, and `body` again, servers should return
  the same `event_id` and must not create a second event.
- If the same sender reuses a `client_transaction_id` in the same room with a
  different `msgtype` or `body`, servers should return HTTP 409 with
  `CHAWAN_CONFLICT` when a structured error body is available.
- `event_id` must be a non-empty string.
- Server storage algorithms, encrypted media, rich messages, edits, and
  reactions are out of scope.
