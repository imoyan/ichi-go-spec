# SPEC-117: Matrix Application Service Third-Party Network Directory Breadth

Status: draft
Feature profile: core
Contract type: boundary
Matrix domain: Application Service API
Canonical: yes

## Purpose

Define the parser-only third-party network directory boundary promoted from the
`SPEC-075` `third-party-network-directory-breadth` lane after `SPEC-058`
established representative Application Service registration and query behavior.

This contract lets implementation repositories adopt parser-only helpers for
third-party protocol metadata, location, and user lookup surfaces without
claiming bridge protocol implementations, room directory listing for third-party
networks, real third-party provider integration, runtime query adoption, or full
Application Service API support.

## Scope

This contract covers parser-only boundary definitions for:

```text
GET /_matrix/app/v1/thirdparty/location
GET /_matrix/app/v1/thirdparty/location/{protocol}
GET /_matrix/app/v1/thirdparty/protocol/{protocol}
GET /_matrix/app/v1/thirdparty/user
GET /_matrix/app/v1/thirdparty/user/{protocol}
```

Only these parser surfaces are defined:

- protocol metadata shape: `instances`, `user_fields`, `location_fields`, `icon`;
- location item shape: `alias`, `protocol`, `fields`;
- user item shape: `userid`, `protocol`, `fields`, `display_name`, `avatar_url`;
- authorization failure artifacts for missing or invalid `hs_token`;
- legacy route fallback descriptors as parser-only annotations, not runtime.

No runtime adoption is claimed for any third-party network endpoint.

This contract does not define actual third-party network bridge protocol
implementations, appservice-managed room directory listing for third-party
networks, real third-party provider integration, or runtime query adoption.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/application-service-api/#get_matrixappv1thirdpartylocation>
- Source: <https://spec.matrix.org/v1.18/application-service-api/#get_matrixappv1thirdpartyprotocolprotocol>
- Source: <https://spec.matrix.org/v1.18/application-service-api/#get_matrixappv1thirdpartyuser>
- Source: <https://spec.matrix.org/v1.18/application-service-api/#get_matrixappv1thirdpartylocationprotocol>
- Source: <https://spec.matrix.org/v1.18/application-service-api/#get_matrixappv1thirdpartyuserprotocol>
- Parent contract: `SPEC-058`, `SPEC-105`
- Gap inventory: `SPEC-075`
- Checked at: 2026-05-17T12:00:00+09:00
- Timezone: Asia/Tokyo

## Parser-Only Boundary

Implementations adopting this contract MUST NOT claim runtime adoption of any
third-party network query endpoint. The adoption boundary is limited to parsing
and validating response shapes for correctness checks and artifact helpers.

Protocol metadata parsers MUST validate:

- `instances` is a non-null array when present;
- `user_fields` and `location_fields` are arrays of strings when present;
- `icon` is a string when present.

Location item parsers MUST validate:

- `alias` is a well-formed Matrix room alias string;
- `protocol` is a non-empty string;
- `fields` is a non-null object when present.

User item parsers MUST validate:

- `userid` is a well-formed Matrix user ID string;
- `protocol` is a non-empty string;
- `fields` is a non-null object when present;
- `display_name` and `avatar_url` are strings when present.

Authorization failure parsers MUST validate:

- absent `Authorization` header produces a 401 descriptor;
- invalid `hs_token` produces a 403 descriptor.

Legacy route fallback descriptors are recorded as parser annotations only.
Runtime legacy fallback routing is not adopted by this contract.

## Resource Bounds

Parser adoption is bounded:

- runtime query adoption: false;
- bridge protocol runtime claimed: false;
- room directory listing for third-party networks claimed: false;
- real third-party provider integration claimed: false;
- outbound bridge connections claimed: false;
- versions advertisement widened: false.

Implementations MUST fail closed when these bounds are missing or weakened.

## Fail-Closed Behavior

Implementations must reject:

- absent `Authorization` header without returning a 401 descriptor;
- invalid `hs_token` without returning a 403 descriptor;
- protocol metadata missing the required shape fields;
- location items missing `alias` or `protocol`;
- user items missing `userid` or `protocol`;
- runtime adoption inferred from parser-only evidence;
- bridge protocol runtime behavior implied by passing this contract.

## Adoption Decision Checklist

After this contract merges:

- `houra-labs#134` may adopt parser-only helpers for third-party protocol
  metadata, location, and user shapes using this vector.
- `houra-server` adoption work for runtime third-party network queries MUST NOT
  be created from this contract alone; a separate runtime contract is required
  when bridge runtime behavior is explicitly scoped.
- `houra-server#137` remains the owner for Application Service full-breadth
  scope until all gap lanes have passing evidence or explicit release exclusion.
- Release evidence must keep `advertisement_allowed=false` for Application
  Service API until the broader `SPEC-075` lanes are resolved for the release.

## Compatibility Boundaries

- `SPEC-058` remains the representative Application Service registration,
  transaction, user-query, and room-alias-query gate.
- `SPEC-105` remains the parser-only Application Service artifact breadth
  contract.
- `SPEC-075` remains the Application Service full-breadth gap inventory.
- `SPEC-116` owns the user and room-alias query runtime boundary.
- `SPEC-118` owns the appservice ping and liveness runtime boundary.
- Passing this contract does not claim bridge protocol runtime, third-party
  network room directory, real provider integration, Complement full-breadth,
  or Matrix v1.18 full compliance.
