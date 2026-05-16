# SPEC-105: Matrix Application Service Parser Artifact Breadth

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Define a focused parser-only artifact boundary for the Application Service
full-breadth lanes in `SPEC-075`.

This contract lets `houra-labs` parse registration, namespace, transaction,
query, ping, masquerade, and redaction evidence artifacts without owning
delivery retry, bridge runtime, token storage, third-party network runtime,
server mutation, or Application Service support advertisement.

## Scope

The parser artifact boundary covers:

- registration YAML / JSON shape descriptors;
- unique `id`, `as_token`, and `hs_token` validation descriptors;
- namespace regex, exclusivity, and conflict descriptors;
- transaction envelope, retry metadata, timeout metadata, and duplicate
  idempotency descriptors;
- user and room-alias query response/error descriptors;
- ping/liveness result descriptors;
- masquerade and identity assertion descriptors;
- appservice-only Client-Server extension descriptors;
- privacy-safe redaction evidence.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/application-service-api/>
- Checked at: 2026-05-16T16:05:00+09:00
- Timezone: Asia/Tokyo

## Artifact Shape

The canonical vector records:

- parser surfaces and their input sources;
- positive artifacts for registration, namespace, transaction, query, ping, and
  masquerade descriptors;
- malformed artifacts for duplicate tokens, invalid namespace regex, unsupported
  method, and secret leakage;
- ownership flags proving delivery, bridge runtime, storage mutation, and
  support advertisement remain out of scope.

## Fail-Closed Behavior

Implementations must fail closed:

- do not persist tokens or bridge state while parsing artifacts;
- do not perform delivery retry, third-party network fetch, or server mutation;
- reject artifacts that leak raw appservice tokens outside redacted evidence;
- do not advertise Application Service API, bridge, or third-party network
  support from parser-only evidence.

## Adoption Decision Checklist

After this contract merges:

- `houra-labs#126` may pin `SPEC-105` and
  `test-vectors/core/matrix-application-service-parser-artifact-breadth.json`.
- Server issues `houra-server#235` through `houra-server#240` remain runtime
  implementation gates.

## Compatibility Boundaries

- `SPEC-058` remains the representative registration, namespace, transaction,
  and query gate.
- `SPEC-075` remains the full Application Service breadth gap inventory.
- Passing this contract does not claim Application Service API support, bridge
  runtime support, or Matrix v1.18 full compliance.
