# Houra Product MVP / Multilingual Handoff Boundary

Status: draft
Feature profile: core
Contract type: boundary
Matrix domain: none
Primary reference: Houra Product MVP / Multilingual Handoff Boundary
Repository anchor: SPEC-128 Product MVP Multilingual Handoff Boundary
Canonical: yes

## Purpose

Define the Product MVP server boundary for exporting only reviewed,
confirmed translations to an audience while preserving a canonical source
language and keeping draft or provider-generated text internal.

This contract does not define translation provider integration or automatic
translation quality judgment. It defines the minimum server-owned handoff
boundary that `houra-server` may adopt for Product MVP evidence while keeping
Product MVP release readiness, Matrix compatibility, and client review UI
claims fail-closed.

## Scope

Multilingual handoff covers one source message with:

- `message_id`, a stable source message identifier;
- `source_locale`, the canonical source language tag;
- `source_text`, the canonical source text;
- `target_locale`, the requested audience language tag;
- `audience`, the audience receiving the confirmed translation;
- `translation_state`, one of `draft`, `pending_review`, or `confirmed`;
- `review_actor`, the human reviewer who confirmed the translation;
- `confirmed_translation`, the reviewed export text;
- optional provider-only draft metadata that must not appear in public handoff
  artifacts.

Implementations must export from the confirmed translation state only. They
must not expose raw model output, provider prompts, provider secrets, local
paths, or unreviewed draft text.

## Locale and Review Rules

Representative Product MVP locales are `en`, `ja`, `es`, and `pt-BR`.

Implementations must:

- normalize locale tags before persistence and response;
- reject unsupported locales;
- reject duplicate locale entries for the same `message_id` and audience;
- reject empty confirmed translations;
- require a non-empty `review_actor` when `translation_state` is `confirmed`;
- keep `source_locale` and `target_locale` distinct for translated handoff.

## Fail-Closed Behavior

Implementations must reject or mark the handoff invalid when:

- translation state is `draft` or `pending_review`;
- `review_actor` is missing for a confirmed translation;
- confirmed translation is empty after trimming;
- target locale is unsupported or duplicated for the same audience;
- source and target locale are the same for a translation handoff;
- raw model output, provider prompt, provider secret, or local path appears in
  the exported payload or evidence artifact;
- provider-only draft metadata is copied to the audience response.

## Evidence Artifact

Implementation evidence for this contract must record:

- the consumed `houra-spec` ref;
- the implementation ref;
- the message id;
- source and target locale;
- the audience;
- the translation state;
- the review actor identifier;
- whether a confirmed translation was exported;
- whether diagnostics and artifacts are redacted.

Evidence artifacts must not contain raw model output, provider prompts, provider
secrets, bearer tokens, database URLs, private local paths, or unreviewed draft
text.

## Claim Boundary

Passing this contract does not widen:

- Product MVP release readiness;
- Matrix compatibility or `/_matrix/client/versions` advertisement;
- translation provider integration;
- automatic translation quality judgment;
- client review UI behavior;
- sample-runner compatibility.

## Compatibility Boundaries

- Existing Product MVP contract behavior remains unchanged.
- `houra-server` owns the server normalization, review-state, persistence, and
  confirmed export invariant for this representative boundary.
- UI review workflow behavior requires separate client and UI surface evidence.
- PostgreSQL and in-memory implementations must keep provider draft state and
  confirmed export state separate for the representative vectors.
- Future provider-specific translation, glossary, locale fallback, or quality
  scoring behavior must be split into separate contracts and issues.

## Adoption Decision Checklist

After this contract merges:

- `houra-server#339` may adopt the representative multilingual handoff behavior
  against the pinned spec ref;
- server adoption must include confirmed translation returned, pending blocked,
  raw model output blocked, duplicate language rejected, unsupported locale,
  empty export, persistence, and redacted artifact tests;
- README adoption evidence in `houra-server` must cite this contract, vector,
  implementation ref, verification commands, and a clean-room note;
- Product MVP readiness remains fail-closed unless a separate release candidate
  gate cites this evidence and all other blocking lanes pass.
