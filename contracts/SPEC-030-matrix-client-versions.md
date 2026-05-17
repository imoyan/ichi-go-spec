# SPEC-030: Matrix Client Versions

Status: draft
Feature profile: core
Contract type: endpoint
Matrix domain: Client-Server API
Canonical: yes

## Purpose

Define the Matrix Client-Server API versions endpoint used to advertise Matrix
compatibility.

## Scope

This endpoint is Matrix-defined, not Houra-defined. It is the first public
contract in the Matrix compliance path and must be kept separate from
`SPEC-001`, which remains the Houra-owned discovery endpoint.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientversions>
- Checked at: 2026-05-09T15:29:22+09:00
- Timezone: Asia/Tokyo

## Request

```text
GET /_matrix/client/versions
```

The request does not require authentication.

## Response fields

```json
{
  "versions": ["v1.18"],
  "unstable_features": {}
}
```

## Server expectations

- `versions` must be present and must be an array of non-empty strings.
- A Matrix stable version must not be listed until the server has evidence for
  the endpoint set and deprecated behavior required by that version.
- `unstable_features`, when present, must be an object whose values are
  booleans.
- `unstable_features` must not be used to toggle stable Matrix behavior.
- Experimental feature names should be namespaced.

## Client expectations

- Clients must parse the response as a JSON object.
- Clients must treat absent `unstable_features` as an empty unsupported-feature
  map.
- Clients must not infer support for a Matrix API solely from this endpoint;
  feature-specific behavior still requires endpoint-level handling.
