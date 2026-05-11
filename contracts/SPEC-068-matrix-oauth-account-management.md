# SPEC-068: Matrix OAuth Account Management and Device Deletion Flow

Status: draft
Feature profile: auth
Canonical: yes

## Purpose

Define the Matrix v1.18 OAuth-aware account-management route that follows
`SPEC-034` device deletion: discover account-management metadata, deep-link
users to web account management for account and device actions, and reconcile
client state after a device has been deleted outside the native client UI.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds OAuth-aware client
behavior around `/_matrix/**` auth endpoints without changing existing
`/_houra/client/**` routes.

This contract does not implement the full Matrix OAuth 2.0 API, dynamic client
registration, authorization-code exchange, device authorization grant, token
revocation, SSO fallback HTML, cross-signing reset, or native account-management
screens. It only defines the account-management discovery and redirect behavior
that OAuth-aware clients must use instead of legacy UIA account/device endpoints
when the homeserver supports the Matrix OAuth 2.0 API.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#oauth-20-aware-clients>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#oauth-20-server-metadata-account-management-extension>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#delete_matrixclientv3devicesdeviceid>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3accountdeactivate>
- Checked at: 2026-05-11T13:18:18+09:00
- Timezone: Asia/Tokyo

## Metadata discovery

OAuth-aware clients determine whether a homeserver uses the Matrix OAuth 2.0
API by requesting:

```text
GET /_matrix/client/v1/auth_metadata
```

When the server advertises account management, the metadata includes:

```json
{
  "issuer": "https://account.example.test/",
  "account_management_uri": "https://account.example.test/manage",
  "account_management_actions_supported": [
    "org.matrix.profile",
    "org.matrix.devices_list",
    "org.matrix.device_view",
    "org.matrix.device_delete",
    "org.matrix.account_deactivate"
  ]
}
```

`account_management_uri`, when present, must be an absolute HTTPS URI.
`account_management_actions_supported`, when present, must be a list of
non-empty action strings. Clients must only construct Matrix-specific action
links for actions advertised by the server.

## Device deletion redirect

OAuth-aware clients must not use legacy device-deletion UIA endpoints from
`SPEC-034` when the server supports the Matrix OAuth 2.0 API and advertises an
account-management URL.

To delete or log out a device other than the current device, clients build an
account-management URL with:

```text
action=org.matrix.device_delete
device_id=DEVICE2
```

For the metadata example above, the resulting URL is:

```text
https://account.example.test/manage?action=org.matrix.device_delete&device_id=DEVICE2
```

Clients must URL-encode query parameter values and must not put bearer tokens in
the URL. The web account-management surface owns the user-interaction and
authentication steps for this action.

If `org.matrix.device_delete` is not advertised, clients must not guess the
action name or silently fall back to `DELETE /_matrix/client/v3/devices/{id}` for
an OAuth-authenticated session. They may open the generic
`account_management_uri` without action parameters.

## Account deactivation redirect

OAuth-aware clients must not use `POST /_matrix/client/v3/account/deactivate`
when the server supports the Matrix OAuth 2.0 API and advertises an
account-management URL.

If `org.matrix.account_deactivate` is advertised, clients deep-link with:

```text
action=org.matrix.account_deactivate
```

If the action is not advertised, clients may open the generic
`account_management_uri` and must not perform account deactivation through the
legacy UIA endpoint for an OAuth-authenticated session.

## Return and reconciliation

After the user returns from account management, clients reconcile state through
Matrix Client-Server API reads:

1. Refresh `GET /_matrix/client/v3/devices` when the local session still has a
   valid access token.
2. Treat the target device disappearing from the device list as successful
   deletion.
3. If the current device was deleted and subsequent authenticated calls return
   `M_UNKNOWN_TOKEN`, clear host-owned bearer-token state and route the user to
   logged-out recovery.
4. Do not persist account-management URLs as proof that deletion completed.
   The post-return API result is the completion signal.

`SPEC-034` remains the contract for legacy UIA device deletion and token
invalidation. This contract defines when OAuth-aware clients must avoid the
legacy deletion path and how they reconcile after external account management.

## Authentication errors

Missing bearer tokens during post-return reconciliation must return `401` with
`M_MISSING_TOKEN`. Invalid or deleted bearer tokens must return `401` with
`M_UNKNOWN_TOKEN`. Error envelopes must follow `SPEC-031`.

## Compatibility boundaries

- Existing `/_houra/client/**` auth/session behavior stays available.
- `SPEC-032` remains the contract for legacy Matrix login, whoami, and logout.
- `SPEC-033` remains the contract for legacy Matrix registration.
- `SPEC-034` remains the contract for legacy Matrix device UIA deletion.
- `SPEC-051` remains the contract for Matrix E2EE device keys.
- This contract does not by itself advertise full Matrix OAuth 2.0 support.
- Matrix OAuth-aware account-management support is additive and does not by
  itself widen `GET /_matrix/client/versions` advertisement beyond the evidence
  gate in `SPEC-030`, `SPEC-031`, and release gates `SPEC-062` through
  `SPEC-066`.
- After this spec PR is merged, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if parser-only shared-core
  adoption is useful for account-management metadata or URL construction.
