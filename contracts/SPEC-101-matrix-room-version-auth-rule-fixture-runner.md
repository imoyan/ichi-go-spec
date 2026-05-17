# Matrix v1.18 / Room Versions / room version auth rule fixture runner

Status: draft
Feature profile: events
Contract type: boundary
Matrix domain: Room Versions
Primary reference: Matrix v1.18 / Room Versions / room version auth rule fixture runner
Repository anchor: SPEC-101 Matrix Room Version Auth Rule Fixture Runner
Canonical: yes

## Purpose

Define a focused parser-only fixture boundary for the `authorization-rules-breadth`
lane in `SPEC-078`.

This contract lets `houra-labs` and implementation repositories validate a
bounded Matrix room-version authorization fixture matrix without claiming full
Room Versions algorithms, production authorization storage, federation fetch, or
Matrix version advertisement.

## Scope

The fixture runner covers room version `12` evidence for:

- `m.room.create` auth rules;
- membership join, invite, leave, ban, and knock decisions;
- restricted and `knock_restricted` joins;
- `m.room.power_levels` validation;
- third-party invite auth;
- redaction and generic state-event auth;
- creator infinite power in room version `12`;
- duplicate auth event rejection;
- rejected-auth-event handling;
- `m.federate=false` and server-signature boundary flags.

The fixture runner records only public identifiers, event types, expected
allow/deny decisions, and bounded reason codes.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/rooms/v12/#authorization-rules>
- Source: <https://spec.matrix.org/v1.18/rooms/v12/#handling-redactions>
- Checked at: 2026-05-16T15:55:00+09:00
- Timezone: Asia/Tokyo

## Fixture Shape

The canonical vector has this top-level shape:

```json
{
  "contract": "SPEC-101",
  "event": {
    "matrix_room_version": "12",
    "runner": "room-version-auth-rule-fixture-runner",
    "resource_bounds": {
      "max_cases": 32,
      "max_auth_events_per_case": 10,
      "max_state_events_per_case": 64,
      "network_lookup_allowed": false,
      "storage_mutation_allowed": false,
      "versions_advertisement_widened": false
    },
    "cases": []
  }
}
```

Each case must include:

- stable `id`;
- `category`;
- `input_summary` with event type, sender, state key presence, and auth-event
  count;
- `expected_decision` with `allowed` and `reason`;
- `ownership` flags proving that production storage, network behavior,
  federation fetch, and Matrix `/versions` advertisement are not claimed.

## Fail-Closed Behavior

Implementations must fail closed:

- do not infer full Room Versions support from this runner;
- do not mutate production room state while parsing fixtures;
- do not perform network lookup, federation fetch, or database expansion;
- reject fixture batches above the declared bounds;
- keep `GET /_matrix/client/versions` and room-version capabilities unchanged
  unless a later release gate explicitly allows them.

## Adoption Decision Checklist

After this contract merges:

- `houra-labs#130` may pin `SPEC-101` and
  `test-vectors/events/matrix-room-version-auth-rule-fixture-runner.json` as
  the auth-rule fixture runner input.
- `houra-server#168` may use the same vector as parser/fixture evidence, but
  runtime auth-rule storage and federation behavior remain server-owned.

## Compatibility Boundaries

- `SPEC-043` remains the representative room version `12` auth vector gate.
- `SPEC-078` remains the full Room Versions algorithm gap inventory.
- Passing this contract does not claim state resolution, event hash/signature
  verification, federation PDU acceptance, or Matrix v1.18 full compliance.
