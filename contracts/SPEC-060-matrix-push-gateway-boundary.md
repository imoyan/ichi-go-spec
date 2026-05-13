# SPEC-060: Matrix Push Gateway Boundary

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Define the Matrix v1.18 Push Gateway notification, pusher, push rule, delivery
failure, and privacy boundary contract for Houra ecosystem API work.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds the independent
push gateway boundary used when a homeserver forwards notification data to an
application-specific push gateway. It also records the Client-Server pusher and
push rule endpoints needed to configure that delivery path.

This contract covers `POST /_matrix/push/v1/notify`, rejected pushkey handling,
duplicate suppression, `event_id_only` format, pusher set/list shape, push rule
configuration shape, notification count visibility in `/sync`, and delivery
failure retry requirements. It does not define APNS, FCM/GCM, Web Push, vendor
credentials, device permission UI, notification rendering, background tasks, or
Identity Service behavior.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/push-gateway-api/#push-gateway-api>
- Source: <https://spec.matrix.org/v1.18/push-gateway-api/#post_matrixpushv1notify>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#push-notifications>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3pushrules>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#put_matrixclientv3pushrulesglobalkindruleid>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3pushers>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3pushersset>
- Source: <https://www.iana.org/assignments/iana-ipv4-special-registry>
- Source: <https://www.iana.org/assignments/iana-ipv6-special-registry>
- Checked at: 2026-05-10T21:53:00+09:00
- IANA address registry checked at: 2026-05-13T20:05:00+09:00
- Timezone: Asia/Tokyo

## Service boundary

Push Gateway support is a separate deployable component. The homeserver stores
pushers, evaluates push rules, computes unread counts, and calls the configured
gateway URL. The push gateway relays notifications to a device-vendor push
provider. Passing this contract must not make APNS, FCM/GCM, Web Push, or
vendor credential handling a hidden homeserver module.

Clients configure HTTP pushers through:

```text
GET /_matrix/client/v3/pushers
POST /_matrix/client/v3/pushers/set
```

For HTTP pushers, `data.url` must be an HTTPS URL whose path is
`/_matrix/push/v1/notify`. The homeserver forwards pusher `data` to the push
gateway without the `url` key.

The configured push gateway URL is an outbound destination. The homeserver must
reject or disable HTTP pushers whose `data.url` uses a non-HTTPS scheme,
userinfo, fragment, the wrong path, or an unsafe destination. Unsafe
destinations use the same default blocked address classes as `SPEC-055`,
including loopback, link-local, private-use, shared-address, unique-local,
unspecified, multicast, and otherwise non-globally-routable address space.

Homeservers must revalidate gateway destinations after redirects, after DNS
resolution, and immediately before opening a connection. A gateway URL that
starts as public but redirects or rebinds to an unsafe address must fail closed
before notification delivery. Legitimate public HTTPS push gateways whose host
resolves to public addresses and whose path is `/_matrix/push/v1/notify` remain
valid.

Clients configure push rules through:

```text
GET /_matrix/client/v3/pushrules/
PUT /_matrix/client/v3/pushrules/global/{kind}/{ruleId}
DELETE /_matrix/client/v3/pushrules/global/{kind}/{ruleId}
PUT /_matrix/client/v3/pushrules/global/{kind}/{ruleId}/actions
PUT /_matrix/client/v3/pushrules/global/{kind}/{ruleId}/enabled
```

User-created push rule IDs must not start with `.` and must not contain `/` or
`\`. Rule changes produce `m.push_rules` account data in the next `/sync`.

## Notify request

The push gateway endpoint is:

```text
POST /_matrix/push/v1/notify
```

It does not require Matrix API authentication. Unsupported endpoints return
`404 M_UNRECOGNIZED`; unsupported methods on known endpoints return
`405 M_UNRECOGNIZED`.

The request body contains `notification`. Event notifications should include
event metadata, counts, devices, priority, sender, room, type, and content when
available. Count-only updates may omit event fields. When pusher `data.format`
is `event_id_only`, only `event_id`, `room_id`, `counts`, and `devices` are
required for event notifications.

Gateways must suppress duplicate alerts for retried event notifications by
`event_id`. Count updates are idempotent and do not require duplicate alert
suppression.

## Delivery failures

The `200` response contains `rejected`, a list of pushkeys rejected by the push
gateway or upstream provider. Homeservers must stop sending to rejected pushkeys
and remove the associated pushers.

If the push gateway returns an HTTP error, the homeserver should retry for a
reasonable time using exponential backoff. Retry evidence must not contain raw
pushkeys, vendor tokens, or message content beyond what the vector explicitly
allows.

Outbound delivery attempts must use bounded connect/read timeouts, a redirect
limit, and response body size limits. Unsafe-destination diagnostics must redact
pushkeys, vendor tokens, gateway credentials, and message content.

## Privacy boundary

Push notifications pass through a push gateway and a push provider. Contracts
and implementations should prefer `event_id_only` or sync-command style payloads
where possible instead of sending message content to vendor push providers.
Pushkeys, provider routing tokens, and gateway credentials are secrets and must
never be logged in full or stored in public evidence.

## Compatibility boundaries

- Existing Houra and Matrix client, federation, application service, and
  identity behavior stays available.
- This contract introduces Push Gateway and related pusher/push-rule boundary
  contracts only. It does not claim APNS, FCM/GCM, Web Push, vendor credential
  handling, device permission UI, notification rendering, background tasks, or
  Matrix v1.18 full ecosystem compliance.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if parser-only helpers for
  push notification payloads or pusher data validation are intentionally
  adopted.
