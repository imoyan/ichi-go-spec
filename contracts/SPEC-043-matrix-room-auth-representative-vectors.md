# SPEC-043: Matrix Room Auth Representative Vectors

Status: draft
Feature profile: events
Contract type: boundary
Matrix domain: Room Versions
Canonical: yes

## Purpose

Define representative Matrix v1.18 room version 12 authorization vectors for
membership, power levels, and redaction handling.

This contract adds concrete auth-rule fixtures after `SPEC-040`, `SPEC-041`,
and `SPEC-042`. It is a vector gate only; it does not claim complete
room-version authorization support.

## Scope

This contract follows Matrix-defined room version 12 auth rules, not Houra-only
policy. It covers representative cases for:

- membership `join` authorization
- `m.room.power_levels` validation and creator handling
- sending `m.room.redaction` events
- deciding whether an accepted redaction event should be applied

This contract does not cover every Matrix authorization rule, full state
resolution, rejected event handling, federation auth-chain validation, room
upgrades, or all historical room-version differences.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/rooms/v12/#authorization-rules>
- Source: <https://spec.matrix.org/v1.18/rooms/v12/#handling-redactions>
- Checked at: 2026-05-10T15:35:00+09:00
- Timezone: Asia/Tokyo

## Membership vectors

The membership vectors cover a minimal public-room join:

- A `join` membership event where `sender` equals `state_key` may pass when the
  room is public and the user is not banned.
- A `join` membership event where `sender` differs from `state_key` is rejected.

Invite, leave, ban, knock, restricted join rules, third-party invites, and
federated join auth are left to later auth and federation gates.

## Power-level vectors

The power-level vectors cover representative room version 12 behavior:

- Room creators, derived from the create event sender and the room-version 12
  `additional_creators` field, must not be listed in `content.users` of
  `m.room.power_levels`.
- Integer-valued power-level fields must stay integers.
- A room creator may set valid power levels for non-creators in these
  representative vectors.

The vectors do not claim full comparison coverage for every changed or removed
power-level field.

## Redaction vectors

Redaction handling has two layers:

- The `m.room.redaction` event itself is authorized like other events.
- Applying a redaction to the target event requires either sufficient redact
  power level or a matching sender domain between the redaction event and the
  target event.

The redaction vectors cover sufficient power, same-domain application, and
cross-domain low-power denial. They do not cover all redaction event content,
historical redaction algorithms, or federation timing edge cases.

## Adoption issue creation

After this spec PR is merged:

- create an `houra-server` adoption issue for representative room version 12
  auth vector evaluation, including membership, power-level, and redaction
  allow/deny evidence
- create an `houra-labs` adoption issue only if a shared room-version auth
  helper is intentionally adopted
- do not create an `houra-client` adoption issue for this contract unless the
  UI-free client core begins validating room-version auth vectors locally

Do not create implementation adoption issues before this contract is merged.

## Compatibility boundaries

- Existing `/_houra/client/**` room behavior stays available.
- Passing this contract does not claim complete Matrix room-version auth,
  complete state resolution, federation auth-chain validation, or Matrix v1.18
  full compliance.
- Passing this contract must not widen `GET /_matrix/client/versions`
  advertisement.
