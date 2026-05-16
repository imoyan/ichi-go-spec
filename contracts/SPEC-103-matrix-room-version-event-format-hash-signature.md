# SPEC-103: Matrix Room Version Event Format, Hash, and Signature Helpers

Status: draft
Feature profile: events
Canonical: yes

## Purpose

Define a focused parser/helper fixture boundary for the `per-version-event-
format-id-hash-signature-limit-breadth` lane in `SPEC-078`.

This contract lets `houra-labs` parse event-format and canonical JSON helper
fixtures for Matrix room versions without calculating hashes, verifying
signatures, mutating room state, or advertising Room Versions support.

## Scope

The helper boundary covers:

- stable room version event ID and room ID format descriptors;
- `auth_events`, `prev_events`, `depth`, `hashes`, `signatures`, `unsigned`,
  and `content` shape descriptors;
- canonical JSON input and output descriptors;
- event hash, reference hash, and signing input fixture schema;
- event size, nesting, and depth fail-closed limits;
- version-specific redacted content retention descriptors.

It does not perform network auth, federation fetch, production room state
mutation, server-side signature trust policy, or Matrix `/versions`
advertisement.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/rooms/>
- Source: <https://spec.matrix.org/v1.18/rooms/v12/>
- Source: <https://spec.matrix.org/v1.18/appendices/#canonical-json>
- Checked at: 2026-05-16T15:55:00+09:00
- Timezone: Asia/Tokyo

## Fixture Shape

The canonical vector records:

- `room_versions` with event and room ID descriptor metadata;
- `canonical_json_cases` with input, expected canonical JSON text, byte count,
  and invalid-case reasons;
- `hash_signature_inputs` with public fields included in event-hash,
  reference-hash, and signing-input descriptors;
- `redaction_retention_cases` for retained and stripped content fields;
- `limits` for canonical bytes, nesting depth, event depth, `auth_events`, and
  `prev_events`.

## Fail-Closed Behavior

Implementations must fail closed:

- do not calculate hashes or verify signatures unless a later implementation
  contract explicitly owns that behavior;
- reject helper input above declared size, depth, auth-event, or prev-event
  bounds;
- reject canonical JSON descriptors that include private signing material;
- do not infer full Room Versions support from helper fixtures.

## Adoption Decision Checklist

After this contract merges:

- `houra-labs#129` may pin `SPEC-103` and
  `test-vectors/events/matrix-room-version-event-format-hash-signature.json`.
- `houra-server#169` and `houra-server#250` may use the same vector as
  parser/helper input, but runtime state mutation and signature trust policy
  remain server-owned.

## Compatibility Boundaries

- `SPEC-040` remains the event DAG and auth-event reference integrity gate.
- `SPEC-083` remains the bounded event-decision artifact gate.
- `SPEC-078` remains the full Room Versions algorithm gap inventory.
- Passing this contract does not claim event authorization, state resolution,
  federation correctness, or Matrix v1.18 full compliance.
