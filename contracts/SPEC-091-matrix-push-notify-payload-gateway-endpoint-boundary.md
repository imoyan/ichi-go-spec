# SPEC-091: Matrix Push Notify Payload and Gateway Endpoint Boundary

Status: draft
Feature profile: core
Contract type: boundary
Matrix domain: Push Gateway API
Canonical: yes

## Purpose

Define a bounded Push Gateway notify payload and gateway endpoint boundary for
the `notify-payload-gateway-endpoint-breadth` lane in `SPEC-077`.

This contract lets implementation repositories record representative evidence
for `POST /_matrix/push/v1/notify` payload handling, count-only updates,
duplicate event suppression, rejected pushkey responses, and unsupported
endpoint or method behavior without claiming full Push Gateway API support or
vendor provider operation.

## Scope

This contract covers representative Matrix v1.18 Push Gateway endpoint behavior:

- event notification payloads with content, counts, devices, event ID, priority,
  room, sender, display names, type, and room display metadata;
- count-only update payloads that omit event-specific fields;
- duplicate suppression for event notifications by `event_id`;
- idempotent handling for count-only updates;
- `200` response bodies containing `rejected`;
- unauthenticated notify endpoint handling;
- `404 M_UNRECOGNIZED` for unsupported Push Gateway endpoints;
- `405 M_UNRECOGNIZED` for unsupported methods on
  `/_matrix/push/v1/notify`.

It does not define APNS, FCM/GCM, Web Push, vendor credentials, gateway-side
provider dispatch, client notification rendering, device permission UI,
background scheduling, delivery retry expiry, pusher destination safety, or
Push Gateway full-breadth advertisement.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/push-gateway-api/#post_matrixpushv1notify>
- Parent contract: `SPEC-060`
- Gap inventory: `SPEC-077`
- Checked at: 2026-05-16T01:08:00+09:00
- Timezone: Asia/Tokyo

## Endpoint behavior

The notify endpoint is:

```text
POST /_matrix/push/v1/notify
```

The endpoint MUST NOT require Matrix Client-Server API authentication.

Valid event notifications SHOULD preserve the representative payload fields
listed by the vector when they are present and accepted by the implementation
boundary. Valid count-only updates MAY omit event metadata and content. Count
updates are idempotent and do not require duplicate alert suppression.

Event notifications with an `event_id` MUST be duplicate-suppressed by
`event_id` within the representative gateway process. The evidence artifact may
record this as a duplicate decision; it must not imply durable cross-process
deduplication unless a later lifecycle contract adds that requirement.

Successful notify responses MUST use HTTP `200` and include `rejected` as an
array. The representative artifact keeps rejected pushkeys redacted and records
only the rejected count.

Unsupported endpoints under the Push Gateway surface MUST return
`404 M_UNRECOGNIZED`. Unsupported methods on `/_matrix/push/v1/notify` MUST
return `405 M_UNRECOGNIZED`.

## Resource and privacy bounds

Representative artifacts MUST be bounded:

- maximum canonical case bytes: 24576;
- maximum case count: 8;
- maximum payload field count per accepted payload: 12;
- maximum device count: 4;
- maximum rejected count: 4;
- duplicate cache scope: `process`;
- duplicate cache max entries: 128;
- network lookup: false;
- vendor provider request generation: false;
- raw pushkey evidence: false;
- raw vendor token evidence: false;
- versions advertisement widened: false.

Implementations MUST fail closed when these bounds are not present or are
weakened.

## Evidence artifact

Each representative case records:

- `id`;
- `kind`: `event_notification`, `count_only_update`,
  `duplicate_event_notification`, `rejected_response`,
  `unsupported_endpoint`, or `unsupported_method`;
- `request`: method and path;
- `status`;
- `errcode` when the result is a Matrix error;
- `payload_fields` for accepted payload shape evidence;
- `duplicate_suppressed`;
- `rejected_count`;
- `result`: `accepted`.

Artifacts MUST NOT store raw pushkeys, vendor tokens, gateway credentials,
local paths, provider request bodies, or full provider responses. Message
content is allowed only for the representative full notification payload case
listed by the vector, and it must remain bounded to that case.

## Compatibility boundaries

- This contract does not widen `GET /_matrix/client/versions`.
- Push Gateway API remains out of the current Matrix v1.18 advertisement until
  the release-evidence gate explicitly allows it.
- `SPEC-086` remains the privacy-minimization boundary for content-free or
  reduced payloads. This contract records endpoint and payload shape breadth;
  it does not weaken `SPEC-086` minimization rules for sensitive payloads.
- Pusher storage, outbound destination safety, retry lifecycle, and provider
  operation stay in their own lanes.
