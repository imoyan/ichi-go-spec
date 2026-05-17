# Matrix v1.18 / Room Versions / room version event decision artifacts

Status: draft
Feature profile: events
Contract type: boundary
Matrix domain: Room Versions
Primary reference: Matrix v1.18 / Room Versions / room version event decision artifacts
Repository anchor: SPEC-083 Matrix Room Version Event Decision Artifacts
Canonical: yes

## Purpose

Define a bounded event-decision artifact boundary for the
`event-acceptance-rejection-soft-fail-visibility-breadth` lane in `SPEC-078`.

This contract lets implementation repositories record accepted, rejected,
soft-failed, and redacted room-version event outcomes without expanding into a
full Matrix room-version algorithm, full state resolution, or unbounded
federation history processing.

## Scope

This contract covers only local artifact shape and representative decision
classification for room version `12` event handling. It is a child of
`SPEC-078` and depends on the earlier representative evidence in `SPEC-040`,
`SPEC-041`, `SPEC-042`, `SPEC-043`, `SPEC-057`, and `SPEC-080`.

The artifact boundary is intentionally small:

- classify accepted, rejected, soft-failed, and redacted outcomes;
- include only redacted-safe identifiers and decision reasons;
- record whether an event is visible in timeline, state-at-event, backfill, and
  get-missing-events views;
- enforce bounded payload, auth event, previous event, and state lookup inputs;
- keep full room-version algorithms and domain-wide advertisement excluded.

It does not define complete Matrix authorization, complete state resolution,
event hash validation, event signature validation, federation transaction
persistence, or complete backfill/get-missing-events behavior.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/rooms/v12/>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#checks-performed-on-receipt-of-a-pdu>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#retrieving-events>
- Checked at: 2026-05-15T22:58:00+09:00
- Timezone: Asia/Tokyo

## Artifact rule

An implementation may emit a room-version event-decision artifact with this
minimal shape:

```json
{
  "room_version": "12",
  "decisions": [
    {
      "event_id": "$accepted:example.test",
      "type": "m.room.message",
      "outcome": "accepted",
      "reason": "representative_auth_passed",
      "visible_in": {
        "timeline": true,
        "state_at_event": false,
        "backfill": true,
        "get_missing_events": true
      }
    }
  ]
}
```

Allowed `outcome` values are:

- `accepted`: the event is stored as accepted and may be visible in normal
  timeline-like retrieval surfaces covered by the representative vector;
- `rejected`: the event is stored only as a rejection artifact and must not be
  visible in timeline, state-at-event, backfill, or get-missing-events surfaces;
- `soft_failed`: the event is retained for graph or diagnostic context but must
  not become visible in timeline or state-at-event surfaces;
- `redacted`: the redaction event is accepted and the redacted target is visible
  only through the redacted representation defined by the adopting
  implementation evidence.

## Resource bounds

Implementations must reject or truncate work before expensive processing when
these bounds are exceeded:

- maximum canonicalized event payload inspected by this gate: 65536 bytes;
- maximum `auth_events` count: 10;
- maximum `prev_events` count: 20;
- maximum state entries inspected for the representative state-at-event check:
  64;
- maximum artifact decisions emitted for one representative batch: 32;
- no recursive graph expansion beyond the explicit `auth_events`,
  `prev_events`, and state entries supplied to the gate.

These bounds are part of the contract. Implementations must not replace them
with unbounded in-memory maps, unbounded database scans, or network lookups.
If a future contract needs wider behavior, it must define a separate
performance and storage evidence gate.

## Visibility rule

Visibility flags are evidence flags, not a query engine:

- accepted message events may be visible in timeline, backfill, and
  get-missing-events representative views;
- accepted state events may be visible in state-at-event representative views;
- rejected events are hidden from all four views;
- soft-failed events are hidden from timeline and state-at-event views and may
  be retained only as non-advertised graph context;
- redacted target events must not expose unredacted event content through this
  artifact.

## Fail-closed behavior

Implementations must fail closed:

- do not advertise full Room Versions support from this artifact;
- do not widen `GET /_matrix/client/versions` or
  `GET /_matrix/client/v3/capabilities`;
- do not infer federation get-missing-events support from local artifact
  generation;
- do not perform network lookups, recursive database scans, or unbounded state
  resolution while generating this artifact;
- if an event outcome cannot be classified within the bounded inputs, classify
  it as rejected or leave it out of advertised evidence.

## Adoption decision checklist

After this contract merges:

- `houra-server#250` should adopt the artifact and resource-bound rules for a
  representative room version `12` event-decision batch.
- `houra-labs` work is needed only if a shared bounded classifier is extracted.
- `houra-client` work is not required unless a client-facing diagnostic surface
  intentionally consumes these artifacts.

## Compatibility boundaries

- `SPEC-040` remains the event DAG and auth-event structural gate.
- `SPEC-043` remains the representative room version `12` auth-rule gate.
- `SPEC-057` remains the federation backfill/event_auth/state_ids interop gate.
- `SPEC-078` remains the full Room Versions algorithm gap inventory.
- Passing this contract does not claim full room-version algorithms, federation
  transaction correctness, complete state resolution, or Matrix v1.18 full
  compliance.
