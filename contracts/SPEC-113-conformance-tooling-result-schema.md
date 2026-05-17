# SPEC-113: Conformance Tooling Result Schema

Status: draft
Feature profile: core
Contract type: schema
Matrix domain: Appendices/common rules
Canonical: yes

## Purpose

Define the implementation conformance report shape used by Houra client,
server, and lab repositories when they consume `houra-spec` as read-only
contract/vector input.

This contract does not define a runner implementation, SDK API, CI provider
annotation format, storage layout, or release claim. It defines the minimum
artifact shape needed to trace every implementation result back to the
canonical contract, vector, feature profile, and `houra-spec` ref.

## Scope

Conformance tooling v1 covers implementation-produced reports for:

- Product MVP `/_houra/client/**` contract/vector adoption;
- Matrix `/_matrix/**` contract/vector adoption;
- parser, fixture, UI surface, and shared-core experiments when those
  experiments intentionally cite canonical vectors from this repository.

The report is implementation evidence only. It must not widen Product MVP,
Matrix version, Matrix domain, shared-core, or release support claims by
itself.

## Report shape

A conformance report is a JSON object with:

- `schema_version`, fixed to `conformance-report-v1`;
- `generated_at`, an ISO-8601 timestamp with timezone;
- `houra_spec_ref`, a tag, branch, or commit label;
- `houra_spec_commit`, the exact consumed commit SHA;
- `implementation`, with repo, ref, optional PR, and target runtime;
- `runner`, with runner name, version, and command;
- `target`, with profile list, optional Matrix domain list, and release
  candidate label when the report is release-facing;
- `results`, one record per canonical vector or declared out-of-scope vector;
- `totals`, counting `pass`, `fail`, `skipped`, `blocked`, and
  `out_of_scope`;
- `claim_boundary`, recording whether Product MVP, Matrix advertisement, and
  release readiness are widened by the report;
- `redaction`, recording that secret-bearing diagnostics were removed.

Each result record contains:

- `vector_name`, matching the vector file's `name`;
- `vector_path`, under `test-vectors/<profile>/`;
- `contract`, a known `SPEC-*` id;
- `feature_profile`, matching `CONTRACT_MODULE_MAP.md`;
- `status`, one of `pass`, `fail`, `skipped`, `blocked`, or `out_of_scope`;
- `duration_ms`, when measured;
- `failure_detail`, required for `fail` and `blocked`, omitted or `null` for
  clean `pass` results;
- `artifact`, optional path to a redacted implementation artifact.

## Status semantics

- `pass`: the implementation result satisfies the referenced vector for the
  consumed `houra_spec_commit`.
- `fail`: the vector was run or evaluated and did not satisfy the canonical
  expectation.
- `skipped`: the runner intentionally did not execute the vector even though it
  is in the target scope. A skip must include a reason and must not be counted
  as adoption evidence.
- `blocked`: the vector could not be evaluated because setup, dependency,
  environment, auth, service availability, or harness preconditions failed. A
  blocked result must include redacted failure detail.
- `out_of_scope`: the vector is deliberately outside the report target. This is
  allowed only when the report records the claim boundary and does not advertise
  the excluded behavior.

## Rejection cases

Consumers must reject or mark the report invalid when:

- the report's `houra_spec_commit` does not match the vector set used by the
  runner;
- `vector_path` or `vector_name` does not exist in the consumed `houra-spec`
  checkout;
- `contract` is unknown or does not match the vector file;
- `feature_profile` does not match `CONTRACT_MODULE_MAP.md`;
- `failure_detail` contains bearer tokens, refresh tokens, database URLs,
  signed or credentialed URLs, private local paths, media keys, room keys,
  recovery keys, pushkeys, vendor tokens, plaintext media bytes, or other raw
  secrets.

## Claim boundary

Conformance reports are evidence inputs. They are not release decisions.

Product MVP claims may use a report only when every in-scope Product MVP vector
is `pass` and UI/adoption evidence required by the release candidate is also
present.

Matrix version or domain advertisement may use a report only through the
release gates in `SPEC-062`, `SPEC-063`, `SPEC-064`, `SPEC-065`, and
`SPEC-066`. A report with `skipped`, `blocked`, `fail`, or `out_of_scope`
results for an advertised Matrix domain must keep advertisement fail-closed
unless a narrower release gate explicitly excludes that behavior.

Shared-core adoption may cite a report only when the relevant shared-core
artifact, parity, performance, packaging, redaction, and rollback evidence is
also present.

## Compatibility boundaries

- Existing contract and vector behavior stays available.
- This contract does not define implementation runner code.
- This contract does not require any repository to publish artifacts.
- This contract does not replace `tool/check_spec.dart`, which validates the
  `houra-spec` repository itself.
- This contract does not widen `GET /_matrix/client/versions` advertisement.

## Adoption decision checklist

After this contract merges:

- implementation repositories may use the `conformance-report-v1` shape for
  local and CI reports;
- `houra-client` and `houra-server` Product MVP evidence may cite reports only
  alongside the release-candidate adoption evidence they already require;
- Matrix release evidence may link reports only through the existing fail-closed
  release gates;
- `houra-labs` may emit reports for parser/shared-core experiments without
  making those experiments required dependencies.
