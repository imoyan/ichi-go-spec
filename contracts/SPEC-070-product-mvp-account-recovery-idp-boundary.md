# SPEC-070: Product MVP Account Recovery and IdP Login Boundary

Status: draft
Feature profile: auth
Canonical: yes

## Purpose

Define the Product MVP next-step boundary for email verification, password
reset, and identity provider login before any Houra client or server
implementation adds those flows.

This contract records a fail-closed defer decision. It intentionally does not
add endpoints, UI fields, SDK methods, OAuth login flows, reset-token flows, or
email-verification flows by itself.

## Scope

This contract is Houra-defined Product MVP planning, with Matrix v1.18 auth
references used only to keep boundaries compatible with the existing Matrix
auth/session contracts.

The initial Product MVP remains password-account creation, password login,
room/message/media operation, refresh, and logout through the current UI
surface. Email verification, password reset, identity provider login, fallback
HTML login, full Matrix OAuth, refresh-token issuance, dynamic client
registration, and native account-management screens remain out of scope until a
later contract and vector set explicitly adopts them.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3login>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3login>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3register>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#oauth-20-aware-clients>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#oauth-20-server-metadata-account-management-extension>
- Checked at: 2026-05-13T18:05:00+09:00
- Timezone: Asia/Tokyo

## Current decision

The Product MVP next step is not widened by this contract.

Servers must not advertise or expose Product MVP account recovery, email
verification, password reset, or identity provider login as supported behavior
unless a later contract defines the request/response shape, UI surface,
security evidence, and implementation adoption gates.

Clients must fail closed:

- do not render email verification, password reset, or identity provider login
  controls as Product MVP actions;
- do not add SDK methods for reset-token request/submit, email verification
  token submit, authorization-code exchange, token refresh, fallback login, or
  IdP launch until a later contract defines them;
- do not infer support from a server-specific endpoint, lab prototype, or
  implementation repository behavior;
- keep the existing password login and registration flows from `SPEC-032` and
  `SPEC-033` unchanged.

## Boundary split

Future work must be split into issue-sized gates. A later spec may adopt one or
more of these lanes:

1. Email verification for registration or account ownership proof.
2. Password reset or logged-out recovery.
3. Identity provider login / SSO / OAuth-aware login initiation.
4. Token refresh and session renewal.
5. Native account-management UI, if the Product MVP ever owns it.

Each lane must state whether it is a Product MVP next-step feature or a broader
Matrix compatibility feature. Matrix full compliance must not be claimed from a
single Product MVP recovery lane.

## SDK and host ownership

SDK core may own only protocol-shaped helpers after a later contract exists:

- request descriptors;
- response parsers;
- capability discovery parser output;
- redirect descriptor construction;
- post-return reconciliation helpers;
- public error-envelope parsing.

Host-owned responsibilities remain outside SDK core:

- browser selection and launch policy;
- deep-link registration and routing;
- callback URL handling;
- cancellation and retry UX;
- token storage and refresh scheduling;
- password storage policy;
- reset-token handling;
- authorization-code handling;
- native secure storage;
- user-facing prompts and recovery copy.

## Security and evidence

Future account recovery and IdP work must not write these values to logs,
issue evidence, release evidence, screenshots, README examples, or test
artifacts:

- passwords;
- bearer tokens;
- refresh tokens;
- reset tokens;
- email verification tokens;
- authorization codes;
- callback URL query values;
- IdP session identifiers.

Evidence may record redacted presence flags, flow status, contract refs,
implementation refs, and clean-room confirmation. It must not record secret
values.

## Compatibility boundaries

- `SPEC-032` remains the contract for Matrix password login, whoami, and
  logout.
- `SPEC-033` remains the contract for Matrix registration and UIA response
  shape.
- `SPEC-068` remains the contract for OAuth-aware account-management metadata,
  account/device redirects, and post-return reconciliation.
- The Product MVP UI surface remains unchanged by this contract.
- This contract does not widen `GET /_matrix/client/versions` advertisement.
- This contract does not claim Matrix full OAuth support, full Matrix auth
  support, or Matrix v1.18 full compliance.

## Adoption decision checklist

After this contract merges:

- `houra-client` may cite this boundary to keep account recovery and IdP login
  out of its exported SDK API and Expo Product MVP surface.
- `houra-server` must not add supported public Product MVP behavior for these
  flows without a narrower follow-up contract.
- `houra-labs` may prototype only when the prototype output is clearly
  non-canonical and does not become implementation evidence by itself.
- Future spec work must add contract text, vectors, UI surface updates when UI
  changes, and security evidence requirements before implementation adoption.
