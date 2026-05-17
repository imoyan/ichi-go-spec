# Matrix v1.18 / Client-Server API / sync query and response sections

Status: draft
Feature profile: sync
Contract type: boundary
Matrix domain: Client-Server API
Primary reference: Matrix v1.18 / Client-Server API / sync query and response sections
Repository anchor: SPEC-093 Matrix Sync Breadth Extensions
Canonical: yes

## Purpose

Define the focused Client-Server `/sync` query descriptor and response-section
parser boundary promoted from the `SPEC-073` `sync-breadth-extensions` lane.

This contract lets implementation repositories adopt shared request descriptors,
public response-section parsers, and explicit unsupported-parameter error
mapping without turning parser evidence into long-poll runtime support, sync
token persistence, E2EE readiness, fanout correctness, or full Matrix
Client-Server API advertisement.

## Scope

This contract covers only parser and request-descriptor shape for:

```text
GET /_matrix/client/v3/sync
```

Only these public envelopes are adopted:

- sync request descriptors for `full_state`, `filter`, `set_presence`,
  `use_state_after`, timeout, and since tokens;
- filter definitions that request lazy-loaded members;
- top-level `presence.events`;
- top-level `to_device.events`;
- top-level `device_lists.changed` and `device_lists.left`;
- top-level `device_one_time_keys_count`;
- representative `rooms.invite`, `rooms.leave`, and `rooms.knock` sections;
- Matrix error envelopes for unsupported or malformed query parameters.

This contract does not define long-poll timing, token ordering, restart
persistence, fanout delivery, membership-list correctness, E2EE device-list
tracking, encrypted payload decryption, storage, federation, or a widened
Matrix `/versions` advertisement.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3sync>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#filtering>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#extensions-to-sync>
- Parent contract: `SPEC-037`
- Gap inventory: `SPEC-073`
- Checked at: 2026-05-16T06:30:00+09:00
- Timezone: Asia/Tokyo

## Adopted Descriptors

Implementations may expose request descriptors for the adopted `/sync` query
surface. Descriptors must keep query parsing typed and bounded:

```json
{
  "method": "GET",
  "path": "/_matrix/client/v3/sync",
  "query_params": {
    "filter": "filter-1",
    "full_state": true,
    "set_presence": "online",
    "since": "s1",
    "timeout": 0,
    "use_state_after": true
  },
  "requires_auth": true,
  "adopted_runtime_behavior": false,
  "response_parser": "sync_extensions"
}
```

`filter` may be either an opaque filter ID string or a filter definition object.
A filter definition object may include `room.state.lazy_load_members` and
`room.timeline.lazy_load_members` booleans. Parser-only adoption must preserve
those booleans without claiming membership-list correctness.

`set_presence` is limited to `online`, `offline`, or `unavailable` in adopted
descriptors. Unsupported values must fail closed with a Matrix error envelope.

## Adopted Response Sections

The extended sync parser may preserve the existing `SPEC-037` response shape and
add these optional sections:

```json
{
  "next_batch": "s2",
  "presence": {
    "events": []
  },
  "to_device": {
    "events": []
  },
  "device_lists": {
    "changed": [
      "@alice:example.test"
    ],
    "left": []
  },
  "device_one_time_keys_count": {
    "signed_curve25519": 3
  },
  "rooms": {
    "join": {},
    "invite": {},
    "leave": {},
    "knock": {}
  }
}
```

`presence.events` and `to_device.events` contain Matrix event-like public
envelopes with required `type` and `content` fields. The parser may preserve
unknown event content as JSON. It must not decrypt or interpret encrypted
payloads.

`device_lists.changed` and `device_lists.left` are arrays of Matrix user IDs.
`device_one_time_keys_count` is a map from algorithm name to non-negative
integer count.

`rooms.invite`, `rooms.leave`, and `rooms.knock` are maps keyed by room ID.
Representative parser evidence may preserve stripped state or timeline sections
as public JSON envelopes, but it does not claim room membership authorization,
state-resolution correctness, lazy-loading correctness, or knock/restricted
join runtime behavior.

## Fail-Closed Behavior

Implementations must fail closed:

- do not advertise full Client-Server API support from these descriptors or
  parsers;
- do not widen `GET /_matrix/client/versions`;
- reject malformed query descriptors with non-boolean `full_state` or
  `use_state_after`;
- reject malformed query descriptors with negative `timeout`;
- reject unsupported `set_presence` values;
- reject malformed `device_lists` sections whose `changed` or `left` entries
  are not user ID strings;
- reject malformed one-time-key counts that are negative or non-integer;
- keep E2EE readiness unclaimed unless `SPEC-050` through `SPEC-054`,
  `SPEC-079`, and implementation evidence pass.

## Adoption Decision Checklist

After this contract merges:

- `houra-labs#121` may add parser-only helper coverage for the adopted
  descriptors and response sections.
- Server implementation work requires a separate adoption issue before runtime
  query semantics, long-poll timing, token ordering, restart persistence,
  room-section fanout, device-list tracking, or E2EE sync behavior is added.
- Client work is needed only if a public SDK or UI surface intentionally exposes
  these descriptors or parsed envelopes.
- Release evidence must keep `advertisement_allowed=false` for Client-Server API
  until the broader `SPEC-073` lanes are resolved for the release.

## Compatibility Boundaries

- `SPEC-037` remains the `/sync` MVP contract.
- `SPEC-046` remains the receipts, typing, and read-marker parser contract.
- `SPEC-047` remains the filters, presence, and capabilities parser contract.
- `SPEC-052` remains the to-device and encrypted room gate.
- `SPEC-073` remains the Client-Server full-breadth gap inventory.
- Passing this contract does not claim long-poll correctness, fanout
  correctness, E2EE readiness, lazy-loading membership correctness, room-section
  completeness, or Matrix v1.18 full compliance.
