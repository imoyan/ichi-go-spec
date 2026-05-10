# SPEC-063: Matrix Complement-Compatible CI Lane

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Define the Complement-compatible homeserver black-box CI lane and pass/fail
report shape used as a release gate candidate for Houra Matrix v1.18 support.

## Scope

This contract is Matrix-defined, not Houra-defined. It describes how Houra
implementation repositories wire a black-box homeserver test lane compatible
with Complement. It does not add new Matrix endpoint behavior and does not
replace domain-specific contract vectors.

The lane is server-owned. It may consume client tokens, users, devices, rooms,
federation peers, application services, identity services, or push gateways as
test fixtures, but the CI lane adoption issue belongs to `houra-server` unless
a later issue adds a client-facing Complement harness.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/>
- Server-Server API: <https://spec.matrix.org/v1.18/server-server-api/>
- Client-Server API: <https://spec.matrix.org/v1.18/client-server-api/>
- Complement: <https://github.com/matrix-org/complement>
- Checked at: 2026-05-10T22:52:00+09:00
- Timezone: Asia/Tokyo

## Lane setup

The Complement-compatible lane must define:

- Houra homeserver image build command;
- homeserver startup command;
- client API base URL;
- federation listener URL;
- health check command;
- per-test isolated storage;
- TLS or Complement PKI behavior;
- supported stable domain filter;
- excluded unstable MSC filter;
- artifact directory;
- timeout and retry policy.

The lane must run against a reproducible Houra image or commit. It must not use
developer-local state, untracked configuration, or raw secrets in artifacts.

## Pass/fail report

The lane writes a JSON report containing:

- `matrix_spec_version`;
- `houra_ref`, such as image digest or commit SHA;
- `complement_ref`, such as git SHA or image tag;
- `stable_spec_only`;
- `unstable_mscs_included`;
- `domains`;
- `totals`, containing pass, fail, skip, and expected-fail counts;
- `failures`, with test name, domain, failure class, and artifact path;
- `artifacts`, with log and summary paths;
- `release_gate_status`.

The report is evidence, not advertising. A failing or missing Complement lane
must keep Matrix version/domain advertisement blocked.

## Release gate candidate

Complement-compatible pass status can only support release readiness when:

- `SPEC-062` domain coverage evidence exists for the same Houra ref;
- the Complement run is stable-spec-only unless a separate unstable MSC issue
  has opted in;
- all required artifacts are present;
- all failures are either fixed or explicitly classified as unsupported domain
  gaps with linked issues;
- raw access tokens, signing keys, pushkeys, 3PIDs, and vendor credentials are
  redacted.

This contract defines the lane shape. Later release-advertisement contracts
decide whether a specific Matrix version/domain can be advertised.

## Compatibility boundaries

- Existing `/_houra/**` and `/_matrix/**` behavior stays available.
- This contract defines CI lane setup and evidence reporting only.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030`, `SPEC-031`, and later
  release-advertisement gates.
- After this spec PR is merged, create an adoption issue for `houra-server`.
  Do not create `houra-client` or `houra-labs` adoption issues unless a later
  client-facing or shared-core Complement harness is intentionally scoped.
