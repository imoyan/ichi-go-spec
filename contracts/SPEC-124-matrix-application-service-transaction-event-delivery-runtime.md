# Matrix v1.18 / Application Service API / appservice transaction event delivery runtime

Status: draft
Feature profile: core
Contract type: boundary
Matrix domain: Application Service API
Primary reference: Matrix v1.18 / Application Service API / appservice transaction event delivery runtime
Repository anchor: SPEC-124 Matrix Application Service Transaction Event Delivery Runtime
Canonical: yes

## Purpose

Define the focused homeserver-to-appservice transaction delivery runtime
boundary promoted from the `SPEC-075`
`transaction-event-delivery-legacy-route-unknown-route-breadth` lane.

`SPEC-105` established parser-only artifact coverage for transaction envelopes.
This contract adds representative runtime behavior: the server must push
transactions to the appservice, handle ephemeral batches when
`receive_ephemeral` is enabled, retry on failure, enforce idempotency for
duplicate transaction IDs, maintain event ordering within a transaction, return
the correct error for unknown routes and methods, and attempt legacy route
fallback when needed.

This contract lets implementation repositories adopt transaction delivery
runtime without claiming third-party network event push, appservice ping, or
client-server extension sync for virtual users.

## Scope

This contract covers representative runtime behavior for:

```text
PUT /_matrix/app/v1/transactions/{txnId}
```

Only these public behaviors are adopted:

- `PUT /_matrix/app/v1/transactions/{txnId}` delivery with event and ephemeral
  batches;
- `receive_ephemeral: true` — typing, receipts, and presence payloads in the
  transaction body;
- retry and backoff on non-2xx appservice response;
- idempotency: duplicate `txnId` must not re-deliver;
- transaction ordering: events in a transaction maintain order;
- unknown route: `404` / `M_UNRECOGNIZED` for routes outside adopted endpoints;
- unknown method: `405` / `M_UNRECOGNIZED`;
- legacy route fallback for transactions: try
  `/_matrix/app/v1/transactions/{txnId}` first, then the legacy
  `/_matrix/app/unstable/transactions/{txnId}` path if the appservice signals
  a legacy endpoint.

This contract does not define third-party network event push (`SPEC-117`),
appservice ping (`SPEC-118`), or client-server extension sync for virtual users
(`SPEC-120`).

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/application-service-api/#put_matrixappv1transactionstxnid>
- Source: <https://spec.matrix.org/v1.18/application-service-api/#pushing-events>
- Source: <https://spec.matrix.org/v1.18/application-service-api/#unknown-routes>
- Parent contract: `SPEC-058`
- Parser artifact contract: `SPEC-105`
- Gap inventory: `SPEC-075`
- Checked at: 2026-05-17T12:00:00+09:00
- Timezone: Asia/Tokyo

## Runtime Behavior

### Transaction Delivery

Servers adopting this contract MUST push events to the appservice by sending a
`PUT` request to `/_matrix/app/v1/transactions/{txnId}`. The transaction body
MUST contain at minimum an `events` array. The transaction ID MUST be a
non-empty string that does not contain path separator characters.

### Ephemeral Batch Delivery

When an appservice registration sets `receive_ephemeral: true`, the server MUST
include ephemeral events in the transaction body as an `ephemeral` array
alongside `events`. Eligible ephemeral event types are `m.typing`, `m.receipt`,
and `m.presence`. If the registration does not set `receive_ephemeral: true`,
the `ephemeral` field MUST NOT be populated.

### Retry and Backoff

If the appservice returns a non-2xx HTTP response or the connection fails, the
server MUST retry the transaction using a backoff schedule. The representative
backoff schedule is: first retry after 1 second, second retry after 5 seconds,
third retry after 30 seconds. After the maximum retry count is exceeded, the
transaction delivery MUST be marked as permanently failed. The server must not
discard the transaction silently without a retry attempt.

### Idempotency

If the appservice returns HTTP `200` for a given `txnId`, the server MUST NOT
re-deliver that transaction for the same `txnId`. If the appservice receives a
duplicate `txnId` that it has already processed, it MUST return HTTP `200`
without re-processing the events.

### Transaction Ordering

Events within a single transaction MUST maintain the order in which they
occurred on the homeserver. The server MUST NOT reorder events within a
transaction before delivery.

### Unknown Route

Requests to routes outside the adopted endpoint set MUST return `HTTP 404` with
a Matrix error envelope:

```json
{
  "errcode": "M_UNRECOGNIZED",
  "error": "Unknown route."
}
```

Unknown-route handling must not be silent: the server must not return `200` for
an unsupported route.

### Unknown Method

Requests using an unsupported HTTP method on an adopted route MUST return
`HTTP 405` with a Matrix error envelope:

```json
{
  "errcode": "M_UNRECOGNIZED",
  "error": "Method not allowed."
}
```

### Legacy Route Fallback

If the server detects that an appservice is using a legacy endpoint path
(`/_matrix/app/unstable/transactions/{txnId}`) — typically by receiving a
`404` response from the v1 path — it MAY attempt delivery to the legacy path.
Legacy route fallback is bounded: the server MUST attempt the v1 path first and
only fall back to the legacy path when the appservice signals it does not
support the v1 route.

## Resource Bounds

Runtime adoption is bounded:

- maximum events per transaction: 100;
- maximum retry attempts: 3;
- retry backoff seconds: [1, 5, 30];
- idempotency required: true;
- transaction ordering required: true;
- ephemeral delivery requires `receive_ephemeral: true` flag;
- third-party network event push: false;
- appservice ping delivery: false;
- virtual user client-server sync: false;
- versions advertisement widened: false.

Implementations MUST fail closed when these bounds are missing or weakened.

## Fail-Closed Behavior

Implementations must reject:

- duplicate transaction redelivery after a confirmed HTTP `200` from the
  appservice;
- missing or blank transaction IDs in PUT request paths;
- transaction request bodies that are not valid JSON;
- transaction request bodies missing the `events` field;
- `ephemeral` field population when the registration does not set
  `receive_ephemeral: true`;
- unknown routes that return a silent `200` instead of `M_UNRECOGNIZED`.

Implementations must not:

- advertise Application Service API support from transaction delivery evidence
  alone;
- widen `GET /_matrix/client/versions` from this evidence;
- claim full Application Service API support.

## Adoption Decision Checklist

After this contract merges:

- `houra-server#254` may adopt representative transaction event delivery
  runtime behavior using this vector.
- `SPEC-105` remains the parser-only artifact boundary for transaction envelopes.
- `SPEC-114` owns registration lifecycle and namespace runtime.
- Third-party network event push requires a separate adoption issue before
  `SPEC-117` runtime behavior is claimed.
- Appservice ping requires a separate adoption issue before `SPEC-118` runtime
  behavior is claimed.
- Release evidence must keep `advertisement_allowed=false` for Application
  Service API until the broader `SPEC-075` lanes are resolved for the release.

## Compatibility Boundaries

- `SPEC-058` remains the representative registration, namespace, transaction,
  and query gate.
- `SPEC-105` remains the parser-only artifact breadth boundary.
- `SPEC-114` owns registration lifecycle, exclusive namespace enforcement, and
  secret-redaction runtime.
- `SPEC-075` remains the Application Service full-breadth gap inventory.
- `SPEC-117` owns third-party network directory and event push runtime.
- `SPEC-118` owns appservice ping and liveness runtime.
- Passing this contract does not claim third-party network support, appservice
  ping correctness, virtual user sync behavior, Application Service API full
  breadth, or Matrix v1.18 full compliance.
