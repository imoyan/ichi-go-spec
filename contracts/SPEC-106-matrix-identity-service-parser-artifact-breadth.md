# SPEC-106: Matrix Identity Service Parser Artifact Breadth

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Define a focused parser-only artifact boundary for the Identity Service
full-breadth lanes in `SPEC-076`.

This contract lets `houra-labs` parse request descriptors, public response
payloads, Matrix error envelopes, and privacy-sensitive redaction artifacts
without owning provider delivery, consent UI, contact upload UX, identity server
selection, ephemeral signing runtime, or Identity Service support
advertisement.

## Scope

The parser artifact boundary covers:

- discovery, account, and terms descriptors;
- lookup hash details and lookup response descriptors;
- validation request/submit descriptors;
- bind and unbind lifecycle descriptors;
- public key, ephemeral key, and signed association descriptors;
- invitation storage and ephemeral signing placeholder descriptors;
- Matrix `M_*` error envelopes;
- redaction helper artifacts for tokens, client secrets, hashed 3PIDs,
  signatures, provider payloads, and local paths.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/identity-service-api/>
- Checked at: 2026-05-16T16:05:00+09:00
- Timezone: Asia/Tokyo

## Artifact Shape

The canonical vector records:

- parser surfaces and their public fields;
- positive artifacts for lookup, validation, bind/unbind, public key, and
  signed association descriptors;
- malformed artifacts for invalid `M_*` errors, token leakage, local path
  leakage, and unsupported ownership claims;
- redaction policy metadata.

## Fail-Closed Behavior

Implementations must fail closed:

- do not deliver email or MSISDN provider messages from parser evidence;
- do not store identity tokens, client secrets, raw signatures, or local secret
  paths in artifacts;
- do not infer consent UI, invitation storage, or ephemeral signing runtime
  support;
- do not advertise Identity Service API support from parser-only evidence.

## Adoption Decision Checklist

After this contract merges:

- `houra-labs#127` may pin `SPEC-106` and
  `test-vectors/core/matrix-identity-service-parser-artifact-breadth.json`.
- Server issues `houra-server#241` through `houra-server#245` remain runtime
  implementation gates.
- Client issues `houra-client#142` through `houra-client#145` remain UX and
  service-selection gates.

## Compatibility Boundaries

- `SPEC-059` remains the representative Identity Service boundary.
- `SPEC-092`, `SPEC-094`, and `SPEC-096` remain narrower lifecycle, provider,
  and key/signature child contracts.
- `SPEC-076` remains the full Identity Service breadth gap inventory.
- Passing this contract does not claim Identity Service API support or Matrix
  v1.18 full compliance.
