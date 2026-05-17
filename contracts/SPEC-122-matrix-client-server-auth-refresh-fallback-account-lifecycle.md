# Matrix v1.18 / Client-Server API / login token, refresh, and account deactivation endpoints

Status: draft
Feature profile: auth
Contract type: endpoint
Matrix domain: Client-Server API
Primary reference: Matrix v1.18 / Client-Server API / login token, refresh, and account deactivation endpoints
Repository anchor: SPEC-122 Matrix Client-Server Auth Refresh Fallback Account Lifecycle
Canonical: yes

## Purpose

Define the focused Client-Server auth/refresh/fallback/account-lifecycle parser
and bounded runtime adoption boundary promoted from the `SPEC-073`
`auth-refresh-fallback-account-lifecycle` lane.

This contract lets implementation repositories adopt shared request descriptors,
a bounded runtime token-rotation behavior for the refresh endpoint, and explicit
parser-only coverage for get-login-token and account deactivation without
turning that evidence into complete User-Interactive Auth support, OAuth login
coverage, full device-token invalidation, or a widened Matrix Client-Server API
advertisement.

## Scope

This contract covers parser-only or bounded runtime shape for:

```text
POST /_matrix/client/v1/login/get_token
POST /_matrix/client/v3/refresh
POST /_matrix/client/v3/account/deactivate
```

And these non-endpoint policy surfaces:

- fallback login UI page reference and policy guidance;
- account data removal semantics on deactivation;
- bearer-token ownership boundary preserving `SPEC-032` and `SPEC-068` rules.

Only these behaviors are adopted:

- `get_token` request and response descriptor (parser-only); no runtime
  adoption;
- `refresh` request descriptor plus **bounded runtime token rotation**: the
  server must accept a valid `refresh_token`, issue a new `access_token` and
  `refresh_token`, and invalidate the old `access_token`;
- `deactivate` request and response descriptor (parser-only); no runtime
  adoption due to required storage mutation verification;
- fallback login page URL policy guidance (non-endpoint, non-runtime);
- account data removal policy guidance (non-endpoint, non-runtime).

This contract does not define OAuth login flows, complete User-Interactive Auth
breadth, additional login flow types beyond password (`m.login.password`), full
device and token invalidation breadth, full account data or E2EE cleanup
semantics, or a widened Matrix versions advertisement.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv1loginget_token>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3refresh>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3accountdeactivate>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#login-fallback>
- Parent contract: `SPEC-032`
- Parent contract: `SPEC-033`
- Parent contract: `SPEC-034`
- Parent contract: `SPEC-068`
- Gap inventory: `SPEC-073`
- Checked at: 2026-05-17T12:00:00+09:00
- Timezone: Asia/Tokyo

## Adopted Descriptors

### get_token (parser-only)

```json
{
  "id": "get-login-token",
  "method": "POST",
  "path": "/_matrix/client/v1/login/get_token",
  "requires_auth": true,
  "body": {
    "device_id": "DEVICE1"
  },
  "adopted_runtime_behavior": false,
  "unsupported_reason": "complex_auth_flow_requires_separate_adoption",
  "response_parser": "login_token"
}
```

The parser must normalize a successful response envelope containing `login_token`
and `expires_in_ms`. It must not execute the auth flow at runtime. Clients must
not infer that token-based login is available until a separate runtime adoption
contract covers `POST /_matrix/client/v3/login` with `m.login.token`.

### refresh (bounded runtime)

```json
{
  "id": "refresh-token",
  "method": "POST",
  "path": "/_matrix/client/v3/refresh",
  "requires_auth": false,
  "body": {
    "refresh_token": "old-refresh-token"
  },
  "adopted_runtime_behavior": true,
  "response_parser": "refresh_response"
}
```

Token rotation is bounded and deterministic: the server accepts a valid
`refresh_token`, returns a new `access_token` and `refresh_token`, and
invalidates the old `access_token`. The `expires_in_ms` field is optional but
must be a positive integer when present.

Implementations must fail closed:

- reject requests with a missing or blank `refresh_token`;
- reject requests with an expired `refresh_token` using `M_UNKNOWN_TOKEN`;
- reject requests missing the `access_token` that the original token pair
  belongs to;
- treat token rotation as atomic: either both new tokens are issued or neither;
- do not persist rotation state across restart unless `SPEC-034` storage
  evidence also passes.

### deactivate (parser-only)

```json
{
  "id": "account-deactivate",
  "method": "POST",
  "path": "/_matrix/client/v3/account/deactivate",
  "requires_auth": true,
  "body": {
    "id_server": "id.example.test"
  },
  "adopted_runtime_behavior": false,
  "unsupported_reason": "requires_storage_mutation_verification",
  "response_parser": "deactivate_response"
}
```

The parser must normalize a successful response envelope. It must not execute
the deactivation storage mutation at runtime. The `id_server_unbind_result`
field in the response must be one of `success` or `no-support`.

## Fallback Login Policy

Matrix specifies a fallback login HTML page at:

```text
GET /_matrix/client/v3/login/sso/redirect
GET /_matrix/static/client/login/
```

This contract records only the policy: Houra servers must not advertise
`m.login.token` in `GET /_matrix/client/v3/login` until a runtime contract
covers the full fallback handshake. The fallback URL is not an adopted endpoint
in this contract.

## Account Data Removal Policy

Account deactivation in Matrix SHOULD remove account data and unbind any
third-party identifier associations. This contract records the policy only:
actual storage mutation and unbind verification must be tracked in a separate
runtime adoption issue before the deactivate endpoint is marked as adopted
runtime behavior.

## Resource Bounds

Runtime adoption for refresh is bounded:

- token rotation required: true;
- access token invalidation on rotation: true;
- storage mutation for deactivation: false;
- OAuth flow runtime: false;
- complete UIA breadth claimed: false;
- device-token invalidation breadth: false;
- versions advertisement widened: false.

## Fail-Closed Behavior

Implementations must fail closed:

- do not advertise full Client-Server API support from these descriptors or
  parsers;
- do not widen `GET /_matrix/client/versions`;
- reject malformed refresh request bodies with missing `refresh_token`;
- reject expired refresh tokens with `M_UNKNOWN_TOKEN`;
- do not execute get_token auth flow at runtime; return `M_UNRECOGNIZED` or
  equivalent until a dedicated runtime adoption contract passes;
- do not execute account deactivation storage mutation until a dedicated
  runtime contract and storage-mutation evidence are in place;
- preserve `SPEC-032` and `SPEC-068` bearer-token ownership rules: tokens must
  not be persisted by SDK core; they must be returned to the host;
- keep E2EE readiness unclaimed unless `SPEC-050` through `SPEC-054` and
  `SPEC-079` evidence pass.

## Adoption Decision Checklist

After this contract merges:

- `houra-labs#133` may add parser-only helper coverage for `get_token` and
  `deactivate` descriptors and bounded runtime evidence for `refresh`.
- `houra-server#252` may adopt bounded runtime token rotation for the refresh
  endpoint using this vector.
- `houra-spec#270` tracks the spec-side boundary for this lane.
- Server implementation of account deactivation runtime behavior requires a
  separate adoption issue and storage-mutation evidence before the `deactivate`
  endpoint is marked as runtime-adopted.
- Get-login-token runtime adoption requires a separate contract covering the
  full `m.login.token` handshake and `POST /_matrix/client/v3/login` with
  `type: m.login.token`.
- Release evidence must keep `advertisement_allowed=false` for Client-Server API
  until the broader `SPEC-073` lanes are resolved for the release.

## Compatibility Boundaries

- `SPEC-032` remains the auth/session MVP contract (password login, whoami,
  logout).
- `SPEC-033` remains the registration contract.
- `SPEC-034` remains the devices and sessions contract.
- `SPEC-068` remains the OAuth-aware account-management and device-deletion
  redirect boundary.
- `SPEC-073` remains the Client-Server full-breadth gap inventory.
- Passing this contract does not claim complete UIA correctness, OAuth login
  support, device-token invalidation breadth, account data removal runtime
  correctness, or Matrix v1.18 full compliance.
