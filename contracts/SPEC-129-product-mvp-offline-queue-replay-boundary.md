# Houra Product MVP / Offline Queue Replay Boundary

Status: draft
Feature profile: core
Contract type: boundary
Matrix domain: none
Primary reference: Houra Product MVP / Offline Queue Replay Boundary
Repository anchor: SPEC-129 Product MVP Offline Queue Replay Boundary
Canonical: yes

## Purpose

Define the Product MVP server boundary for accepting a replayed operation after
a client has been offline, while enforcing server-owned idempotency, duplicate
classification, payload drift rejection, and raw device data exclusion.

This contract is not a device-local queue implementation and does not copy
behavior from sample runners. It defines the minimum server-owned replay
behavior that `houra-server` may adopt for Product MVP evidence while keeping
Product MVP release readiness, Matrix compatibility, client retry UI, and
sample-runner compatibility claims fail-closed.

## Scope

Offline queue replay covers one replayed Product MVP operation with:

- `replay_id`, a stable server-visible replay identifier;
- `idempotency_key`, a required client-generated key for exactly one logical
  replay operation;
- `replay_source`, the bounded source descriptor for the replayed operation;
- `payload`, a normalized server-facing operation payload;
- `raw_device_payload`, device-local sensor/cache/debug input that must remain
  outside public responses, export payloads, and evidence artifacts;
- `accepted_state`, the user-visible state for the first accepted replay;
- `deduplicated_state`, the user-visible state for a duplicate replay with the
  same idempotency key and identical normalized payload.

Implementations must compare normalized payloads for idempotency. They must not
silently overwrite a previously accepted replay when the same idempotency key is
used with a different normalized payload.

## Replay States

The representative Product MVP replay states are:

- `accepted`: the first replay for an idempotency key was accepted and persisted;
- `deduplicated`: the same idempotency key and the same normalized payload were
  replayed again without creating another user-visible operation;
- `rejected`: the replay failed a required boundary check.

`deduplicated` must return the original accepted replay result or a stable
reference to it. It must not create a second operation or mutate the accepted
payload.

## Fail-Closed Behavior

Implementations must reject or mark the replay invalid when:

- `idempotency_key` is missing, empty, malformed, or too long;
- the same `idempotency_key` is reused with a different normalized payload;
- `payload` contains raw device, sensor, cache, token, local path, or debug
  fields;
- `raw_device_payload` is copied into the accepted payload, response, export, or
  evidence artifact;
- a replay attempts to supply server-owned state such as `accepted_state`,
  `deduplicated_state`, `created_at`, or the replay result id;
- the normalized payload exceeds the representative payload size limit;
- logs, evidence artifacts, or diagnostics contain forbidden raw device values.

Representative forbidden raw values include GPS coordinates, sensor readings,
local queue paths, device cache keys, bearer tokens, and local debug traces.

## Evidence Artifact

Implementation evidence for this contract must record:

- the consumed `houra-spec` ref;
- the implementation ref;
- the replay id and idempotency key;
- whether the operation was accepted, deduplicated, or rejected;
- whether duplicate replay returned the original result without creating a new
  operation;
- whether payload drift was rejected;
- whether raw device data was excluded from responses, exports, logs, and
  evidence artifacts.

Evidence artifacts must not contain raw device payload values, bearer tokens,
database URLs, private local paths, precise coordinates, sensor readings, cache
keys, or internal debug traces.

## Claim Boundary

Passing this contract does not widen:

- Product MVP release readiness;
- Matrix compatibility or `/_matrix/client/versions` advertisement;
- device-local queue implementation;
- mobile retry UI behavior;
- external queue service integration;
- sample-runner compatibility.

## Compatibility Boundaries

- Existing Product MVP contract behavior remains unchanged.
- `houra-server` owns the server replay, idempotency, deduplication, and
  persistence invariant for this representative boundary.
- Device-local storage, retry scheduling, conflict UI, and background task
  behavior require separate client and UI surface evidence.
- PostgreSQL and in-memory implementations must produce the same accepted and
  deduplicated result for the representative vectors.
- Future offline sync breadth, merge/conflict resolution policy, or external
  queue-service integration must be split into separate contracts and issues.

## Adoption Decision Checklist

After this contract merges:

- `houra-server#338` may adopt the representative offline queue replay behavior
  against the pinned spec ref;
- server adoption must include first replay accepted, duplicate replay
  deduplicated, missing idempotency key rejected, raw device data blocked,
  payload drift rejected, persistence, and redaction artifact tests;
- README adoption evidence in `houra-server` must cite this contract, vector,
  implementation ref, verification commands, and a clean-room note;
- Product MVP readiness remains fail-closed unless a separate release candidate
  gate cites this evidence and all other blocking lanes pass.
