# SPEC-064: Matrix Version Advertisement Release Gate

Status: draft
Feature profile: core
Contract type: gate
Matrix domain: Client-Server API
Canonical: yes

## Purpose

Define the release gate that prevents `GET /_matrix/client/versions` and
release notes from advertising Matrix support beyond available implementation
evidence.

## Scope

This contract is Matrix-defined, not Houra-defined. It binds Matrix version and
domain advertisement to stable-domain evidence from `SPEC-062` and black-box
homeserver evidence from `SPEC-063`. It does not add new endpoint behavior.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientversions>
- Source: <https://spec.matrix.org/v1.18/#specification-versions>
- Checked at: 2026-05-10T23:08:00+09:00
- Timezone: Asia/Tokyo

## Inclusion rule

`GET /_matrix/client/versions` may include a Matrix version or an unstable
feature flag only when all included behavior has evidence:

- the domain exists in the `SPEC-062` coverage report;
- `contract_gate.status` is `pass`;
- `implementation_gate.status` is `pass` for every required implementation
  repo;
- required adoption issue refs are linked;
- Complement-compatible evidence is present when the domain requires
  homeserver black-box coverage;
- release notes list the supported domains, unsupported domains, room versions,
  excluded unstable MSCs, and artifact refs.

Missing, failed, stale, or secret-leaking evidence blocks advertisement.

## Refusal behavior

The release gate fails closed. A candidate that tries to advertise `v1.18`
while any included stable domain has `implementation_gate.status` other than
`pass` must be rejected before merge or release tagging.

The gate records:

- requested Matrix version;
- advertised domains;
- excluded domains;
- evidence refs;
- blocking reasons;
- release artifact path.

## Adoption boundary

`houra-server` owns the `/_matrix/client/versions` response and release gate.
`houra-client` owns parsing and compatibility smoke evidence so client release
notes do not claim unsupported server behavior. `houra-labs` is out of scope
unless a later shared-core release starts advertising Matrix behavior.

## Compatibility boundaries

- Existing `/_houra/**` and `/_matrix/**` behavior stays available.
- This contract defines release-advertisement gating only.
- Passing this gate does not itself implement any Matrix domain.
- After this spec PR is merged, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if shared-core release
  artifacts begin advertising Matrix support.
