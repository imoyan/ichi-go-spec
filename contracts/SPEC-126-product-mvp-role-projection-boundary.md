# SPEC-126: Product MVP Role Projection Boundary

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Define the Product MVP server boundary for returning a normalized subject as a
role- and audience-specific projection.

This contract is not an enterprise RBAC system and does not copy behavior from
sample runners. It defines the minimum allowlist-based projection behavior that
`houra-server` may adopt for Product MVP handoff evidence while keeping Product
MVP release readiness, Matrix compatibility, and broader authorization claims
fail-closed.

## Scope

Role projection covers a single normalized subject with:

- `subject_id`, a stable identifier for the projected entity;
- `owner_customer_id`, the customer or tenant that owns customer-private data;
- `audience_customer_id`, the customer or tenant visible to the requester;
- `role`, one of `admin`, `worker`, `customer`, or `guest`;
- `attributes`, a server-owned normalized object containing public,
  operational, customer-private, and internal fields.

Implementations must project with role allowlists. They must not remove fields
with a denylist after first building a broad object.

## Projection Roles

The representative Product MVP roles are:

- `admin`: may receive public, operational, and audit-safe metadata for the
  subject, but not raw secrets or internal-only diagnostics;
- `worker`: may receive public and operational fields needed to perform work,
  but not customer-private notes, billing fields, or internal diagnostics;
- `customer`: may receive public fields and customer-private fields only when
  `audience_customer_id` matches `owner_customer_id`;
- `guest`: may receive public display fields only.

Unknown roles must fail closed.

## Fail-Closed Behavior

Implementations must reject or mark the projection invalid when:

- `role` is unknown;
- `subject_id` is empty or not normalized;
- the projection allowlist would produce an empty object;
- `audience_customer_id` does not match `owner_customer_id` for a
  customer-private field;
- a projected output contains a forbidden field for the selected role;
- the projection configuration is tampered, missing, or contains a field that is
  not present in the normalized subject schema;
- logs, evidence artifacts, or diagnostics contain forbidden raw fields.

Representative forbidden raw fields are `internal_note`, `billing_account_id`,
`secret_token`, `debug_trace`, and other customer data not owned by the
requesting audience.

## Evidence Artifact

Implementation evidence for this contract must record:

- the consumed `houra-spec` ref;
- the implementation ref;
- the role being evaluated;
- the allowlisted field names included in the projection;
- the forbidden field names that were checked and omitted;
- whether any cross-customer data was omitted;
- whether diagnostics and artifacts are redacted.

Evidence artifacts must not contain forbidden raw field values, bearer tokens,
database URLs, private local paths, customer-private notes, billing identifiers,
or internal debug traces.

## Claim Boundary

Passing this contract does not widen:

- Product MVP release readiness;
- Matrix compatibility or `/_matrix/client/versions` advertisement;
- account, team, or enterprise RBAC behavior;
- UI or client-side role management;
- sample-runner compatibility.

## Compatibility Boundaries

- Existing Product MVP contract behavior remains unchanged.
- `houra-server` owns the server projection behavior and persistence invariant.
- UI and client role-management behavior require separate client and UI surface
  evidence.
- PostgreSQL and in-memory implementations must produce the same projected
  shape for the representative vectors.
- Future broader authorization, policy administration, or team-management
  behavior must be split into a separate contract and issue.

## Adoption Decision Checklist

After this contract merges:

- `houra-server#337` may adopt the representative role projection behavior
  against the pinned spec ref;
- server adoption must include success, forbidden-field, cross-customer,
  unknown-role, tampered-config, and redaction tests;
- README adoption evidence in `houra-server` must cite this contract, vector,
  implementation ref, verification commands, and a clean-room note;
- Product MVP readiness remains fail-closed unless a separate release candidate
  gate cites this evidence and all other blocking lanes pass.
