# SPEC-061: Matrix Federation Interop Smoke

Status: draft
Feature profile: events
Contract type: gate
Matrix domain: Server-Server API
Canonical: yes

## Purpose

Define the Matrix v1.18 two-homeserver and reference-homeserver federation
smoke gate for Houra federation adoption evidence.

## Scope

This contract is Matrix-defined, not Houra-defined. It binds the previously
defined federation contracts into runnable smoke evidence. It does not add new
federation endpoint behavior beyond `SPEC-055`, `SPEC-056`, and `SPEC-057`.

This contract covers one two-Houra-homeserver smoke, one Houra plus reference
homeserver interop checklist, and one Docker Compose or CI lane adoption
requirement. It does not replace Complement, does not claim full Matrix v1.18
federation compliance, and does not adopt unstable MSC tests.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/server-server-api/#server-server-api>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#transactions>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#joining-rooms>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#backfilling-and-retrieving-missing-events>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#room-state-resolution>
- Complement: <https://github.com/matrix-org/complement>
- Checked at: 2026-05-10T22:11:00+09:00
- Timezone: Asia/Tokyo

## Two Houra homeserver smoke

The minimal two-Houra smoke uses two independent homeservers with distinct
server names, signing keys, storage, and federation listener addresses:

- `hs-a.example.test`
- `hs-b.example.test`

The smoke must demonstrate:

1. delegated discovery or direct resolution for both server names;
2. signing-key publication and cache refresh;
3. room creation on `hs-a` with room version `12`;
4. remote join from `hs-b` through make_join and send_join;
5. federated transaction delivery from `hs-b` to `hs-a`;
6. backfill, event_auth, and state_ids recovery for a missing event;
7. representative state-resolution evidence for the accepted room version;
8. local client `/sync` visibility on both homeservers after federation.

Each step records request path, origin, destination, room ID, room version,
event IDs when applicable, command or test name, and pass/fail evidence.

## Reference homeserver interop

The reference smoke runs the same stable federation path with one Houra
homeserver and one reference homeserver. The reference homeserver may be
Synapse or another Complement-compatible reference image, but the behavior
source remains the Matrix v1.18 stable specification.

The interop checklist must record:

- reference homeserver name and image/tag;
- Houra server name and image/tag or commit;
- stable spec version under test;
- disabled unstable MSC tests, if any;
- make_join/send_join direction;
- transaction direction;
- backfill/event_auth/state_ids direction;
- pass/fail result and failure artifact links.

## Docker Compose and CI lane

The adoption lane may be plain Docker Compose, Complement, or a repo CI wrapper
around both. A passing implementation must provide:

- reproducible build command for the Houra homeserver image;
- two-Houra topology command;
- Houra plus reference homeserver topology command;
- federation ports for client and server traffic;
- TLS or Complement PKI setup for federation traffic;
- isolated storage per homeserver;
- health checks before smoke steps run;
- artifacts for request/response summaries with secrets redacted.

Complement is treated as a black-box Matrix homeserver integration test
framework. Passing this smoke is not a substitute for the later broad
Complement lane under the conformance and release-advertisement phase.

## Compatibility boundaries

- Existing `/_houra/client/**`, `/_matrix/client/**`, `/.well-known/**`,
  `/_matrix/key/**`, and existing `/_matrix/federation/**` behavior stays
  available.
- Discovery and signing-key behavior come from `SPEC-055`.
- Transaction, join, and invite exchange come from `SPEC-056`.
- Backfill, event_auth, state_ids, and representative state-resolution evidence
  come from `SPEC-057`.
- This contract does not claim get_missing_events, timestamp lookup, leave,
  knock, third-party invites, federation E2EE EDU handling, policy servers,
  complete Complement coverage, or Matrix v1.18 full federation compliance.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create an adoption issue for `houra-server`.
  Do not create `houra-client` work unless a later client-visible federation
  smoke surface is intentionally added. Create an `houra-labs` issue only if
  parser-only or room-version-helper adoption is intentionally scoped with
  parity vectors and performance gates.
