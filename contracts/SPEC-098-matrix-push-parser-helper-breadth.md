# SPEC-098: Matrix Push Parser Helper Breadth

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Define bounded Push Gateway parser-helper contracts for the
`pusher-configuration-outbound-destination-safety-breadth`,
`push-rule-evaluation-sync-visibility-breadth`, and
`security-observability-redaction-breadth` lanes in `SPEC-077`.

This contract lets `houra-labs` implement reusable parser-only helpers for
pusher descriptors, push-rule descriptors, and redacted push evidence without
claiming production Push Gateway API support, vendor provider operation, client
notification rendering, or Matrix version advertisement.

## Scope

This contract covers representative Matrix v1.18 push parser artifacts:

- HTTP pusher configuration descriptors for `GET /pushers` and
  `POST /pushers/set`;
- outbound destination descriptor decisions for HTTPS notify URLs;
- push-rule descriptors for global override, content, room, sender, and
  underride rules;
- `m.push_rules` account-data and `/sync` visibility descriptors;
- malformed pusher and push-rule descriptor cases that fail closed;
- redaction helper cases for pushkeys, gateway URLs, vendor tokens, message
  content, local paths, and provider responses.

The contract is parser-only. It does not define pusher persistence, background
delivery workers, DNS or redirect runtime lookups, retry queues, APNS, FCM/GCM,
Web Push, OS permission UI, notification rendering, unread badge behavior, or
Push Gateway full-breadth advertisement.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#push-notifications>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3pushers>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3pushersset>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3pushrules>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#put_matrixclientv3pushrulesglobalkindruleid>
- Parent contract: `SPEC-060`
- Gap inventory: `SPEC-077`
- Checked at: 2026-05-16T13:15:00+09:00
- Timezone: Asia/Tokyo

## Parser behavior

Parser helpers MUST produce normalized, typed descriptors instead of raw JSON
passthrough.

Pusher descriptors MUST record:

- `kind`: `http_pusher`;
- `app_id`, `app_display_name`, `device_display_name`, `lang`, `profile_tag`,
  and `data.format` when present;
- `data.url` as a normalized HTTPS notify URL descriptor;
- destination-safety parser decisions for scheme, host class, path, userinfo,
  fragment, redirect policy, and DNS-revalidation policy;
- removal and duplicate-replacement intent without storing raw pushkeys.

Push-rule descriptors MUST record:

- rule `kind`: `override`, `content`, `room`, `sender`, or `underride`;
- rule ID validation result;
- enabled state;
- normalized conditions, actions, and tweaks;
- sync visibility as `m.push_rules` account data;
- unread notification count linkage as descriptor metadata only.

Malformed descriptors MUST fail closed. Parser helpers MUST reject:

- non-object pusher or push-rule payloads;
- non-HTTPS pusher URLs;
- pusher URLs whose path is not `/_matrix/push/v1/notify`;
- pusher URLs with userinfo or fragments;
- user-created push-rule IDs that start with `.` or contain `/` or `\`;
- unsupported rule kinds;
- action or tweak entries whose shape cannot be normalized.

## Resource and privacy bounds

Representative artifacts MUST be bounded:

- maximum canonical case bytes: 28672;
- maximum case count: 10;
- maximum pusher descriptor count: 4;
- maximum push-rule descriptor count: 6;
- maximum action count per rule: 8;
- maximum condition count per rule: 8;
- URL parser only: true;
- DNS lookup: false;
- redirect follow: false;
- network lookup: false;
- provider request generation: false;
- raw pushkey evidence: false;
- raw vendor token evidence: false;
- raw gateway credential evidence: false;
- raw message content evidence: false;
- raw local path evidence: false;
- versions advertisement widened: false.

Implementations MUST fail closed when these bounds are missing or weakened.

## Redaction helper artifact

Redaction helper evidence records only categories, counts, hashes, or stable
decision IDs. It MUST NOT store raw pushkeys, gateway credentials, vendor
tokens, provider responses, local paths, message bodies, formatted bodies,
room display names, or sender display names.

The helper MUST redact those categories consistently across parser errors,
audit entries, metrics, release evidence, and diagnostics. Redaction output may
include replacement tokens such as `pushkey-redacted` only when the token is
synthetic and not reversible.

## Evidence artifact

Each representative case records:

- `id`;
- `kind`: `pusher_descriptor`, `push_rule_descriptor`,
  `sync_visibility_descriptor`, `malformed_descriptor`, or `redaction_helper`;
- `input_surface`;
- `status`;
- `errcode` when the result is a Matrix error;
- `normalized_fields`;
- `redacted_fields`;
- `result`: `accepted` or `rejected`.

Artifacts MUST NOT preserve raw parser inputs. They record normalized shape
evidence only.

## Compatibility boundaries

- This contract does not widen `GET /_matrix/client/versions`.
- Push Gateway API remains out of the current Matrix v1.18 advertisement until
  the release-evidence gate explicitly allows it.
- `SPEC-086` remains the payload-minimization boundary.
- `SPEC-091` remains the notify payload and gateway endpoint boundary.
- Runtime destination checks, retry lifecycle, provider credentials, provider
  dispatch, permission UI, rendering, background scheduling, and badge behavior
  stay in their own lanes.

## Adoption notes

- `houra-labs#128` may adopt this contract for parser-only Push Gateway helper
  implementation.
- `houra-server` adoption is only required when server pusher configuration,
  push-rule evaluation, delivery, or release evidence consumes these helpers.
- `houra-client` adoption is only required when user-facing pusher setup or
  notification UI changes.
