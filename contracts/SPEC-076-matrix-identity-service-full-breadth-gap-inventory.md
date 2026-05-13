# SPEC-076: Matrix Identity Service Full-Breadth Gap Inventory

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Define the current Matrix v1.18 Identity Service API full-breadth gap inventory
before Houra widens any identity, third-party identifier, provider delivery, or
consent-flow support claim beyond the adopted representative boundary subset.

This contract records a fail-closed decomposition decision. It intentionally
does not add Identity Service endpoint behavior, move identity storage into the
homeserver, start external email or SMS provider delivery, widen
`GET /_matrix/client/versions`, or turn representative identity-service
boundary evidence into a full Identity Service claim.

## Scope

This contract is the bridge between the adopted Identity Service subset in
`SPEC-059` and the broader Matrix v1.18 Identity Service API.

The current release candidate keeps Identity Service API out of the advertised
Matrix support scope. Full identity-service work must be split into explicit
follow-up contracts or implementation issues before `houra-server` can cite it
as release evidence.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/identity-service-api/>
- Checked at: 2026-05-14T08:18:16+09:00
- Timezone: Asia/Tokyo

## Current decision

Identity Service API remains excluded from the current publishable Matrix
support claim.

The current release evidence may cite `SPEC-059` identity-service token, terms,
lookup, validation, bind, unbind, and privacy-failure gates as implementation
evidence, but it must also cite `imoyan/houra-server#138` as the open Identity
Service full-breadth scope decision until all gap lanes below have their own
passing evidence or explicit release exclusion.

Systems must fail closed:

- do not advertise Identity Service API or 3PID discovery support from
  representative lookup, validation, bind, or unbind vectors alone;
- keep `houra-server#138` open while unsupported identity-service breadth
  remains excluded from the release candidate;
- keep Matrix `/versions` empty for the current blocked release candidate
  unless a later release bundle shows included-domain evidence and matching
  release notes;
- keep Identity Service tokens, validation tokens, client secrets, lookup
  peppers, provider payloads, and association signatures redacted in every
  follow-up lane.

## Covered subset

The current adopted subset is useful implementation evidence but not a full
Identity Service claim:

- `SPEC-059`: separate service boundary, identity-service-scoped tokens,
  terms gate, public key and hash-detail shape, lookup, email validation
  session, 3PID bind, validated 3PID query, unbind, and privacy/auth failure
  handling.

## Required gap lanes

Future Identity Service full-breadth work must be split into at least these
lanes. Each lane needs either a narrower spec contract with vectors, an
implementation issue with explicit non-advertisement, or both.

### Service discovery, authentication, account, and terms breadth

Track service metadata and account lifecycle behavior beyond the representative
boundary vector:

- `GET /_matrix/identity/versions`;
- `GET /_matrix/identity/v2`;
- `GET /_matrix/identity/v2/account`;
- `POST /_matrix/identity/v2/account/register`;
- `POST /_matrix/identity/v2/account/logout`;
- `GET /_matrix/identity/v2/terms`;
- `POST /_matrix/identity/v2/terms`;
- token issuance, token expiry, bearer-token preference, query-token
  compatibility, CORS, and `M_TERMS_NOT_SIGNED` recovery behavior.

### Public key, ephemeral key, and signed association breadth

Track identity-service key handling and association signature behavior:

- `GET /_matrix/identity/v2/pubkey/{keyId}`;
- `GET /_matrix/identity/v2/pubkey/isvalid`;
- `GET /_matrix/identity/v2/pubkey/ephemeral/isvalid`;
- long-term key rotation, ephemeral key expiry, invalid key IDs, stale
  signatures, and association verification failure artifacts;
- trust boundary between the identity service, homeserver, and clients.

### Lookup, hash details, pepper, and privacy breadth

Track lookup behavior beyond the representative privacy vector:

- `GET /_matrix/identity/v2/hash_details`;
- `POST /_matrix/identity/v2/lookup`;
- `sha256` and `none` algorithm behavior where allowed;
- lookup pepper rotation, `M_INVALID_PEPPER`, `M_INVALID_PARAM`, unsupported
  algorithm, rate limit, malformed address, and no-match behavior;
- privacy evidence that lookup responses do not reveal unrelated 3PIDs or MXIDs.

### Validation session and provider delivery breadth

Track email and MSISDN validation sessions without assuming production provider
operations:

- `POST /_matrix/identity/v2/validate/email/requestToken`;
- `POST /_matrix/identity/v2/validate/email/submitToken`;
- `POST /_matrix/identity/v2/validate/msisdn/requestToken`;
- `POST /_matrix/identity/v2/validate/msisdn/submitToken`;
- `send_attempt`, `client_secret`, token expiry, repeated submit, provider
  bounce, provider timeout, and locale/template artifacts;
- explicit server responsibility boundaries for email and SMS provider delivery.

### Bind, validated 3PID, unbind, and association lifecycle breadth

Track publication and removal of associations beyond the representative bind
and unbind vectors:

- `POST /_matrix/identity/v2/3pid/bind`;
- `GET /_matrix/identity/v2/3pid/getValidated3pid`;
- `POST /_matrix/identity/v2/3pid/unbind`;
- homeserver-signed unbind, session-based unbind, unsupported unbind,
  stale-session, already-unbound, and post-unbind lookup behavior;
- persistence, expiry, replay protection, and audit artifacts for association
  lifecycle decisions.

### Invitation storage breadth

Track stored 3PID invitation behavior that is not covered by `SPEC-059`:

- `POST /_matrix/identity/v2/store-invite`;
- room ID, sender, medium, address, room alias, room avatar URL, room join
  rules, and room display metadata;
- invited-address privacy, provider delivery handoff, invitation expiry,
  repeated invite, invite cancellation, and unsupported storage behavior.

### Ephemeral invitation signing breadth

Track ephemeral key signing for stored invitations:

- `POST /_matrix/identity/v2/sign-ed25519`;
- lookup of stored invite tokens, ephemeral public key validity, signature
  shape, expiry, not-found behavior, and malformed token handling;
- separation between signing keys for identity-service associations and
  ephemeral invitation signatures.

### Consent UI, provider operations, and client handoff breadth

Track user-visible and provider-operational boundaries:

- consent UI ownership, accepted terms persistence, and retry after terms
  acceptance;
- browser redirect / fallback behavior for email and SMS verification;
- client handoff for identity server selection and account-data persistence;
- provider secrets, delivery logs, local paths, and addresses redacted in
  artifacts;
- issue refs for intentionally excluded provider delivery and consent UI.

### Release evidence and non-advertisement breadth

Track release-bundle linkage for Identity Service API:

- release evidence linkage to `SPEC-062`, `SPEC-064`, `SPEC-065`, and
  `SPEC-066`;
- included-domain pass/fail artifacts for every supported Identity Service
  lane;
- explicit release-note exclusions for invitation storage, ephemeral signing,
  provider delivery, and consent UI while unsupported;
- proof that representative `SPEC-059` evidence does not widen Matrix version
  advertisement.

## Adoption decision checklist

After this contract merges:

- `houra-server#138` may cite `SPEC-076` as the Identity Service full-breadth
  gap inventory for the current blocked release candidate.
- Future `houra-server` child issues should map one gap lane to one focused
  implementation or release-scope decision.
- `houra-client` work should be created only when user-facing identity-server
  selection, validation, consent, or account-data flows are explicitly scoped.
- `houra-labs` work should be created only when parser-only 3PID, association,
  signature, or redaction helpers are intentionally scoped.
- Release evidence must keep `advertisement_allowed=false` for Identity Service
  API until every included lane has passing evidence or is explicitly excluded
  from that release candidate.

## Compatibility boundaries

- `SPEC-059` remains a representative Identity Service boundary gate, not a
  full Identity Service API, provider delivery, invitation storage, or consent
  UI conformance gate.
- Identity Service support remains separate from Client-Server account
  management, Push Gateway, Application Service, Room Versions, Olm & Megolm,
  and external provider operations unless a later contract explicitly links the
  domains.
