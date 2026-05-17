# SPEC-039: Matrix Client-Server MVP Live E2E Gate

Status: draft
Feature profile: core
Contract type: gate
Matrix domain: Client-Server API
Canonical: yes

## Purpose

Define the live end-to-end adoption gate for the Matrix Client-Server
MVP-equivalent compatibility layer described by `SPEC-030` through `SPEC-038`.

This contract does not add a new public endpoint. It defines when the already
specified Matrix v1.18 Client-Server MVP endpoint families may be treated as one
integrated server/client adoption milestone.

## Scope

The gate covers the additive `/_matrix/**` behavior for:

- versions and advertisement discipline from `SPEC-030` and `SPEC-031`
- login flows, password login, whoami, and logout from `SPEC-032`
- registration from `SPEC-033`
- devices and sessions from `SPEC-034`
- room create, join, leave, and state from `SPEC-035`
- send event and messages pagination from `SPEC-036`
- sync from `SPEC-037`
- media upload and authenticated download from `SPEC-038`

Existing `/_houra/client/**` behavior must remain available. Passing this gate
does not mean Matrix v1.18 full compliance; it only means the Client-Server
MVP-equivalent subset is integrated across the server and client.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/>
- Source: <https://spec.matrix.org/v1.18/appendices/>
- Checked at: 2026-05-10T13:57:19+09:00
- Timezone: Asia/Tokyo

## Live scenario

A conforming adoption must run a live client against a live server and complete
this ordered scenario without using implementation internals as behavior
sources:

1. Call `GET /_matrix/client/versions` and confirm it advertises only behavior
   supported by the evidence in this repository.
2. Discover login flows with `GET /_matrix/client/v3/login`.
3. Register a Matrix user with `POST /_matrix/client/v3/register`.
4. Authenticate with password login and retain the returned access token in the
   host-owned client layer.
5. Confirm session identity with `GET /_matrix/client/v3/account/whoami`.
6. List or inspect devices through the `SPEC-034` device/session surface.
7. Create a room, join it by room ID or supported alias input, fetch state, and
   leave only after message/sync checks are complete.
8. Send a `m.room.message` event with a stable transaction ID.
9. Fetch messages and confirm the sent event is visible through pagination.
10. Run initial and incremental `/sync` checks and confirm state, timeline,
    account data, and sync token handling follow `SPEC-037`.
11. Upload media through `POST /_matrix/media/v3/upload`, then download it
    through authenticated `/_matrix/client/v1/media/download/**` paths.
12. Logout and confirm token invalidation or the corresponding Matrix error
    behavior expected by the implemented session surface.

Each step must cite the matching `SPEC-*` contract and at least one canonical
vector from `test-vectors/`.

## Evidence requirements

The adoption record must include:

- `houra-spec` tag or commit used as canonical input
- `houra-server` commit, PR, and release tag or image digest
- `houra-client` commit, PR, and package/build identifier
- `houra-labs` commit only when a shared parser or binding is used by the gate
- command lines for server vector tests, client vector tests, and live e2e
- pass/fail result for each scenario step
- `/versions` advertisement result and any deliberately unadvertised endpoint
  families
- known exclusions, which must not include any endpoint family required by this
  contract
- clean-room confirmation that implementation repositories were not used as
  behavior sources

The README adoption report may summarize these fields, but must link or name
the durable PR/check evidence.

## Evidence boundary

Product MVP happy path evidence and Docker Compose deploy smoke evidence are
separate records even when they use the same local server instance.

Product MVP happy path evidence proves public behavior:

- the `SPEC-030` through `SPEC-038` contracts and vectors used as canonical
  input;
- the `design/ui-surfaces/product-mvp.json` `product-mvp-happy-path`
  acceptance flow, when UI evidence is included;
- server/client refs, package or image identifiers, and command lines used for
  vector and live e2e checks;
- pass/fail for registration, login, room creation, send/messages, sync,
  media round trip, refresh, logout, and login-again behavior;
- remaining Product MVP blockers and any explicitly excluded Matrix
  Client-Server breadth.

Docker Compose deploy smoke evidence proves operational readiness only:

- container startup and dependency ordering;
- migration or schema-setup completion;
- health check and server/client connectivity;
- PostgreSQL persistence and auth-hardening smoke when those are the target of
  the deploy lane;
- restart or backup/restore smoke only when the lane explicitly includes it;
- secret, token, local path, database URL, image registry credential, and
  environment redaction.

Do not use Docker Compose startup success as a Product MVP happy path pass
without the contract/vector/UI/server-client evidence above. Do not use Product
MVP happy path success as Docker Compose deploy readiness without startup,
migration, health, connectivity, persistence/auth, and redaction evidence.

Release notes and README adoption reports must name the evidence class for each
row. If a check mixes both classes, split the row or say which parts are Product
MVP behavior evidence and which parts are deploy smoke evidence. Evidence must
not include raw secrets, bearer tokens, refresh tokens, database URLs, private
local paths, or machine-specific environment values.

## Japanese reader note

Product MVP happy path evidence は public behavior の証跡であり、Docker Compose
deploy smoke は起動、migration、health check、connectivity、persistence/auth、
redaction の運用証跡です。同じローカル server を使っていても別 evidence class
として記録し、Compose 起動成功だけを Product MVP pass として扱わないでください。

## Adoption issue creation

After this spec PR is merged:

- create an `houra-server` adoption issue for a live e2e CI lane that starts a
  server from a pinned commit/tag and proves the server side of every scenario
  step
- create an `houra-client` adoption issue for a UI-free core live e2e run
  against the pinned server target
- create an `houra-labs` adoption issue only if the gate adopts or changes a
  shared parser, identifier helper, URI helper, or binding facade
- create a separate `houra-server` deploy smoke issue when Docker Compose
  startup, migration, health check, server/client connectivity, PostgreSQL
  persistence/auth hardening, backup/restore, restart, or secret redaction is
  part of the release candidate evidence

Do not create implementation adoption issues before this contract is merged.

## Compatibility boundaries

- The gate must not widen Matrix version advertisement beyond endpoint evidence
  available at the tested commits.
- The gate must not require unstable MSC behavior.
- The gate must not treat Element, Synapse, Complement, or any implementation
  repository as canonical behavior input.
- Complement-compatible CI belongs to the later conformance/release phase; this
  gate is the MVP-equivalent live smoke for `SPEC-030` through `SPEC-038`.
- E2EE, federation, application service, identity service, push gateway, room
  version algorithms, account data breadth, receipts, typing, read markers,
  filters, presence, aliases, invites, kicks, bans, redactions, and reporting
  are outside this MVP gate unless a later contract explicitly adds them.
