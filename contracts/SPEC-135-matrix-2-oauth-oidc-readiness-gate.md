# Matrix v1.18 / Client-Server API / Matrix 2.0 OAuth/OIDC readiness gate

Status: draft
Feature profile: auth
Contract type: gate
Matrix domain: Client-Server API
Primary reference: Matrix v1.18 / Client-Server API / Matrix 2.0 OAuth/OIDC readiness gate
Repository anchor: SPEC-135 Matrix 2.0 OAuth/OIDC Readiness Gate
Canonical: yes

## Purpose

Define the fail-closed readiness gate for future Matrix 2.0 OAuth/OIDC account
management, login, and authorization-boundary claims.

This contract does not implement OAuth/OIDC and does not widen Matrix 2.0,
Matrix v1.18, Product MVP, or `GET /_matrix/client/versions` advertisement.
It separates stable Matrix requirements from optional, experimental, provider
specific, or implementation-owned OAuth/OIDC behavior.

## Scope

The gate covers:

- stable-source capture for Matrix 2.0 OAuth/OIDC requirements;
- separation between stable Matrix requirements, MSC-only inputs, provider
  behavior, and implementation notes;
- evidence redaction requirements for credentials, grant material, callback
  parameters, and identity-provider session identifiers;
- preservation of `SPEC-068` account-management behavior as a v1.18 boundary;
- release-bundle and `/versions` non-advertisement until same-candidate
  evidence passes.

The gate does not cover:

- OAuth/OIDC runtime implementation;
- dynamic client registration;
- device authorization grant implementation;
- provider interoperability claims;
- token storage, browser presentation, or deep-link handling owned by host
  applications;
- account-management metadata and redirect behavior already defined by
  `SPEC-068`.

## Matrix Reference

Current baseline:

- Matrix specification version: `v1.18`
- OAuth-aware clients source:
  <https://spec.matrix.org/v1.18/client-server-api/#oauth-20-aware-clients>
- OAuth server metadata account-management extension source:
  <https://spec.matrix.org/v1.18/client-server-api/#oauth-20-server-metadata-account-management-extension>
- Current stable-spec entrypoint: <https://spec.matrix.org/latest/>
- Checked at: 2026-05-18T15:44:52+09:00
- Timezone: Asia/Tokyo

Matrix 2.0 source status:

- Stable Matrix 2.0 OAuth/OIDC source: pending official stable spec release
- Stable Matrix 2.0 release note: pending official stable spec release note
- Source snapshot contract: `SPEC-133`
- Advertisement gate contract: `SPEC-134`
- Planning-only source candidate:
  <https://matrix.org/blog/2024/10/29/matrix-2.0-is-here/>

## Classification Rules

Every OAuth/OIDC item must be classified before it can affect a support claim:

- `stable-requirement`: stable Matrix 2.0 spec source, normative requirement
  summary, affected endpoint or metadata surface, token boundary, required
  vectors, implementation evidence, and release evidence rule are present.
- `msc-only`: MSC identifier or planning source, expected Matrix domain,
  reason it is not a stable support claim, revisit issue, and
  `advertisement_allowed=false` are present.
- `provider-specific`: behavior belongs to an identity provider, OAuth server,
  app link, browser, or deployment and is not a protocol support claim.
- `implementation-note`: useful implementation guidance that must not widen
  `/versions`, release notes, or publishable Matrix support claims.
- `out-of-scope`: explicit exclusion text is present in the release evidence.

Only `stable-requirement` items with same-candidate implementation and release
evidence may contribute to a future Matrix 2.0 OAuth/OIDC claim.

## Redaction Rules

OAuth/OIDC evidence must not record bearer credentials, refresh credentials,
authorization grant material, callback query parameters, identity-provider
session identifiers, private keys, recovery material, or raw browser session
state.

Evidence may record only:

- endpoint or metadata shape;
- redirect URL origin and path after query values are redacted;
- public provider capability names;
- pass/fail status;
- implementation and release artifact refs;
- explicit exclusion reasons.

## Fail-Closed Rules

Until this gate passes:

- Matrix 2.0 OAuth/OIDC support is not claimed;
- OAuth login flow support is not advertised;
- `GET /_matrix/client/versions` must not include Matrix 2.0 because of this
  lane;
- release bundles must keep OAuth/OIDC Matrix 2.0 evidence blocked;
- release notes must call OAuth/OIDC Matrix 2.0 support unadvertised;
- `SPEC-068` account-management metadata behavior remains a separate v1.18
  boundary and must not be treated as full Matrix 2.0 OAuth/OIDC support.

## Adoption Decision Checklist

This contract closes #382 only for the current readiness gate. Future adoption
requires:

- refreshed `SPEC-133` stable-source snapshot;
- updated OAuth/OIDC vectors tied to the stable source;
- secret-free server and client implementation evidence;
- release bundle and release notes matching `SPEC-134`;
- explicit exclusions for provider-specific or experimental behavior;
- `dart tool/check_spec.dart` passing on the candidate ref.
