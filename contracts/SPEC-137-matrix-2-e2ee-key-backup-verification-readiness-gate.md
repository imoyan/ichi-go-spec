# Matrix v1.18 / Olm & Megolm / Matrix 2.0 E2EE key backup verification readiness gate

Status: draft
Feature profile: messaging
Contract type: gate
Matrix domain: Olm & Megolm
Primary reference: Matrix v1.18 / Olm & Megolm / Matrix 2.0 E2EE key backup verification readiness gate
Repository anchor: SPEC-137 Matrix 2.0 E2EE Key Backup Verification Readiness Gate
Canonical: yes

## Purpose

Define the fail-closed readiness gate for future Matrix 2.0 E2EE, key backup,
verification, cross-signing, and maintained crypto stack support claims.

This contract does not implement cryptographic behavior, select a production
crypto package, move local key state into the server, or widen Matrix 2.0,
Matrix v1.18, Product MVP, or `GET /_matrix/client/versions` advertisement.

## Scope

The gate covers:

- stable-source capture for Matrix 2.0 E2EE requirements;
- separation between stable E2EE requirements, parser artifact evidence,
  maintained crypto stack evidence, implementation notes, and out-of-scope
  behavior;
- maintained crypto stack and host-owned secure storage evidence required
  before claiming support;
- release-bundle and `/versions` non-advertisement until same-candidate
  evidence passes;
- secret-free evidence rules for key material, recovery material, plaintext,
  encrypted media samples, and local secure-storage state.

The gate does not cover:

- local Olm, Megolm, SAS, cross-signing, key-backup, or secret-storage crypto
  implementation;
- encrypted room runtime support;
- production device-trust UX;
- backup setup or recovery UX;
- MatrixRTC or media encryption beyond existing Product MVP boundaries;
- parser-only artifacts already covered by `SPEC-102`.

## Matrix Reference

Current baseline:

- Matrix specification version: `v1.18`
- Olm and Megolm source: <https://spec.matrix.org/v1.18/olm-megolm/>
- End-to-end encryption source:
  <https://spec.matrix.org/v1.18/client-server-api/#end-to-end-encryption>
- Server-side key backup source:
  <https://spec.matrix.org/v1.18/client-server-api/#server-side-key-backups>
- Current stable-spec entrypoint: <https://spec.matrix.org/latest/>
- Checked at: 2026-05-18T15:59:11+09:00
- Timezone: Asia/Tokyo

Matrix 2.0 source status:

- Stable Matrix 2.0 E2EE source: pending official stable spec release
- Stable Matrix 2.0 release note: pending official stable spec release note
- Source snapshot contract: `SPEC-133`
- Advertisement gate contract: `SPEC-134`
- Planning-only source candidate:
  <https://matrix.org/blog/2024/10/29/matrix-2.0-is-here/>

## Classification Rules

Every E2EE item must be classified before it can affect a support claim:

- `stable-requirement`: stable Matrix 2.0 spec source, normative requirement
  summary, crypto stack boundary, storage ownership boundary, required vectors,
  implementation evidence, and release evidence rule are present.
- `parser-artifact-only`: public event, key, backup, or verification envelope
  parsing evidence exists but does not claim cryptographic correctness.
- `maintained-stack-evidence`: package/version/security-maintenance evidence
  exists but does not itself claim a Matrix domain.
- `implementation-note`: useful implementation guidance that must not widen
  `/versions`, release notes, or publishable Matrix support claims.
- `out-of-scope`: explicit exclusion text is present in the release evidence.

Only stable requirements with a maintained crypto stack, host-owned secure
storage boundary, and same-candidate implementation/release evidence may
contribute to a future Matrix 2.0 E2EE claim.

## Fail-Closed Rules

Until this gate passes:

- Matrix 2.0 E2EE support is not claimed;
- key backup, verification, cross-signing, and encrypted room support remain
  unadvertised;
- parser-only artifacts must not imply crypto runtime support;
- maintained-stack selection evidence must not imply adoption by itself;
- local crypto implementation remains prohibited by `SPEC-050` and `SPEC-081`;
- server evidence must not include plaintext, local secure-storage state,
  recovery material, or private key material;
- `GET /_matrix/client/versions` must not include Matrix 2.0 because of this
  lane;
- release bundles and release notes must keep Olm & Megolm excluded unless the
  same candidate passes this gate and `SPEC-134`.

## Adoption Decision Checklist

This contract closes #384 only for the current readiness gate. Future adoption
requires:

- refreshed `SPEC-133` stable-source snapshot;
- updated E2EE, key backup, verification, cross-signing, and storage ownership
  vectors tied to the stable source;
- maintained crypto stack package/version/security-maintenance evidence;
- secret-free client, server, and release-bundle evidence for the same
  candidate;
- explicit exclusions for parser-only, SDK-owned, host-owned, or out-of-scope
  behavior;
- `dart tool/check_spec.dart` passing on the candidate ref.
