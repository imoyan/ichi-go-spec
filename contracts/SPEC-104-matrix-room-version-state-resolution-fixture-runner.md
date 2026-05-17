# Matrix v1.18 / Room Versions / state resolution fixture runner

Status: draft
Feature profile: events
Contract type: boundary
Matrix domain: Room Versions
Primary reference: Matrix v1.18 / Room Versions / state resolution fixture runner
Repository anchor: SPEC-104 Matrix Room Version State Resolution Fixture Runner
Canonical: yes

## Purpose

Define a focused parser-only fixture boundary for the
`state-resolution-algorithm-breadth` lane in `SPEC-078`.

This contract lets `houra-labs` and implementation repositories validate a
bounded state-resolution fixture batch and diff output shape without owning
production storage, federation fetch, runtime event acceptance, or Matrix
version advertisement.

## Scope

The fixture runner covers:

- state resolution v1 and v2 fixture schema;
- unconflicted state map and conflicted state set descriptors;
- auth chain, power events, mainline ordering, and iterative auth-check input
  descriptors;
- rejected events, soft-failed events, partial history, and restart recovery
  boundary cases;
- performance bounds and diff output schema;
- room-version parity matrix descriptors.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/rooms/v12/#state-resolution>
- Source: <https://spec.matrix.org/v1.18/rooms/#state-resolution>
- Checked at: 2026-05-16T15:55:00+09:00
- Timezone: Asia/Tokyo

## Fixture Shape

The canonical vector records:

- `resource_bounds` with maximum events, auth-chain entries, conflicted state
  entries, iterations, and elapsed milliseconds for representative fixtures;
- `cases` with algorithm version, room version, input counts, expected resolved
  state keys, and diff output;
- `performance_evidence` that records only counts and durations, not private
  database keys or local paths;
- `release_evidence_rules` proving non-advertisement.

## Fail-Closed Behavior

Implementations must fail closed:

- reject fixture batches above declared resource bounds;
- do not fetch missing auth-chain or state events from federation;
- do not mutate production state;
- do not infer complete state-resolution correctness from representative
  fixtures;
- keep Matrix `/versions` and room-version capabilities unchanged.

## Adoption Decision Checklist

After this contract merges:

- `houra-labs#131` may pin `SPEC-104` and
  `test-vectors/events/matrix-room-version-state-resolution-fixture-runner.json`.
- `houra-server#169` may use the same vector as fixture evidence before a
  separate runtime state-resolution implementation gate.

## Compatibility Boundaries

- `SPEC-041` remains the state snapshot and representative state-resolution
  vector gate.
- `SPEC-078` remains the full Room Versions algorithm gap inventory.
- Passing this contract does not claim full Room Versions support, federation
  recovery, or Matrix v1.18 full compliance.
