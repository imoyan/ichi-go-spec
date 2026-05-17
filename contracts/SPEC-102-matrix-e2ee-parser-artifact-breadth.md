# Matrix v1.18 / Olm & Megolm / encrypted event, key, backup, verification, and cross-signing artifacts

Status: draft
Feature profile: messaging
Contract type: boundary
Matrix domain: Olm & Megolm
Primary reference: Matrix v1.18 / Olm & Megolm / encrypted event, key, backup, verification, and cross-signing artifacts
Repository anchor: SPEC-102 Matrix E2EE Parser Artifact Breadth
Canonical: yes

## Purpose

Define a focused parser-only artifact boundary for the `shared-parser-artifacts-
security-release-evidence-breadth` lane in `SPEC-079`.

This contract lets `houra-labs` parse encrypted event, key, backup,
verification, and cross-signing public artifacts without selecting a crypto
stack, implementing Olm/Megolm primitives, owning secure storage, or widening
Matrix E2EE support advertisement.

## Scope

The parser artifact boundary covers:

- encrypted event envelopes for Olm and Megolm public metadata;
- device key and signed key public payload descriptors;
- key backup public metadata and opaque session payload descriptors;
- verification event public content descriptors;
- cross-signing public key descriptors;
- typed Matrix `M_*` error envelopes;
- binding-safe JSON output with no private key, session key, plaintext, local
  secret path, or recovery secret values.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/olm-megolm/>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#end-to-end-encryption>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#key-management-api>
- Checked at: 2026-05-16T15:55:00+09:00
- Timezone: Asia/Tokyo

## Artifact Shape

The canonical vector records:

- request descriptors for upload/query/claim, to-device, key backup,
  verification, and signatures surfaces;
- parser artifacts for encrypted events, device keys, signed keys, backup
  metadata, verification events, and cross-signing public keys;
- negative cases for secret leakage, malformed public payloads, and unsupported
  ownership claims;
- expected binding-safe output keys.

## Fail-Closed Behavior

Implementations must fail closed:

- do not implement cryptographic primitives locally;
- do not store private keys, session keys, recovery keys, plaintext, local
  secret paths, or secure-storage handles in artifacts;
- do not perform transport, retry, or trust UI behavior;
- do not advertise E2EE support from parser-only evidence;
- reject artifacts that include secret-bearing fields.

## Adoption Decision Checklist

After this contract merges:

- `houra-labs#132` may pin `SPEC-102` and
  `test-vectors/messaging/matrix-e2ee-parser-artifact-breadth.json`.
- Server and client work must remain separate for crypto stack selection,
  secure storage, trust UI, and runtime E2EE behavior.

## Compatibility Boundaries

- `SPEC-050` through `SPEC-054`, `SPEC-069`, and `SPEC-072` remain
  representative E2EE boundary gates.
- `SPEC-079` remains the full Olm & Megolm gap inventory.
- Passing this contract does not claim Matrix E2EE support or Matrix v1.18 full
  compliance.
