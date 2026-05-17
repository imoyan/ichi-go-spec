# Matrix v1.18 / Client-Server API / .well-known client, support, and policy metadata

Status: draft
Feature profile: core
Contract type: boundary
Matrix domain: Client-Server API
Primary reference: Matrix v1.18 / Client-Server API / .well-known client, support, and policy metadata
Repository anchor: SPEC-082 Matrix Client Well-Known Discovery, Support, and Policy Boundary
Canonical: yes

## Purpose

Define the focused Client-Server well-known boundary promoted from the
`SPEC-073` discovery, support, and policy lane.

This contract lets implementations adopt the public Matrix well-known response
shapes without turning the broader Client-Server API into an advertised Matrix
support claim. It is a fail-closed boundary for discovery metadata, support
metadata, and policy-server metadata.

## Scope

This contract covers only:

```text
GET /.well-known/matrix/client
GET /.well-known/matrix/support
GET /.well-known/matrix/policy_server
```

It does not define login, registration, sync, media, room behavior,
federation, Identity Service behavior, Push Gateway behavior, policy-server API
endpoints, or Matrix version advertisement through
`GET /_matrix/client/versions`.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#getwell-knownmatrixclient>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#getwell-knownmatrixsupport>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#getwell-knownmatrixpolicy_server>
- Checked at: 2026-05-15T22:40:00+09:00
- Timezone: Asia/Tokyo

## Client discovery response

`GET /.well-known/matrix/client` returns a JSON object. The adopted response may
include:

```json
{
  "m.homeserver": {
    "base_url": "https://example.test"
  }
}
```

`m.homeserver.base_url` must be an absolute `https` URL. Implementations must
not emit local, loopback, private-range, or non-HTTP(S) URLs. If a deployment
does not have a safe public Matrix Client-Server base URL, the route must fail
closed instead of advertising a guessed URL.

`m.identity_server` is not adopted by this contract. Identity Service metadata
belongs to the explicit Identity Service contracts and must not be inferred
from this discovery response.

## Support and policy responses

`GET /.well-known/matrix/support` may return support contacts when a deployment
has configured public support metadata:

```json
{
  "contacts": [
    {
      "email_address": "support@example.test",
      "matrix_id": "@support:example.test",
      "role": "m.role.admin"
    }
  ],
  "support_page": "https://example.test/support"
}
```

Every advertised contact field is optional, but each contact must include at
least one usable contact field. `support_page` must be an absolute `https` URL
when present. If no public support contact is configured, the route must fail
closed and must not fabricate support contacts.

`GET /.well-known/matrix/policy_server` may return policy-server metadata only
when a deployment has an explicit public policy-server base URL:

```json
{
  "m.policy_server": {
    "base_url": "https://policy.example.test"
  }
}
```

`m.policy_server.base_url` must be an absolute `https` URL. If policy-server
deployment is unsupported or unconfigured, the route must fail closed. Serving
this well-known document does not implement the policy-server API.

## Cache and error behavior

Successful well-known responses should be cacheable for a short bounded TTL
chosen by the deployment. The TTL must not cause stale metadata to remain
advertised after the underlying public URL or contact configuration is removed.

Unsupported or unconfigured well-known routes return `404 M_UNRECOGNIZED`.
Unsupported methods on known well-known routes return `405 M_UNRECOGNIZED`.
Malformed local configuration is a server error and must not be silently
coerced into a public advertisement.

## Fail-closed behavior

Implementations must fail closed:

- do not derive public base URLs from untrusted request `Host`,
  `X-Forwarded-*`, or similar headers unless the deployment has an explicit
  trusted proxy configuration;
- do not advertise Identity Service, Push Gateway, federation, or policy-server
  API support from these well-known responses;
- do not widen `GET /_matrix/client/versions` from this contract;
- do not treat the presence of `/.well-known/matrix/client` as evidence of full
  Matrix Client-Server API support;
- keep `SPEC-073` and `imoyan/houra-server#135` open until every included
  Client-Server full-breadth lane has passing evidence or explicit release
  exclusion.

## Japanese reader note

この contract は well-known の公開 metadata だけを狭く定義する。`/.well-known`
が返ることは Matrix Client-Server 全体の対応宣言ではなく、`/_matrix/client/versions`
の advertisement を広げる根拠にもならない。

## Adoption decision checklist

After this contract merges:

- `houra-server#229` may implement these three well-known routes against this
  response and failure boundary.
- `houra-client` work is needed only if client-side discovery parsing or UI
  behavior is intentionally adopted.
- `houra-labs` work is needed only if shared URL or well-known document
  validation helpers are intentionally adopted.
- Release evidence must keep `advertisement_allowed=false` for Client-Server
  API until the broader `SPEC-073` lanes are resolved for the release.

## Compatibility boundaries

- `SPEC-030` remains the Matrix versions endpoint contract.
- `SPEC-055` remains the Server-Server well-known and signing-key discovery
  contract.
- `SPEC-073` remains the Client-Server full-breadth gap inventory.
- `SPEC-074` remains the Server-Server full-breadth gap inventory.
- Passing this contract does not claim full Client-Server support, federation
  support, policy-server API support, Identity Service support, Push Gateway
  support, or Matrix v1.18 full compliance.
