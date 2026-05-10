# SPEC-045: Matrix Profile, Account Data, and Room Tags

Status: draft
Feature profile: sync
Canonical: yes

## Purpose

Define the Matrix v1.18 Client-Server profile, account data, and room tag
endpoint family needed after the Client-Server MVP-equivalent gate.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds `/_matrix/**`
profile, account data, and tag behavior without changing existing
`/_houra/client/**` routes.

This is a Client-Server breadth contract. It covers profile field read, write,
and delete; global and room-scoped account data read/write; room tag list, add,
and remove; representative account-data sync visibility; and representative
authorization and JSON-shape errors. It does not define presence, receipts,
typing notifications, filters, capabilities, room directory, invites, push
rules, OpenID, server administration, or unstable MSC behavior.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3profileuserid>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#put_matrixclientv3profileuseridkeyname>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#delete_matrixclientv3profileuseridkeyname>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#client-config>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#room-tagging>
- Checked at: 2026-05-10T17:51:00+09:00
- Timezone: Asia/Tokyo

## Profile endpoints

Profile reads use Matrix profile endpoints and do not require authentication:

```text
GET /_matrix/client/v3/profile/{userId}
GET /_matrix/client/v3/profile/{userId}/{keyName}
```

A complete profile response is a JSON object containing the available profile
fields. A field response is a JSON object with exactly the requested field key.
The `displayname` field value must be a string. The `avatar_url` field value
must be an `mxc://` URI string. The `m.tz` field value is an IANA timezone
identifier when present. Custom field keys must follow the Matrix namespaced
identifier grammar from `SPEC-031`.

Profile writes require an access token authorized for `{userId}`:

```text
PUT /_matrix/client/v3/profile/{userId}/{keyName}
DELETE /_matrix/client/v3/profile/{userId}/{keyName}
```

The `PUT` request body must be a JSON object containing exactly one property,
and that property name must match `{keyName}`. A successful `PUT` or `DELETE`
returns `200` with `{}`. `DELETE` is successful even when the field is already
absent.

## Account data endpoints

Global account data:

```text
PUT /_matrix/client/v3/user/{userId}/account_data/{type}
GET /_matrix/client/v3/user/{userId}/account_data/{type}
```

Room-scoped account data:

```text
PUT /_matrix/client/v3/user/{userId}/rooms/{roomId}/account_data/{type}
GET /_matrix/client/v3/user/{userId}/rooms/{roomId}/account_data/{type}
```

The access token must be authorized for `{userId}`. The `{type}` path component
is an event type string; custom types should be namespaced. `PUT` request bodies
must be JSON objects and return `200` with `{}` when stored. `GET` returns the
stored content object directly.

Global account data must be visible to later `/sync` responses in
`account_data.events`. Room-scoped account data must be visible to later
`/sync` responses in the target room's `account_data.events`. Missing account
data returns `404` with `M_NOT_FOUND`.

## Room tag endpoints

Room tags are account data exposed through the Matrix room tagging endpoints:

```text
GET /_matrix/client/v3/user/{userId}/rooms/{roomId}/tags
PUT /_matrix/client/v3/user/{userId}/rooms/{roomId}/tags/{tag}
DELETE /_matrix/client/v3/user/{userId}/rooms/{roomId}/tags/{tag}
```

The access token must be authorized for `{userId}`. A tag `PUT` body is a JSON
object and may include `order` as a number in the inclusive range `[0, 1]`.
Successful `PUT` and `DELETE` requests return `200` with `{}`.

The tag list response must be a JSON object with a `tags` object:

```json
{
  "tags": {
    "m.favourite": {
      "order": 0.25
    }
  }
}
```

Adding, updating, or deleting room tags must update the room-scoped `m.tag`
account data representation used by `/sync`.

## Authentication and errors

Missing bearer tokens on endpoints that require authentication must return
`401` with `M_MISSING_TOKEN`. Invalid bearer tokens must return `401` with
`M_UNKNOWN_TOKEN`.

Requests where the access token is not authorized for `{userId}` must return
`403` with `M_FORBIDDEN`.

Malformed JSON objects, mismatched profile keys, invalid profile key names, or
tag `order` values outside `[0, 1]` must return `400` with a Matrix `M_*` error
appropriate to the failure (`M_BAD_JSON`, `M_NOT_JSON`, `M_MISSING_PARAM`, or
`M_INVALID_PARAM`).

Missing profile fields, missing account data, missing rooms, or inaccessible
rooms must return a Matrix `M_*` error envelope, normally `M_NOT_FOUND` or
`M_FORBIDDEN` depending on whether the server is allowed to disclose existence.

## Compatibility boundaries

- Existing `/_houra/client/**` behavior stays available.
- Matrix profile, account data, and tag endpoints must use Matrix `M_*` error
  envelopes, not Houra `code` envelopes.
- This contract does not advertise presence, receipts, typing, filters,
  capabilities, room directory, invitations, push rules, OpenID, server
  administration, E2EE, or federation support.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for profile keys, account-data event types,
  or `m.tag` content.
