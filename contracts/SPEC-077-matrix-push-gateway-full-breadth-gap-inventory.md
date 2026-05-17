# Matrix v1.18 / Push Gateway API / full-breadth gap inventory

Status: draft
Feature profile: core
Contract type: gap-inventory
Matrix domain: Push Gateway API
Primary reference: Matrix v1.18 / Push Gateway API / full-breadth gap inventory
Repository anchor: SPEC-077 Matrix Push Gateway Full-Breadth Gap Inventory
Canonical: yes

## Purpose

Define the current Matrix v1.18 Push Gateway API full-breadth gap inventory
before Houra widens any push gateway, notification delivery, vendor provider,
or device-notification support claim beyond the adopted representative boundary
subset.

This contract records a fail-closed decomposition decision. It intentionally
does not add Push Gateway endpoint behavior, start APNS / FCM / GCM / Web Push
provider operations, implement client notification permission UI, widen
`GET /_matrix/client/versions`, or turn representative push gateway boundary
evidence into a full Push Gateway claim.

## Scope

This contract is the bridge between the adopted Push Gateway subset in
`SPEC-060` and the broader Matrix v1.18 Push Gateway and Client-Server push
notification surfaces.

The current release candidate keeps Push Gateway API out of the advertised
Matrix support scope. Full push work must be split into explicit follow-up
contracts or implementation issues before `houra-server` can cite it as release
evidence.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/push-gateway-api/>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#push-notifications>
- Checked at: 2026-05-14T08:25:29+09:00
- Timezone: Asia/Tokyo

## Current decision

Push Gateway API remains excluded from the current publishable Matrix support
claim.

The current release evidence may cite `SPEC-060` push gateway boundary,
destination control, notify payload, `event_id_only`, pusher setup, push-rule,
rejected pushkey, and retry gates as implementation evidence, but it must also
cite `imoyan/houra-server#139` as the open Push Gateway full-breadth scope
decision until all gap lanes below have their own passing evidence or explicit
release exclusion.

Systems must fail closed:

- do not advertise Push Gateway API, production push delivery, vendor provider,
  client permission UI, or notification rendering support from representative
  notify, pusher, push-rule, and retry vectors alone;
- keep `houra-server#139` open while unsupported push breadth remains excluded
  from the release candidate;
- keep Matrix `/versions` empty for the current blocked release candidate
  unless a later release bundle shows included-domain evidence and matching
  release notes;
- keep pushkeys, vendor tokens, provider credentials, notification content,
  gateway URLs, and local paths redacted in every follow-up lane.

## Covered subset

The current adopted subset is useful implementation evidence but not a full Push
Gateway claim:

- `SPEC-060`: separate push gateway boundary, `POST /_matrix/push/v1/notify`,
  unsupported endpoint behavior, pusher set/list shape, push rule
  configuration, notification counts, rejected pushkey handling, retry
  requirements, unsafe destination controls, and privacy boundaries.

## Required gap lanes

Future Push Gateway full-breadth work must be split into at least these lanes.
Each lane needs either a narrower spec contract with vectors, an implementation
issue with explicit non-advertisement, or both.

### Notify payload and gateway endpoint breadth

Track gateway request/response behavior beyond the representative notify
vector:

- `POST /_matrix/push/v1/notify`;
- full notification fields for content, counts, devices, event ID, priority,
  room, sender, type, and membership target state;
- count-only updates, event notifications, duplicate event suppression, and
  idempotent count updates;
- 200 `rejected` response shape and no-authentication boundary;
- 404 / 405 `M_UNRECOGNIZED` unsupported endpoint and method behavior.

### Pusher configuration and outbound destination safety breadth

Track Client-Server pusher configuration and server outbound controls:

- `GET /_matrix/client/v3/pushers`;
- `POST /_matrix/client/v3/pushers/set`;
- HTTPS-only `data.url`, required `/_matrix/push/v1/notify` path, userinfo and
  fragment rejection, redirect checks, DNS rebinding checks, timeout limits,
  body-size limits, and unsafe address class rejection;
- pusher removal, duplicate pusher replacement, and pushkey rotation.

### Push rule evaluation and sync visibility breadth

Track Client-Server push rule behavior that decides what notifications are sent:

- `GET /_matrix/client/v3/pushrules/`;
- `PUT /_matrix/client/v3/pushrules/global/{kind}/{ruleId}`;
- `DELETE /_matrix/client/v3/pushrules/global/{kind}/{ruleId}`;
- `PUT /_matrix/client/v3/pushrules/global/{kind}/{ruleId}/actions`;
- `PUT /_matrix/client/v3/pushrules/global/{kind}/{ruleId}/enabled`;
- rule ID validation, rule kind ordering, actions, tweaks, `m.push_rules`
  account data, `/sync` unread notification counts, and per-room overrides.

### Delivery retry, rejected pushkey, and lifecycle breadth

Track delivery lifecycle behavior beyond the representative retry vector:

- exponential backoff and retry expiry after gateway HTTP errors;
- connect timeout, read timeout, redirect limit, and response body size limit;
- gateway `rejected` pushkey removal and repeated rejection handling;
- duplicate suppression by `event_id` for event notifications;
- metrics and artifacts for delivery attempts without raw pushkeys or content.

### Privacy and payload minimization breadth

Track privacy-preserving push payload decisions:

- `event_id_only` pusher data format;
- count-only payloads;
- omission or redaction of message content, sender display name, room name, and
  room alias where policy requires;
- privacy policy for high vs low priority notifications, encrypted rooms,
  redacted events, and invite/member events;
- proof that payload minimization does not change the support advertisement.

### Vendor provider credential and gateway operation breadth

Track provider-owned behavior that must not be implied by the server boundary:

- APNS, FCM / GCM, and Web Push provider credentials;
- gateway-side token storage, credential rotation, upstream provider errors,
  provider rate limits, and provider-specific payload rendering;
- gateway deployment configuration, TLS, auth to vendor providers, and
  production credential issuance;
- artifacts proving provider secrets are excluded or redacted.

### Client permission, rendering, and background scheduling breadth

Track client/host-owned behavior outside the server boundary:

- OS notification permission prompts;
- notification rendering, localization, grouping, deep links, and action
  buttons;
- background scheduling, foreground suppression, notification tap handling, and
  unread badge reconciliation;
- mobile, desktop, web, and command-line client differences.

### Security, observability, and redaction breadth

Track production-quality operational evidence:

- gateway URL, pushkey, vendor token, credential, message content, and local
  path redaction;
- audit logs, metrics, traces, retry counters, rejected-pushkey counters, and
  unsafe-destination diagnostics;
- replay and duplicate-delivery evidence;
- issue refs for intentionally excluded provider and client-owned behavior.

### Release evidence and non-advertisement breadth

Track release-bundle linkage for Push Gateway API:

- release evidence linkage to `SPEC-062`, `SPEC-064`, `SPEC-065`, and
  `SPEC-066`;
- included-domain pass/fail artifacts for every supported Push Gateway lane;
- explicit release-note exclusions for provider credentials, device permission
  UI, notification rendering, and background scheduling while unsupported;
- proof that representative `SPEC-060` evidence does not widen Matrix version
  advertisement.

## Adoption decision checklist

After this contract merges:

- `houra-server#139` may cite `SPEC-077` as the Push Gateway full-breadth gap
  inventory for the current blocked release candidate.
- Future `houra-server` child issues should map one gap lane to one focused
  implementation or release-scope decision.
- `houra-client` work should be created only when user-facing pusher setup,
  notification permission, rendering, or badge behavior is explicitly scoped.
- `houra-labs` work should be created only when parser-only pusher data,
  push-rule, notification payload, or redaction helpers are intentionally
  scoped.
- Release evidence must keep `advertisement_allowed=false` for Push Gateway API
  until every included lane has passing evidence or is explicitly excluded from
  that release candidate.

## Compatibility boundaries

- `SPEC-060` remains a representative Push Gateway boundary gate, not a full
  Push Gateway API, production push provider, permission UI, or notification
  rendering conformance gate.
- Push Gateway support remains separate from Client-Server notification UI,
  Identity Service, Application Service, Room Versions, Olm & Megolm, and
  external provider operations unless a later contract explicitly links the
  domains.
