# SPEC-086: Matrix Push Payload Minimization Boundary

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Define a bounded, privacy-preserving Push Gateway payload minimization boundary
for the `privacy-payload-minimization-breadth` lane in `SPEC-077`.

This contract lets implementation repositories record representative evidence
for minimized notification payload decisions without claiming full Push Gateway
API support, vendor provider operation, client notification rendering, or
production push delivery completeness.

## Scope

This contract covers representative server-side payload minimization decisions
for Matrix v1.18 push notifications:

- `event_id_only` payloads;
- count-only updates;
- encrypted room notifications;
- redacted event notifications;
- invite/member notifications.

The implementation evidence is a minimized artifact. It records decision IDs,
notification class, allowed fields, omitted fields, redaction assertions, and
resource bounds. It must not store raw notification payloads, raw event content,
pushkeys, vendor tokens, gateway credentials, local paths, or provider request
bodies.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/push-gateway-api/#post_matrixpushv1notify>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#push-notifications>
- Parent contract: `SPEC-060`
- Gap inventory: `SPEC-077`
- Checked at: 2026-05-16T00:45:00+09:00
- Timezone: Asia/Tokyo

## Payload minimization rules

All representative minimized payload decisions MUST:

- include only fields allowed by the decision artifact;
- omit message body, formatted body, sender display name, room name, and room
  alias unless a later focused contract explicitly allows them;
- keep encrypted room notifications content-free;
- keep redacted event notifications content-free;
- keep invite/member notifications count- or event-reference-oriented unless a
  later focused contract defines display-safe preview text;
- use `event_id`, `room_id`, `counts`, and device metadata as the preferred
  event notification fields;
- preserve `event_id_only` semantics from `SPEC-060`;
- keep count-only updates free of event metadata other than counts and devices.

## Resource and privacy bounds

Representative artifacts MUST be bounded:

- maximum canonical decision bytes: 16384;
- maximum decision count: 8;
- maximum allowed-field count per decision: 8;
- maximum omitted-field count per decision: 12;
- recursive event lookup: false;
- event content lookup: false;
- network lookup: false;
- vendor provider request generation: false;
- raw pushkey persistence: false;
- local path evidence: false.

Implementations MUST fail closed when these bounds are not present or are
weakened.

## Evidence artifact

Each decision records:

- `id`;
- `notification_class`;
- `payload_shape`;
- `allowed_fields`;
- `omitted_fields`;
- `redaction_assertions`;
- `result`.

`notification_class` is one of:

- `event_id_only`;
- `count_only`;
- `encrypted_room`;
- `redacted_event`;
- `invite_member`.

`payload_shape` is one of:

- `event_reference`;
- `count_update`.

`result` is `accepted` for the representative minimized decisions in this
contract.

Artifacts MUST NOT include `content`, `body`, `formatted_body`, `room_name`,
`room_alias`, `sender_display_name`, `pushkey`, `vendor_token`,
`gateway_credentials`, `local_path`, or raw provider payload fields.

## Advertisement and compatibility boundary

Passing this contract MUST NOT:

- advertise Push Gateway API full breadth;
- advertise production push provider support;
- widen `GET /_matrix/client/versions`;
- imply APNS, FCM/GCM, Web Push, permission UI, notification rendering,
  background scheduling, or device badge behavior;
- change existing `SPEC-060` notify, pusher, push-rule, delivery failure, or
  rejected-pushkey evidence.

## Adoption notes

- `houra-server#247` adopts this contract by storing and validating the
  minimized artifact against the vector.
- `houra-client` work is only required when user-facing pusher setup,
  notification rendering, permission prompts, or badge behavior changes.
- `houra-labs` work is only required if a reusable parser helper is adopted.
