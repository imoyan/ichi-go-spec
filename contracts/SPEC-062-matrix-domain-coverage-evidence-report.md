# SPEC-062: Matrix Domain Coverage Evidence Report

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Define the Matrix v1.18 stable-domain coverage and evidence report shape used
to decide whether Houra can claim support for a Matrix domain.

## Scope

This contract is Matrix-defined, not Houra-defined. It records how Houra tracks
contract coverage, implementation adoption, pass/fail evidence, and unsupported
scope for Matrix v1.18 stable domains. It does not add new Matrix endpoint
behavior.

The report covers these stable domains:

- Appendices/common rules
- Client-Server API
- Server-Server API
- Application Service API
- Identity Service API
- Push Gateway API
- Room Versions
- Olm & Megolm

Unstable MSCs are explicitly excluded unless a later issue opts into a specific
MSC with its own contract, vector, adoption issue, and release note.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/>
- Client-Server API: <https://spec.matrix.org/v1.18/client-server-api/>
- Server-Server API: <https://spec.matrix.org/v1.18/server-server-api/>
- Application Service API: <https://spec.matrix.org/v1.18/application-service-api/>
- Identity Service API: <https://spec.matrix.org/v1.18/identity-service-api/>
- Push Gateway API: <https://spec.matrix.org/v1.18/push-gateway-api/>
- Room Versions: <https://spec.matrix.org/v1.18/rooms/>
- Olm & Megolm: <https://spec.matrix.org/v1.18/olm-megolm/>
- Checked at: 2026-05-10T22:34:00+09:00
- Timezone: Asia/Tokyo

## Report shape

The coverage report is a JSON object with:

- `matrix_spec_version`, fixed to `v1.18`;
- `matrix_spec_source`, fixed to the official Matrix v1.18 source root;
- `checked_at`, an ISO-8601 timestamp with timezone;
- `unstable_mscs_included`, fixed to `false` unless a later contract changes
  scope;
- `domains`, an array containing one record for each stable domain;
- `excluded_unstable_mscs`, an object recording the exclusion reason and issue
  policy.

Each domain record contains:

- `domain`, one of the stable domain names listed in this contract;
- `source`, the official Matrix v1.18 URL for that domain;
- `contract_refs`, the Houra `SPEC-*` contracts covering that domain;
- `implementation_repos`, the repos expected to produce adoption evidence;
- `adoption_issue_refs`, GitHub issue refs created after spec PR merge;
- `known_gap_refs`, stable-domain gaps that are intentionally not covered yet,
  each with a scope label and issue ref or explicit reason;
- `contract_gate`, with command, pass/fail status, and artifact path;
- `implementation_gate`, with pass/fail status and artifact path; `artifact`
  may be `null` only when the gate status is `not-run` or `not-applicable`;
- `advertisement_allowed`, a boolean that may be `true` only when included
  domain evidence is complete.

## Evidence rules

`contract_gate.status` can be `pass`, `fail`, or `not-run`.
`implementation_gate.status` can be `pass`, `fail`, `not-run`, or
`not-applicable`.

`advertisement_allowed` must remain `false` when:

- the domain has missing contract references;
- the implementation gate is `not-run` or `fail`;
- adoption issue references are missing for implementation repos that must
  produce evidence;
- stable-domain gaps are not listed with a known-gap issue or explicit
  out-of-scope reason;
- the domain includes excluded unstable MSC behavior;
- the evidence artifact contains raw secrets, tokens, signing keys, pushkeys,
  or personally identifying third-party identifiers.

## Compatibility boundaries

- Existing `/_houra/**` and `/_matrix/**` behavior stays available.
- This contract defines evidence reporting only. It does not claim any Matrix
  domain support by itself.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create adoption issues for `houra-server` and
  `houra-client` to emit implementation evidence in this shape. Create an
  `houra-labs` issue only if shared-core evidence becomes part of a domain gate.
