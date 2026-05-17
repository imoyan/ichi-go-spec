# Matrix v1.18 / Application Service API / appservice bridge security and observability evidence

Status: draft
Feature profile: core
Contract type: boundary
Matrix domain: Application Service API
Primary reference: Matrix v1.18 / Application Service API / appservice bridge security and observability evidence
Repository anchor: SPEC-121 Matrix Application Service Bridge Security Observability Breadth
Canonical: yes

## Purpose

Define the Application Service bridge security, observability, and release
evidence boundary promoted from the `SPEC-075`
`bridge-external-url-security-observability-release-evidence-breadth` lane.

This contract does not add endpoint behavior. It defines what must be excluded,
redacted, and recorded in release evidence for any appservice or bridge adoption.
It is a policy and evidence contract only.

## Scope

This contract covers the following policy and evidence surfaces:

- `external_url` handling: messages bridged from third-party networks may carry
  `external_url` in event content; client-visible URL scheme safety must be
  enforced as a required policy;
- token redaction: `as_token`, `hs_token`, and registration file contents must
  be redacted in logs, traces, and release artifacts;
- outbound request redaction: appservice target URLs must be redacted or masked
  in observable artifacts;
- metrics and audit: appservice transaction delivery rate, retry count, and
  failure count must be observable without leaking tokens or URLs;
- trace IDs: requests from homeserver to appservice must carry a correlation
  trace ID that does not include token values;
- release evidence linkage: any appservice or bridge adoption must reference
  `SPEC-062` (domain coverage), `SPEC-064` (advertisement gate), `SPEC-065`
  (release notes), and `SPEC-066` (readiness gate);
- intentional exclusion evidence: release notes must list excluded bridge
  protocol behaviors explicitly.

This contract does not cover:

- any bridge protocol runtime implementation;
- delivery of bridged events;
- provider-specific bridge behaviors;
- runtime appservice transaction handling (owned by earlier `SPEC-075` lanes).

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/application-service-api/>
- Source: <https://spec.matrix.org/v1.18/application-service-api/#put_matrixappv1transactionstxnid>
- Parent contracts: `SPEC-058`, `SPEC-075`, `SPEC-062`, `SPEC-065`
- Gap inventory: `SPEC-075`
- Checked at: 2026-05-17T12:00:00+09:00
- Timezone: Asia/Tokyo

## Security Policy

**external_url_scheme_safety** — When a bridged event carries `external_url` in
its content, the client must not automatically open the URL without explicit
user action. The homeserver must not follow or resolve the URL during event
ingestion. Only `https` scheme URLs may be presented to users; bare `http` URLs
and non-HTTP schemes must be suppressed or rendered inert. This policy must
appear in release evidence for any feature that surfaces `external_url` content.

**token_redaction_required** — The `as_token`, `hs_token`, and the full
contents of the appservice registration file must not appear in:
- server logs or structured log entries;
- distributed traces or trace spans;
- CI/CD artifacts, test reports, or release bundles;
- normalized parser or evidence artifacts.

Implementations must verify token redaction before any appservice adoption PR is
merged.

**outbound_url_redaction_required** — The URL configured as the appservice
endpoint (the `url` field in the registration file) must be redacted or masked
in any observable artifact, trace span, metric label, or log entry that
references appservice transactions.

**trace_id_no_token** — Correlation trace IDs attached to homeserver-to-appservice
requests must not include, encode, or embed `as_token`, `hs_token`, or any
portion of the registration file content. Trace IDs must be opaque random
identifiers or structured identifiers that contain only non-secret fields.

**metrics_without_token_leak** — Observable metrics for appservice transaction
delivery (delivery rate, retry count, failure count, timeout count) must use
metric labels that contain only the appservice `id` field from the registration.
Metric labels must not include `as_token`, `hs_token`, or the appservice
endpoint URL.

## Release Evidence Requirements

Any appservice or bridge adoption PR must include or reference:

**domain_coverage_ref_required** — A reference to the current `SPEC-062`
domain coverage report confirming that the Application Service domain remains
excluded from the coverage claim for the release.

**advertisement_gate_ref_required** — A reference to the current `SPEC-064`
advertisement gate confirming that `advertisement_allowed=false` for the
Application Service API.

**release_notes_ref_required** — A reference to the `SPEC-065` release notes
confirming that appservice coverage is documented. If coverage is not included
in the release, the release notes must explicitly state this exclusion.

**readiness_gate_ref_required** — A reference to the `SPEC-066` readiness gate
confirming that the appservice lane is either resolved or explicitly listed as
excluded for the release.

**excluded_bridge_behaviors_listed** — Release notes and the exclusion evidence
must enumerate every bridge protocol behavior that is intentionally not
implemented. Generic statements such as "bridges are not supported" are
insufficient; specific excluded behaviors (protocol handshake, presence sync,
typing notification bridging, media bridging, etc.) must be listed.

## Fail-Closed Behavior

Implementations must fail closed:

- reject any appservice adoption PR where `as_token` or `hs_token` appears in
  logs, traces, or release artifacts;
- reject any appservice adoption PR where the appservice endpoint URL is
  unredacted in traces or metric labels;
- reject any `external_url` client rendering that auto-opens the URL or follows
  non-`https` scheme URLs;
- reject release evidence that does not reference `SPEC-062`, `SPEC-064`,
  `SPEC-065`, and `SPEC-066`;
- reject release notes that do not explicitly list excluded bridge protocol
  behaviors;
- do not allow trace IDs to carry token material.

## Adoption Decision Checklist

After this contract merges:

- This contract has no associated `houra-server` or `houra-labs` implementation
  issue yet. It becomes a precondition for any future `houra-server` bridge
  adoption PR.
- Any PR that adds appservice transaction delivery, bridge integration, or
  `external_url` content handling must cite this contract and demonstrate
  compliance with the security and redaction policies above.
- `houra-labs` may record compliance evidence artifacts once a bridge adoption
  is planned, but this contract must be satisfied before that work begins.
- Release evidence must keep `advertisement_allowed=false` for the Application
  Service API until all `SPEC-075` lanes are resolved.

## Compatibility Boundaries

- `SPEC-058` remains the representative registration, namespace, transaction,
  and query gate.
- `SPEC-062` remains the domain coverage report gate.
- `SPEC-064` remains the advertisement gate.
- `SPEC-065` remains the release notes evidence gate.
- `SPEC-066` remains the readiness gate.
- `SPEC-075` remains the Application Service full-breadth gap inventory.
- `SPEC-119` and `SPEC-120` own the Client-Server extension masquerade, sync,
  device, and cross-signing parser boundary lanes.
- Passing this contract does not claim bridge protocol runtime implementation,
  bridged event delivery, provider-specific bridge behaviors, appservice API
  runtime breadth, or Matrix v1.18 full compliance.
