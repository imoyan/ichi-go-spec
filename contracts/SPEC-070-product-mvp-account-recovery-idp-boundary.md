# SPEC-070: Product MVP Account Recovery and IdP Login Boundary

Status: draft
Feature profile: auth
Canonical: yes

## Purpose

Define the Product MVP next-step boundary for email verification, password
reset, and identity provider login before any Houra client or server
implementation adds those flows.

This contract keeps the current Product MVP release candidate fail-closed, but
it also defines optional Product MVP vNext lanes that implementations may adopt
after the matching vectors, UI surface evidence, and implementation adoption
gates pass.

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

## Current release decision

The current Product MVP baseline is not widened by this contract. Password
login, password-account creation, room/message/media operation, refresh, and
logout remain the only required Product MVP auth/session behavior.

Servers must not advertise or expose Product MVP account recovery, email
verification, password reset, or identity provider login as supported behavior
unless the matching optional lane below is implemented and adoption evidence
names the `houra-spec`, implementation, UI surface, and verification refs.

Clients must fail closed:

- do not render email verification, password reset, or identity provider login
  controls unless capability discovery advertises the matching lane;
- do not call reset-token request/submit, email verification token submit,
  authorization-code exchange, token refresh, fallback login, or IdP launch
  endpoints unless capability discovery advertises the matching lane;
- do not infer support from a server-specific endpoint, lab prototype, or
  implementation repository behavior;
- keep the existing password login and registration flows from `SPEC-032` and
  `SPEC-033` unchanged.

## Capability discovery

Product MVP vNext account recovery and IdP login support is discovered through
the Houra login discovery response from `SPEC-003`. The response must still
include the password flow. A server that supports vNext lanes may add an
`account_recovery` object and an IdP login flow descriptor:

```json
{
  "flows": [
    {
      "type": "houra.login.password"
    },
    {
      "type": "houra.login.idp.redirect",
      "providers": [
        {
          "id": "example-idp",
          "name": "Example IdP"
        }
      ],
      "start_path": "/_houra/client/login/idp/start",
      "complete_path": "/_houra/client/login/idp/complete"
    }
  ],
  "account_recovery": {
    "password_reset": {
      "supported": true,
      "request_path": "/_houra/client/account/password-reset/request",
      "submit_path": "/_houra/client/account/password-reset/submit"
    },
    "email_verification": {
      "supported": true,
      "requires_auth": true,
      "request_path": "/_houra/client/account/email-verification/request",
      "submit_path": "/_houra/client/account/email-verification/submit"
    }
  }
}
```

If a lane is missing or has `supported: false`, clients must hide or disable the
matching Product MVP action and must not probe server-specific endpoints. A
server may return `404` with `HOURA_NOT_FOUND` for unadvertised recovery and
IdP paths.

## Email verification lane

Email verification is an authenticated account-ownership proof. It does not
change initial registration requirements and does not make email a required
Product MVP account field.

```text
POST /_houra/client/account/email-verification/request
Authorization: Bearer token-1
```

```json
{
  "email": "alice@example.test",
  "client_secret": "client-secret-1",
  "send_attempt": 1
}
```

`email` is the address to verify. `client_secret` is host-owned opaque state
used to correlate request and submit attempts. `send_attempt` is a positive
integer incremented by the host when the user asks to resend verification.

Servers should return `202` without exposing email-provider internals:

```json
{
  "sid": "email-sid-1",
  "email": "alice@example.test",
  "submit_path": "/_houra/client/account/email-verification/submit",
  "expires_in_ms": 900000
}
```

The submit request completes ownership proof:

```text
POST /_houra/client/account/email-verification/submit
Authorization: Bearer token-1
```

```json
{
  "sid": "email-sid-1",
  "client_secret": "client-secret-1",
  "token": "123456"
}
```

Successful verification returns:

```json
{
  "email_verified": true,
  "user_id": "@alice:example.test"
}
```

## Password reset lane

Password reset is a logged-out recovery lane for Houra password accounts. The
request step must not reveal whether an account exists for the submitted email.

```text
POST /_houra/client/account/password-reset/request
```

```json
{
  "email": "alice@example.test",
  "client_secret": "client-secret-1",
  "send_attempt": 1
}
```

Servers should return the same public response shape for known and unknown
email addresses:

```json
{
  "recovery_id": "reset-1",
  "submit_path": "/_houra/client/account/password-reset/submit",
  "expires_in_ms": 900000
}
```

The submit request applies the new password only when the recovery token and
client secret are valid:

```text
POST /_houra/client/account/password-reset/submit
```

```json
{
  "recovery_id": "reset-1",
  "client_secret": "client-secret-1",
  "token": "123456",
  "new_password": "correct horse battery staple"
}
```

Successful password reset does not create a session by itself. Clients should
return to the password login action from `SPEC-004`.

```json
{
  "password_reset": true,
  "login_required": true
}
```

## Identity provider login lane

Identity provider login is an unauthenticated redirect lane. Host applications
own browser presentation, deep-link routing, cancellation UI, and callback
handling. SDK core may construct request descriptors and parse public responses
only after this lane is advertised.

```text
POST /_houra/client/login/idp/start
```

```json
{
  "provider_id": "example-idp",
  "redirect_uri": "houra://auth/callback",
  "state": "state-1"
}
```

Servers return a redirect descriptor, not browser behavior:

```json
{
  "authorization_url": "https://idp.example.test/authorize?client_id=houra&state=state-1",
  "state": "state-1",
  "expires_in_ms": 300000
}
```

After the host receives the callback, the completion request exchanges the
authorization result for the same session response shape as `SPEC-004`:

```text
POST /_houra/client/login/idp/complete
```

```json
{
  "provider_id": "example-idp",
  "redirect_uri": "houra://auth/callback",
  "state": "state-1",
  "code": "authorization-code-1"
}
```

```json
{
  "user_id": "@alice:example.test",
  "access_token": "token-idp-1",
  "device_id": "DEVICE-IDP1"
}
```

Clients must not persist the access token in SDK core. Hosts remain responsible
for token storage, browser state, callback routing, and cancellation handling.

## Error and recovery-state expectations

For malformed request bodies, servers should return `400` with
`HOURA_BAD_REQUEST`. For invalid, expired, or already-used recovery tokens,
servers should return `401` with `HOURA_UNAUTHORIZED`. For unadvertised Product
MVP vNext lanes, servers may return `404` with `HOURA_NOT_FOUND`.

Clients must preserve recoverable error visibility without clearing user input
unless the host explicitly chooses a more destructive reset policy.

## Boundary split

Further work must stay split into issue-sized gates. Later specs may refine one
or more of these lanes:

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
- `SPEC-068` remains the contract for Matrix OAuth-aware account-management
  metadata, account/device redirects, and post-return reconciliation.
- Product MVP vNext UI actions are optional and must remain hidden unless the
  matching capability is advertised and adoption evidence is recorded.
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
