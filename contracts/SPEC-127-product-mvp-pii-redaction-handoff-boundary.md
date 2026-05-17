# SPEC-127: Product MVP PII Redaction Handoff Boundary

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Define the Product MVP server boundary for preparing an external handoff from a
raw report only after classification, redaction, and human approval have all
completed.

This contract is not a legal PII taxonomy and does not define production
external adapter delivery. It defines the minimum server-owned safety boundary
that `houra-server` may adopt for Product MVP handoff evidence while keeping
Product MVP release readiness, Matrix compatibility, and client approval UI
claims fail-closed.

## Scope

PII redaction handoff covers one raw report with:

- `report_id`, a stable report identifier;
- `raw_report`, a server-internal object that may contain public fields,
  PII fields, secrets, tokens, provider data, and local diagnostics;
- `classification`, a server-owned result for each input field;
- `redacted_payload`, the external-safe payload after classification;
- `review_state`, the human approval state for the handoff;
- `handoff_state`, the final external handoff readiness state.

Implementations must separate raw/internal state from redacted/export state.
They must not build an external payload by copying a broad report object and
removing fields with a denylist.

## Classification Categories

Representative Product MVP categories are:

- `public`: safe external handoff field;
- `customer_contact`: personally identifying contact data;
- `sensitive_note`: free-form note that may contain PII;
- `credential`: token, password, key, or provider secret;
- `local_path`: local filesystem or machine-specific path;
- `provider_secret`: external provider credential or webhook secret;
- `internal_diagnostic`: internal debug or trace material.

Only `public` fields may be copied to `redacted_payload` without a replacement
marker. PII and secret-bearing categories must be omitted or replaced with a
bounded marker such as `[redacted:customer_contact]`.

Unknown classifications must fail closed.

## Handoff State Machine

The representative state machine is:

1. `classified`: classification exists, but no redacted external payload is
   approved.
2. `redacted`: a redacted payload exists and all non-public categories are
   omitted or replaced.
3. `reviewed`: a human reviewer approved the exact redacted payload.
4. `approved_for_handoff`: the payload may be queued as an external handoff
   artifact.

Implementations must reject external handoff when the report is unclassified,
unredacted, unreviewed, or when the approved payload differs from the redacted
payload that was reviewed.

## Fail-Closed Behavior

Implementations must reject or mark the handoff invalid when:

- classification is missing for any raw field;
- classification contains an unknown category;
- `redacted_payload` contains any raw PII, credential, provider secret, local
  path, or internal diagnostic value;
- a raw value is renamed into a different external field instead of redacted;
- handoff is requested before human approval;
- the raw report or redacted payload exceeds the representative payload size
  limit;
- logs, evidence artifacts, or diagnostics contain forbidden raw values.

Representative forbidden raw values include email addresses, phone numbers,
postal addresses, access tokens, provider secrets, local filesystem paths, and
debug traces.

## Evidence Artifact

Implementation evidence for this contract must record:

- the consumed `houra-spec` ref;
- the implementation ref;
- the report id and classification categories observed;
- the redacted field names included in the handoff payload;
- the field names that were omitted or replaced;
- the human approval state;
- whether an external handoff artifact was allowed;
- whether diagnostics and artifacts are redacted.

Evidence artifacts must not contain raw PII values, bearer tokens, database
URLs, private local paths, provider secrets, customer-private notes, or internal
debug traces.

## Claim Boundary

Passing this contract does not widen:

- Product MVP release readiness;
- Matrix compatibility or `/_matrix/client/versions` advertisement;
- production external adapter delivery;
- legal PII taxonomy coverage;
- client approval UI behavior;
- sample-runner compatibility.

## Compatibility Boundaries

- Existing Product MVP contract behavior remains unchanged.
- `houra-server` owns the server classification, redaction, approval, and
  persistence invariant for this representative boundary.
- UI approval workflow behavior requires separate client and UI surface
  evidence.
- PostgreSQL and in-memory implementations must keep raw/internal state and
  redacted/export state separate for the representative vectors.
- Future legal taxonomy, provider-specific delivery, or organization policy
  administration behavior must be split into separate contracts and issues.

## Adoption Decision Checklist

After this contract merges:

- `houra-server#340` may adopt the representative PII redaction handoff behavior
  against the pinned spec ref;
- server adoption must include classification, redaction, human approval,
  approved handoff, unreviewed handoff, unredacted export, renamed raw value
  leak, unknown classification, oversized payload, persistence, and redaction
  artifact tests;
- README adoption evidence in `houra-server` must cite this contract, vector,
  implementation ref, verification commands, and a clean-room note;
- Product MVP readiness remains fail-closed unless a separate release candidate
  gate cites this evidence and all other blocking lanes pass.
