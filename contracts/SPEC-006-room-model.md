# SPEC-006: Room Model

Status: draft
Feature profile: rooms
Canonical: yes

## Purpose

Define the MVP room operations used by first-party clients.

## Endpoints

```text
POST /_houra/client/rooms
POST /_houra/client/rooms/{room_id}/join
POST /_houra/client/rooms/{room_id}/leave
GET /_houra/client/rooms/{room_id}/state
```

Authenticated endpoints require `Authorization: Bearer`.

## Room object

```json
{
  "room_id": "!room:example.test",
  "name": "General",
  "membership": "join"
}
```

`name` is optional. `membership` is one of `join`, `invite`, `leave`.

## Client expectations

- Clients must validate room IDs as non-empty strings.
- Clients must reject unknown membership values.
- Room state responses contain an `events` array of SPEC-007 event objects.
