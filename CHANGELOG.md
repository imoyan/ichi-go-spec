# Changelog

This file records `houra-spec` Implementation Adoption Reports and pre-release
readiness summaries that have been moved out of `README.md` to keep the README
focused on the current baseline. Compatibility classification, contracts,
vectors, and design inputs follow the same definitions as `SOURCE_OF_TRUTH.md`
"Pre-1.0 Compatibility Policy".

The most recent Implementation Adoption Reports remain in `README.md`. Older
entries are preserved here verbatim and are referenced by their `v0.2.0-pre.X`
release targets.

## Gap Lane Contract Additions

### SPEC-113 through SPEC-121: CS-API and AS-API gap lane contracts (2026-05-17)

Classification: additive

Added nine contracts and their test vectors to address the remaining open gap
lanes from `SPEC-073` (Client-Server) and `SPEC-075` (Application Service):

- `SPEC-113`: CS-API auth/refresh/fallback/account lifecycle — child boundary
  for `SPEC-073` Lane 2. Covers `POST /login/get_token` (parser-only),
  `POST /refresh` (bounded runtime), and `POST /account/deactivate`
  (parser-only). Referenced by `houra-labs#133` and `houra-server#252`.

- `SPEC-114`: AS-API registration/namespace/lifecycle runtime — child boundary
  for `SPEC-075` Lane 1. Adds representative runtime behavior (multi-registration
  loading, exclusive namespace enforcement, token redaction, restart reload) on
  top of the `SPEC-105` parser-only foundation. Referenced by `houra-server#253`.

- `SPEC-115`: AS-API transaction/event delivery runtime — child boundary for
  `SPEC-075` Lane 2. Covers `PUT /_matrix/app/v1/transactions/{txnId}`,
  ephemeral batches, retry/backoff, idempotency, unknown route/method errors, and
  legacy route fallback. Referenced by `houra-server#254`.

- `SPEC-116`: AS-API query/user/room-alias/namespace runtime — child boundary
  for `SPEC-075` Lane 3. Covers user and room-alias query endpoints, authorization
  failures, namespace-miss 404, and exclusive-namespace-before-local resolution
  order. Referenced by `houra-server#255`.

- `SPEC-117`: AS-API third-party network directory breadth — child parser-only
  boundary for `SPEC-075` Lane 4. Defines protocol metadata, location item, and
  user item shapes for all five `/_matrix/app/v1/thirdparty/…` endpoints.
  Referenced by `houra-labs#134`.

- `SPEC-118`: AS-API ping/liveness breadth — child boundary for `SPEC-075` Lane 5.
  Covers `POST /_matrix/app/v1/ping` and
  `POST /_matrix/client/v1/appservice/{appserviceId}/ping` with `transaction_id`
  passthrough, `duration_ms` reporting, failure propagation, and token redaction.
  Referenced by `houra-server#256`.

  parser/policy boundary for `SPEC-075` Lane 6. Parser-only for `as_token`
  masquerade, `user_id`/`device_id` assertion, timestamp massaging, and
  `m.login.application_service`; bounded runtime policy for namespace-owned
  user/alias management without UIA. Referenced by `houra-server#257`.

- `SPEC-120`: AS-API CS extension sync/device breadth — child parser-only
  boundary for `SPEC-075` Lane 7. Covers virtual user sync, room directory listing,
  device creation/deletion, and cross-signing key upload without UIA, with E2EE
  evidence gate and OAuth-homeserver must-support-as_token policy.
  Referenced by `houra-labs#135`.

- `SPEC-121`: AS-API bridge security/observability breadth — child policy-and-
  evidence boundary for `SPEC-075` Lane 8. Defines five security policies and five
  release evidence requirements for any future bridge adoption PR. No runtime
  behavior adopted.

None of these contracts widen `GET /_matrix/client/versions` or change the
`advertisement_allowed=false` decision for any domain. `houra-server#135` and
`houra-server#137` remain open. Implementation follow-up issues are enumerated
per contract in the adoption decision checklists above.

## Earlier Implementation Adoption Reports

### Flutter lab client initial adoption

- Implementation repository: `imoyan/houra-labs`
- Repository role: Flutter lab client candidate for the covered Houra public
  contract.
- Implementation commit inspected: `1e2609beacdb0ed171c721698a86342825f22c79`
- Spec input inspected: current `main` after SPEC-008 idempotency, SPEC-010
  pagination, and SPEC-020 download metadata updates.

Observed checks:

| Check | Result | Notes |
|---|---|---|
| `dart run tool/check_spec_sync.dart` | pass | Reads this spec checkout and validates bundled theme/vector references |
| `flutter analyze` | pass | No analyzer issues |
| `flutter test` | pass | SPEC-008 `client_transaction_id` coverage is implemented |

Profile status:

| Profile | Status | Notes |
|---|---|---|
| core | pass | Existing contract tests passed |
| auth | pass | Existing contract tests passed |
| rooms | pass | Existing contract tests passed |
| events | pass | Existing contract tests passed |
| messaging | pass | SPEC-008 idempotency vector is implemented |
| sync | pass | Existing contract tests passed |
| media | pass | Existing contract tests passed |

No server implementation detail was used as a specification source. The
implementation follows this repository as the canonical behavior source.

### TypeScript server MVP adoption

- Implementation repository: `imoyan/houra-server`
- Repository role: production TypeScript server baseline for the covered Houra
  public contract.
- Implementation issue: `imoyan/houra-server#1`
- Implementation pull request: `imoyan/houra-server#2`
- Implementation commit inspected: `4c64718ff1608b99017de1166cd1c74aeebce053`
- Spec behavior input inspected: `5e882e909aaf9a5c7d6af557b0b1d8addb1b50ae`
- Matrix reference: Matrix Specification 1.18, checked on 2026-05-08 JST.

Observed checks:

| Check | Result | Notes |
|---|---|---|
| `npm run typecheck` | pass | TypeScript strict check |
| `npm run build` | pass | Production server build |
| `npm test` | pass | 31 tests, including 27 request vectors |
| GitHub Actions `CI / test` | pass | Ran on PR #2 head |

Profile status:

| Profile | Status | Notes |
|---|---|---|
| core | pass | Versions and structured error behavior covered |
| auth | pass | Login, whoami, logout, and token invalidation covered |
| rooms | pass | Create, join, leave, and state endpoints covered |
| events | pass | Event-shaped state, sync, and timeline responses covered |
| messaging | pass | Text send idempotency and conflict behavior covered |
| sync | pass | Room list, timeline, and incremental sync covered |
| media | pass | Base64 upload and metadata download descriptors covered |

No client implementation or lab prototype was used as a specification source.
The server consumes this repository's contracts and request vectors as the
behavior source.

### TypeScript client core MVP adoption

- Implementation repository: `imoyan/houra-client`
- Repository role: UI-free TypeScript client core for the covered Houra public
  contract.
- Implementation issue: `imoyan/houra-client#1`
- Implementation pull request: `imoyan/houra-client#2`
- Implementation commit inspected: `44c23c5868a8a2c62e41b3829ae83dcd1d7a680c`
- Spec behavior input inspected: `5e882e909aaf9a5c7d6af557b0b1d8addb1b50ae`
- Matrix reference: Matrix Specification 1.18, checked on 2026-05-08 JST.

Observed checks:

| Check | Result | Notes |
|---|---|---|
| `npm run typecheck` | pass | TypeScript strict check |
| `npm run build` | pass | Client core declaration build |
| `npm test` | pass | 36 tests covering request vectors and parser vectors |
| GitHub Actions `CI / test` | pass | Ran on PR #2 head |

Profile status:

| Profile | Status | Notes |
|---|---|---|
| core | pass | Versions and structured error parsing covered |
| auth | pass | Login, whoami, logout request formation and parsing covered |
| rooms | pass | Room request formation and room parser behavior covered |
| events | pass | Event parser and malformed event rejection covered |
| messaging | pass | Text send request formation and conflict error parsing covered |
| sync | pass | Room list, timeline, and sync parsing covered |
| media | pass | Upload request formation and metadata parser behavior covered |

No server implementation or lab prototype was used as a specification source.
The client consumes this repository's contracts and request/response vectors as
the behavior source.

### Server/client live e2e smoke

- Implementation repository: `imoyan/houra-client`
- Smoke issue: `imoyan/houra-client#3`
- Smoke pull request: `imoyan/houra-client#4`
- Client commit inspected: `e3be2330411ac4952195b5fe17308840bc74ee5b`
- Server target commit: `4c64718ff1608b99017de1166cd1c74aeebce053`
- Spec input inspected: `88053e35195c0b30f77d856f83ad8dd59eebf9ad`
- Matrix reference: Matrix Specification 1.18, checked on 2026-05-08 JST.

Observed checks:

| Check | Result | Notes |
|---|---|---|
| local live `npm run test:e2e` | pass | Client connected to local `houra-server` over HTTP |
| GitHub Actions `CI / test` | pass | Vector and parser tests |
| GitHub Actions `CI / e2e` | pass | Checked out pinned `houra-server` and ran live HTTP smoke |

E2E smoke covered discovery, login, whoami, room create/join/list/state,
message send and idempotent retry/conflict, sync, timeline pagination, media
upload/metadata, leave, logout, and post-logout unauthorized behavior.

The server is used only as the live HTTP target for connection smoke coverage;
the expected public behavior remains defined by this repository's contracts and
vectors.

### TypeScript server PostgreSQL Product MVP adoption

- Implementation repository: `imoyan/houra-server`
- Repository role: production TypeScript server with PostgreSQL persistence and
  Docker Compose deploy baseline for the covered Houra public contract.
- Implementation issue: `imoyan/houra-server#3`
- Implementation pull request: `imoyan/houra-server#4`
- Implementation commit inspected: `99b614a34b13faba7c84fdd54ee2f31d7960848f`
- Spec behavior input inspected: `v0.2.0-pre.2`
- Matrix reference: Matrix Specification 1.18, checked on 2026-05-08 JST.
- Started at: 2026-05-09T07:17:11+09:00
- Ended at: 2026-05-09T07:33:10+09:00
- Elapsed seconds: 959
- Codex usage: unavailable in the local Codex App session.

Observed checks:

| Check | Result | Notes |
|---|---|---|
| `npm run typecheck` | pass | TypeScript strict check |
| `npm run build` | pass | Production server build |
| `npm test` | pass | 31 passed, 1 PostgreSQL test skipped by default |
| `DATABASE_URL=... npm run db:migrate` | pass | Applied SQL migration to test PostgreSQL |
| `HOURA_TEST_DATABASE_URL=... npm run test:postgres` | pass | Restart persistence for sessions, rooms, messages, and media metadata |
| `docker compose build` | pass | Server image built with compiled migration runner |
| `docker compose up -d` + live HTTP smoke | pass | login, room create, send text, and sync against PostgreSQL-backed server |
| GitHub Actions `CI / test` | pass | Ran on PR #4 head |

Profile status:

| Profile | Status | Notes |
|---|---|---|
| core | pass | Existing discovery/vector behavior retained |
| auth | pass | DB-backed login, whoami, logout, and hashed access-token session lifecycle |
| rooms | pass | DB-backed create, join, leave, list, and state |
| events | pass | Event rows persist across store restarts |
| messaging | pass | DB-backed send and idempotency key behavior |
| sync | pass | DB-backed room sync and timeline smoke |
| media | pass | Local filesystem storage path with DB-backed media metadata |

Binary media download remains outside this adoption report. Any new binary
download endpoint must be specified here first with contract and vector changes.

No client implementation or lab prototype was used as a specification source.
Server database tables and migrations are implementation evidence only; they do
not define public behavior.

### Expo React Native Product MVP adoption

- Implementation repository: `imoyan/houra-client`
- Repository role: production React Native client with UI-free TypeScript core
  and Expo MVP app layer for the covered Houra public contract.
- Implementation issue: `imoyan/houra-client#6`
- Implementation pull request: `imoyan/houra-client#7`
- Implementation commit inspected: `3a61d505e4ec98e5f8d8d1c10d2279c277f05954`
- Spec behavior input inspected: `v0.2.0-pre.2`
- Server target for live smoke: `houra-server`
  `99b614a34b13faba7c84fdd54ee2f31d7960848f`
- Matrix reference: Matrix Specification 1.18, checked on 2026-05-08 JST.
- Started at: 2026-05-09T07:37:41+09:00
- Ended at: 2026-05-09T08:04:17+09:00
- Elapsed seconds: 1596
- Codex usage: unavailable in the local Codex App session.

Observed checks:

| Check | Result | Notes |
|---|---|---|
| `npm run typecheck` | pass | Core and Expo app TypeScript checks |
| `npm run build` | pass | UI-free client core declaration build |
| `npm test` | pass | 38 passed, 1 live e2e skipped by default |
| `npx expo config --type public` | pass | Expo SDK 55 public config resolved |
| `npx expo export --platform ios --output-dir /tmp/houra-client-expo-export --clear` | pass | Metro bundle smoke for app entry and Expo UI imports |
| `HOURA_E2E_BASE_URL=http://localhost:3000 npm run test:e2e` | pass | Live happy path against PostgreSQL-backed Docker Compose server |
| GitHub Actions `CI / test` | pass | Ran on PR #7 head |
| GitHub Actions `CI / e2e` | pass | Live HTTP smoke ran on PR #7 head |

Profile status:

| Profile | Status | Notes |
|---|---|---|
| core | pass | Existing core request/parsing behavior retained |
| auth | pass | Login and logout exposed through Expo UI; session stored by host app adapter |
| rooms | pass | Room list and create flow exposed through Expo UI |
| events | pass | Timeline event parsing reused from UI-free core |
| messaging | pass | Message composer uses core text-send API |
| sync | pass | Live e2e covers sync against PostgreSQL-backed server |
| media | pass | Media upload metadata flow exposed through Expo UI |

Dependency audit note: the client reported a moderate PostCSS advisory through
Expo CLI / Metro config. The available `npm audit fix --force` path would
downgrade Expo to 49, so the implementation recorded it as follow-up evidence
rather than weakening the Expo SDK 55 baseline.

No server implementation or lab prototype was used as a specification source.
The server was used only as the live HTTP target for connection smoke coverage;
the expected public behavior remains defined by this repository's contracts and
vectors.

### Product MVP pre-release readiness

- Release target: `v0.2.0-pre.3`
- Compatibility classification: workflow/adoption evidence update only.
- Changed public behavior profiles: none.
- Changed contracts: none.
- Changed vectors: none.
- Implementation evidence added: PostgreSQL-backed `houra-server` Product MVP
  adoption and Expo React Native `houra-client` Product MVP adoption.
- Completion claim: Houra Product MVP subset is implementation-ready for the
  covered contract/vector scope. This is not a Matrix full-spec compliance
  claim.
- Remaining known gaps: binary media download endpoint, production account
  registration, federation, encrypted media, simulator/manual UI QA, and the
  recorded Expo CLI / PostCSS audit follow-up.

### Binary media download adoption

- Spec release consumed: `v0.2.0-pre.4`
- Changed profile: `media`
- Changed contract: `SPEC-020`
- Changed vectors: `download-content-basic`, `auth-required-content`,
  `auth-required-content-missing-token`, and `missing-media-content`
- Compatibility classification: additive pre-1.0 MVP media behavior.

Server adoption:

- Implementation repository: `imoyan/houra-server`
- Implementation issue: `imoyan/houra-server#7`
- Implementation pull request: `imoyan/houra-server#8`
- Implementation commit inspected: `37e6562f77cf1c6a8886a9838f0fe141c83c9486`
- Matrix reference: Matrix Specification 1.18 remains a reference snapshot
  only; this adoption is not Matrix full compliance.
- Started at: 2026-05-09T08:29:56+09:00
- Ended at: 2026-05-09T08:36:33+09:00
- Elapsed seconds: 397
- Codex usage: unavailable in the local Codex App session.

Server observed checks:

| Check | Result | Notes |
|---|---|---|
| `npm run typecheck` | pass | TypeScript strict check |
| `npm run build` | pass | Production server build |
| `npm test` | pass | 36 passed, 1 PostgreSQL test skipped by default |
| `HOURA_TEST_DATABASE_URL=... npm run test:postgres` | pass | Restart persistence includes media content download |
| Docker Compose live content smoke | pass | `media1/content` returned `aGVsbG8=` |
| GitHub Actions `CI / test` | pass | Ran on PR #8 head |

Client adoption:

- Implementation repository: `imoyan/houra-client`
- Implementation issue: `imoyan/houra-client#10`
- Implementation pull request: `imoyan/houra-client#11`
- Implementation commit inspected: `588965c239e4efb6c005ec326031255aca8ecb8e`
- Server target for live smoke: `houra-server`
  `37e6562f77cf1c6a8886a9838f0fe141c83c9486`
- Matrix reference: Matrix Specification 1.18 remains a reference snapshot
  only; this adoption is not Matrix full compliance.
- Started at: 2026-05-09T08:39:36+09:00
- Ended at: 2026-05-09T09:03:19+09:00
- Elapsed seconds: 1423
- Codex usage: unavailable in the local Codex App session.

Client observed checks:

| Check | Result | Notes |
|---|---|---|
| `npm run typecheck` | pass | Core and Expo app TypeScript checks |
| `npm run build` | pass | UI-free client core declaration build |
| `npm test` | pass | 42 passed, 1 live e2e skipped by default |
| `npx expo config --type public` | pass | Expo SDK 55 public config resolved |
| `npx expo export --platform ios --output-dir /tmp/houra-client-expo-export --clear` | pass | Metro bundle smoke for app entry and Expo UI imports |
| `HOURA_E2E_BASE_URL=http://localhost:3000 npm run test:e2e` | pass | Live happy path includes media content download |
| GitHub Actions `CI / test` | pass | Ran on PR #11 head |
| GitHub Actions `CI / e2e` | pass | Pinned `houra-spec` v0.2.0-pre.4 and `houra-server` PR #8 merge commit |

Profile status:

| Profile | Status | Notes |
|---|---|---|
| media | pass | Server and client both adopted same-origin binary media content download |

No implementation repository was used as a behavior source. The server remains
only the live HTTP target for connection smoke coverage; the expected public
behavior remains defined by this repository's contracts and vectors.

### Product MVP pre-release readiness after binary media download

- Release target: `v0.2.0-pre.5`
- Compatibility classification: workflow/adoption evidence update for
  `v0.2.0-pre.4` public behavior.
- Changed public behavior profiles: none in this release; `media` behavior
  changed in `v0.2.0-pre.4`.
- Changed contracts: none.
- Changed vectors: none.
- Implementation evidence added: binary media download adoption for
  `houra-server` and `houra-client`.
- Completion claim: Houra Product MVP subset includes binary media content
  download for the covered contract/vector scope. This is not a Matrix
  full-spec compliance claim.
- Remaining known gaps: production account registration, federation, encrypted
  media, range/resumable media download, thumbnails, simulator/manual UI QA, and
  the recorded Expo CLI / PostCSS audit follow-up.

### Account registration adoption

- Spec release consumed: `v0.2.0-pre.6`
- Changed profile: `auth`
- Changed contract: `SPEC-004`
- Changed vectors: `register-basic`, `register-duplicate-user`, and
  `register-invalid`
- Compatibility classification: additive pre-1.0 MVP auth behavior.

Server adoption:

- Implementation repository: `imoyan/houra-server`
- Implementation issue: `imoyan/houra-server#9`
- Implementation pull request: `imoyan/houra-server#10`
- Implementation commit inspected: `d3711878ca35758e9510463b9da6afcd42ada304`
- Matrix reference: Matrix Specification 1.18 remains a reference snapshot
  only; this adoption is not Matrix full compliance.
- Matrix source checked: 2026-05-09T11:00:00+09:00 from
  `https://spec.matrix.org/` and
  `https://matrix.org/blog/2026/03/26/matrix-v1.18-release/`.
- Started at: 2026-05-09T10:39:20+09:00
- Ended at: 2026-05-09T10:44:02+09:00
- Elapsed seconds: 282
- Codex usage: unavailable in the local Codex App session.

Server observed checks:

| Check | Result | Notes |
|---|---|---|
| `npm run typecheck` | pass | TypeScript strict check |
| `npm run build` | pass | Production server build |
| `npm test` | pass | 41 passed, 1 PostgreSQL test skipped by default |
| `npm run db:migrate` | pass | PostgreSQL schema applied before restart persistence tests |
| `HOURA_TEST_DATABASE_URL=... npm run test:postgres` | pass | Restart persistence covers registered user sessions and login |
| Docker Compose live registration smoke | pass | Registered a user and verified `whoami` with the returned bearer token |
| GitHub Actions `CI / test` | pass | Ran on PR #10 head |

Client adoption:

- Implementation repository: `imoyan/houra-client`
- Implementation issue: `imoyan/houra-client#12`
- Implementation pull request: `imoyan/houra-client#13`
- Implementation commit inspected: `0be1a22cf770c6fb8a192f391d25eee06966c54c`
- Server target for live smoke: `houra-server`
  `d3711878ca35758e9510463b9da6afcd42ada304`
- Matrix reference: Matrix Specification 1.18 remains a reference snapshot
  only; this adoption is not Matrix full compliance.
- Matrix source checked: 2026-05-09T11:00:00+09:00 from
  `https://spec.matrix.org/` and
  `https://matrix.org/blog/2026/03/26/matrix-v1.18-release/`.
- Started at: 2026-05-09T10:47:45+09:00
- Ended at: 2026-05-09T10:50:35+09:00
- Elapsed seconds: 170
- Codex usage: unavailable in the local Codex App session.

Client observed checks:

| Check | Result | Notes |
|---|---|---|
| `npm run typecheck` | pass | Core and Expo app TypeScript checks |
| `npm run build` | pass | UI-free client core declaration build |
| `npm test` | pass | 45 passed, 1 live e2e skipped by default |
| `npx expo config --type public` | pass | Expo SDK 55 public config resolved |
| `npx expo export --platform ios --output-dir /tmp/houra-client-expo-export --clear` | pass | Metro bundle smoke for app entry and Expo UI imports |
| `HOURA_E2E_BASE_URL=http://localhost:3000 npm run test:e2e` | pass | Live happy path includes register, whoami, logout, login, room, message, sync, media, and logout |
| GitHub Actions `CI / test` | pass | Pinned `houra-spec` v0.2.0-pre.6 |
| GitHub Actions `CI / e2e` | pass | Pinned `houra-spec` v0.2.0-pre.6 and `houra-server` PR #10 merge commit |

Profile status:

| Profile | Status | Notes |
|---|---|---|
| auth | pass | Server and client both adopted password account registration |

No implementation repository was used as a behavior source. The server remains
only the live HTTP target for connection smoke coverage; the expected public
behavior remains defined by this repository's contracts and vectors.

### Product MVP pre-release readiness after account registration

- Release target: `v0.2.0-pre.7`
- Compatibility classification: workflow/adoption evidence update for
  `v0.2.0-pre.6` public behavior.
- Changed public behavior profiles: none in this release; `auth` behavior
  changed in `v0.2.0-pre.6`.
- Changed contracts: none.
- Changed vectors: none.
- Implementation evidence added: account registration adoption for
  `houra-server` and `houra-client`.
- Completion claim: Houra Product MVP subset includes password account
  registration for the covered contract/vector scope. This is not a Matrix
  full-spec compliance claim.
- Remaining known gaps outside current MVP: federation, encrypted media,
  range/resumable media download, thumbnails, email verification, password
  reset, IdP integration, simulator/manual UI QA, and the recorded Expo CLI /
  PostCSS audit follow-up.

### Product MVP UI surface contract

- Spec issue: `imoyan/houra-spec#65`
- Changed design inputs: `design/ui.surface.schema.json` and
  `design/ui-surfaces/product-mvp.json`
- Compatibility classification: additive pre-1.0 Product MVP UI surface
  definition.
- Changed public API contracts: none.
- Changed vectors: none.
- Server behavior impact: none.
- Implementation follow-up: client implementations should map their native UI
  affordances to the `product-mvp` screen, action, state, text key, and
  acceptance-flow ids without deriving behavior from another implementation.

The UI surface contract is platform-neutral. It is intentionally not a React,
Expo, Flutter, SwiftUI, Android, or Web component contract. It exists so each
client implementation can prove that it exposes the same Product MVP operation
surface while keeping framework-specific layout, navigation, local session
storage, accessibility affordances, and component structure implementation-owned.

### Product MVP pre-release readiness after UI surface contract

- Release target: `v0.2.0-pre.8`
- Compatibility classification: additive UI surface contract.
- Changed public behavior profiles: none; this release adds platform-neutral UI
  surface conformance input.
- Changed contracts: none.
- Changed vectors: none.
- Changed design inputs: `design/ui.surface.schema.json` and
  `design/ui-surfaces/product-mvp.json`.
- Required implementation follow-up: `houra-client` should record Expo MVP UI
  coverage against `product-mvp` and keep Expo-specific acceptance steps
  separate from the generic UI surface.
- Completion claim: Houra Product MVP now has a reusable UI surface definition
  for client implementations. This is not a Matrix full-spec compliance claim.

### Product MVP UI surface adoption

- Spec release consumed: `v0.2.0-pre.8`
- Changed design input consumed: `design/ui-surfaces/product-mvp.json`
- Compatibility classification: workflow/adoption evidence update for the
  `v0.2.0-pre.8` UI surface contract.
- Server behavior impact: none.

Client adoption:

- Implementation repository: `imoyan/houra-client`
- Implementation issue: `imoyan/houra-client#16`
- Implementation pull request: `imoyan/houra-client#17`
- Implementation commit inspected: `1d7d0e0c74223d9b9fd6b87e80c40428f79c7307`
- Matrix reference: Matrix Specification 1.18 remains a reference snapshot
  only; this adoption is not Matrix full compliance.
- Started at: 2026-05-09T11:26:08+09:00
- Ended at: 2026-05-09T11:30:59+09:00
- Elapsed seconds: 291
- Codex usage: unavailable in the local Codex App session.

Client observed checks:

| Check | Result | Notes |
|---|---|---|
| `npm run typecheck` | pass | Core and Expo app TypeScript checks |
| `npm run build` | pass | UI-free client core declaration build |
| `npm test` | pass | 49 passed, 1 live e2e skipped by default; includes Product MVP UI surface conformance |
| `npx expo config --type public` | pass | Expo SDK 55 public config resolved |
| `npx expo export --platform ios --output-dir /tmp/houra-client-expo-export --clear` | pass | Metro bundle smoke for app entry and Expo UI imports |
| GitHub Actions `CI / test` | pass | Pinned `houra-spec` v0.2.0-pre.8 |
| GitHub Actions `CI / e2e` | pass | Pinned `houra-spec` v0.2.0-pre.8 and `houra-server` PR #10 merge commit |

UI surface status:

| Surface | Status | Notes |
|---|---|---|
| `product-mvp` | pass | Expo UI metadata covers canonical screen, action, text key, and acceptance-flow ids |

No implementation repository was used as a behavior source. The Expo app is the
React Native adapter for the platform-neutral `product-mvp` surface; expected UI
surface semantics remain defined by `design/ui-surfaces/product-mvp.json`.

### Product MVP pre-release readiness after UI surface adoption

- Release target: `v0.2.0-pre.9`
- Compatibility classification: workflow/adoption evidence update for
  `v0.2.0-pre.8` UI surface behavior.
- Changed public behavior profiles: none.
- Changed contracts: none.
- Changed vectors: none.
- Changed design inputs: none in this release; `product-mvp` UI surface changed
  in `v0.2.0-pre.8`.
- Implementation evidence added: Product MVP UI surface adoption for
  `houra-client`.
- Completion claim: Houra Product MVP has a reusable UI surface definition and
  one React Native Expo adapter adoption record. This is not a Matrix full-spec
  compliance claim.

### Product MVP manual UI acceptance

- Spec release consumed: `v0.2.0-pre.9`
- Compatibility classification: workflow/adoption evidence update for the
  Houra Product MVP subset.
- Server behavior impact: none.
- Client behavior impact: none.

Client manual acceptance:

- Implementation repository: `imoyan/houra-client`
- Implementation issue: `imoyan/houra-client#18`
- Implementation pull request: `imoyan/houra-client#19`
- Implementation merge commit inspected:
  `b00d3ec8222bf0e877a496cc73190f34b27f9399`
- Server target: `imoyan/houra-server`
  `f12e1758b952a8d4a251448cfd1fb4b97b2bf874`
- Matrix reference: Matrix Specification 1.18 remains a reference snapshot
  only; this acceptance is not Matrix full compliance.
- Started at: 2026-05-09T11:51:34+09:00
- Ended at: 2026-05-09T12:08:17+09:00
- Elapsed seconds: 1003
- Codex usage: unavailable in the local Codex App session.

Manual UI acceptance covered the `product-mvp-happy-path` flow against a
PostgreSQL-backed Docker Compose server using Expo Go on an iPhone 17 Pro iOS
26.4 simulator. The operator created `@manual18:example.test`, created and
listed the `General` room, selected the room timeline, sent `manual message`,
uploaded and downloaded `note.txt` as `text/plain / 5 bytes`, logged out,
logged back in with the same account, and confirmed the room timeline still
showed `manual message`.

Client observed checks:

| Check | Result | Notes |
|---|---|---|
| `curl -fsS http://127.0.0.1:3000/_houra/client/versions` | pass | Docker Compose server discovery response included `media` |
| local live `npm run test:e2e` | pass | `HOURA_E2E_BASE_URL=http://127.0.0.1:3000` against the Docker Compose server |
| XcodeBuildMCP simulator UI inspection/screenshots | pass | Manual Product MVP UI flow completed on iPhone 17 Pro iOS 26.4 |
| `npm run typecheck` | pass | Core and Expo app TypeScript checks |
| `npm run build` | pass | UI-free client core declaration build |
| `npm test` | pass | 49 passed, 1 live e2e skipped by default |
| `git diff --check` | pass | README adoption evidence patch |
| GitHub Actions `CI / test` | pass | `houra-client` PR #19 |
| GitHub Actions `CI / e2e` | pass | `houra-client` PR #19 |

No implementation repository was used as a behavior source. This record only
confirms that one Expo React Native adapter can operate the canonical Product
MVP UI surface against the live Docker Compose server baseline.

### Product MVP pre-release readiness after manual UI acceptance

- Release target: `v0.2.0-pre.10`
- Compatibility classification: workflow/adoption evidence update for the
  Product MVP acceptance flow.
- Changed public behavior profiles: none.
- Changed contracts: none.
- Changed vectors: none.
- Changed design inputs: none.
- Implementation evidence added: manual Product MVP UI acceptance for
  `houra-client` against the Docker Compose `houra-server` baseline.
- Completion claim: Houra Product MVP is complete for the defined subset when
  reproduced from fresh sibling checkouts with Docker Compose server startup,
  Expo client startup, live HTTP smoke, and the documented manual UI
  happy-path. This is not a Matrix full-spec compliance claim.
- Remaining explicit limitations: federation, encrypted media, range/resumable
  media download, thumbnails, email verification, password reset, identity
  provider login, cloud deployment, and Matrix full-spec coverage remain outside
  this Product MVP subset.

### Product MVP maintenance adoption after operations readiness

- Spec release consumed: `v0.2.0-pre.10`
- Compatibility classification: workflow/adoption evidence update for the
  Houra Product MVP subset.
- Public behavior impact: none.
- Changed contracts: none.
- Changed vectors: none.
- Changed design inputs: none.
- Matrix reference: Matrix Specification 1.18 remains a reference snapshot
  only; this maintenance adoption is not Matrix full compliance.
- Started at: 2026-05-09T14:00:06+09:00
- Ended at: 2026-05-09T14:00:50+09:00
- Elapsed seconds: 44
- Timezone: Asia/Tokyo
- Codex usage: unavailable in the local Codex App session.

Server maintenance evidence:

- Implementation repository: `imoyan/houra-server`
- Implementation issue: `imoyan/houra-server#15`
- Implementation pull request: `imoyan/houra-server#16`
- Implementation merge commit inspected:
  `bfef401e262aac0ccb99f7af5c945adf7ecd3b64`
- Implementation release: `v0.2.0-pre.11`
- Release URL:
  `https://github.com/imoyan/houra-server/releases/tag/v0.2.0-pre.11`

Client maintenance evidence:

- Implementation repository: `imoyan/houra-client`
- Implementation issue: `imoyan/houra-client#25`
- Implementation pull request: `imoyan/houra-client#26`
- Implementation merge commit inspected:
  `55b116d0506f14069a6277c17e1fad1b31d6dee5`
- Implementation release: `v0.2.0-pre.12`
- Release URL:
  `https://github.com/imoyan/houra-client/releases/tag/v0.2.0-pre.12`
- Server target for live e2e smoke: `houra-server` v0.2.0-pre.11

Observed checks:

| Check | Result | Notes |
|---|---|---|
| `houra-server` GitHub Actions `CI / test` | pass | PR #16, operations-readiness release |
| `houra-client` GitHub Actions `CI / test` | pass | PR #26, e2e target update |
| `houra-client` GitHub Actions `CI / e2e` | pass | PR #26, pinned `houra-server` v0.2.0-pre.11 |

No implementation repository was used as a behavior source. This record only
confirms that the Product MVP implementation releases are aligned after the
server operations-readiness update and client live e2e target update.

### Product MVP pre-release readiness after maintenance adoption

- Release target: `v0.2.0-pre.11`
- Compatibility classification: workflow/adoption evidence update for the
  Product MVP maintenance release.
- Changed public behavior profiles: none.
- Changed contracts: none.
- Changed vectors: none.
- Changed design inputs: none.
- Implementation evidence added: `houra-server` v0.2.0-pre.11 operations
  readiness and `houra-client` v0.2.0-pre.12 live e2e target adoption.
- Completion claim: Houra Product MVP remains complete for the defined subset;
  this release updates adoption evidence only and is not a Matrix full-spec
  compliance claim.

### Product MVP release alignment adoption

- Spec release consumed: `v0.2.0-pre.11`
- Compatibility classification: workflow/adoption evidence update for the
  Houra Product MVP subset.
- Public behavior impact: none.
- Changed contracts: none.
- Changed vectors: none.
- Changed design inputs: none.
- Matrix reference: Matrix Specification 1.18 remains a reference snapshot
  only; this release alignment record is not Matrix full compliance.
- Started at: 2026-05-09T14:18:31+09:00
- Ended at: 2026-05-09T14:19:26+09:00
- Elapsed seconds: 55
- Timezone: Asia/Tokyo
- Codex usage: unavailable in the local Codex App session.

Server alignment evidence:

- Implementation repository: `imoyan/houra-server`
- Implementation issue: `imoyan/houra-server#17`
- Implementation pull request: `imoyan/houra-server#18`
- Implementation merge commit inspected:
  `40d9d29cb845dee774219e329a1294fdfb275b39`
- Implementation release: `v0.2.0-pre.12`
- Release URL:
  `https://github.com/imoyan/houra-server/releases/tag/v0.2.0-pre.12`
- Spec input adopted by implementation CI: `houra-spec` v0.2.0-pre.11

Client alignment evidence:

- Implementation repository: `imoyan/houra-client`
- Implementation issue: `imoyan/houra-client#27`
- Implementation pull request: `imoyan/houra-client#28`
- Implementation merge commit inspected:
  `f64002bcfd3ef0388f70f9dab144dd934764e204`
- Implementation release: `v0.2.0-pre.13`
- Release URL:
  `https://github.com/imoyan/houra-client/releases/tag/v0.2.0-pre.13`
- Spec input adopted by implementation CI: `houra-spec` v0.2.0-pre.11
- Server target for live e2e smoke: `houra-server` v0.2.0-pre.12

Observed checks:

| Check | Result | Notes |
|---|---|---|
| `houra-server` GitHub Actions `CI / test` | pass | PR #18, pinned `houra-spec` v0.2.0-pre.11 |
| `houra-client` GitHub Actions `CI / test` | pass | PR #28, pinned `houra-spec` v0.2.0-pre.11 |
| `houra-client` GitHub Actions `CI / e2e` | pass | PR #28, pinned `houra-server` v0.2.0-pre.12 |

No implementation repository was used as a behavior source. This record only
confirms that the Product MVP implementation CI inputs are aligned to the
current spec maintenance release and server live e2e release.

### Product MVP pre-release readiness after release alignment

- Release target: `v0.2.0-pre.12`
- Compatibility classification: workflow/adoption evidence update for the
  Product MVP release-alignment maintenance release.
- Changed public behavior profiles: none.
- Changed contracts: none.
- Changed vectors: none.
- Changed design inputs: none.
- Implementation evidence added: `houra-server` v0.2.0-pre.12 and
  `houra-client` v0.2.0-pre.13 release alignment with `houra-spec`
  v0.2.0-pre.11.
- Completion claim: Houra Product MVP remains complete for the defined subset;
  this release updates adoption evidence only and is not a Matrix full-spec
  compliance claim.

### Product MVP deployment hardening adoption

- Spec release consumed: `v0.2.0-pre.12`
- Compatibility classification: workflow/adoption evidence update for the
  Houra Product MVP subset.
- Public behavior impact: none.
- Changed contracts: none.
- Changed vectors: none.
- Changed design inputs: none.
- Matrix reference: Matrix Specification 1.18 remains a reference snapshot
  only; this deployment hardening record is not Matrix full compliance.
- Started at: 2026-05-09T14:40:11+09:00
- Ended at: 2026-05-09T14:41:10+09:00
- Elapsed seconds: 59
- Timezone: Asia/Tokyo
- Codex usage: unavailable in the local Codex App session.

Server deployment hardening evidence:

- Implementation repository: `imoyan/houra-server`
- Implementation issue: `imoyan/houra-server#19`
- Implementation pull request: `imoyan/houra-server#20`
- Implementation merge commit inspected:
  `0b7fd3c0a9776c718b36a84d1621ea2b2cf02252`
- Implementation release: `v0.2.0-pre.13`
- Release URL:
  `https://github.com/imoyan/houra-server/releases/tag/v0.2.0-pre.13`
- Scope: automated Docker Compose operations smoke, backup/restore validation,
  restart persistence validation, and production runtime configuration guard.

Client live e2e adoption evidence:

- Implementation repository: `imoyan/houra-client`
- Implementation issue: `imoyan/houra-client#29`
- Implementation pull request: `imoyan/houra-client#30`
- Implementation merge commit inspected:
  `32c0bea8339b2a92bfd9e7f24ed3afc7cb3e892e`
- Implementation release: `v0.2.0-pre.14`
- Release URL:
  `https://github.com/imoyan/houra-client/releases/tag/v0.2.0-pre.14`
- Server target for live e2e smoke: `houra-server` v0.2.0-pre.13

Observed checks:

| Check | Result | Notes |
|---|---|---|
| `houra-server` GitHub Actions `CI / test` | pass | PR #20, includes `npm run test:ops` |
| `houra-client` GitHub Actions `CI / test` | pass | PR #30, e2e target update |
| `houra-client` GitHub Actions `CI / e2e` | pass | PR #30, pinned `houra-server` v0.2.0-pre.13 |

No implementation repository was used as a behavior source. This record only
confirms that the Product MVP deployment hardening release is adopted by the
server and covered by the client live e2e smoke target.

### Product MVP pre-release readiness after deployment hardening

- Release target: `v0.2.0-pre.13`
- Compatibility classification: workflow/adoption evidence update for the
  Product MVP deployment-hardening maintenance release.
- Changed public behavior profiles: none.
- Changed contracts: none.
- Changed vectors: none.
- Changed design inputs: none.
- Implementation evidence added: `houra-server` v0.2.0-pre.13 deployment
  hardening and `houra-client` v0.2.0-pre.14 live e2e target adoption.
- Completion claim: Houra Product MVP remains complete for the defined subset;
  this release updates adoption evidence only and is not a Matrix full-spec
  compliance claim.

### Product MVP client UI robustness adoption

- Spec release consumed: `v0.2.0-pre.13`
- Compatibility classification: workflow/adoption evidence update for the
  Houra Product MVP subset.
- Public behavior impact: none.
- Changed contracts: none.
- Changed vectors: none.
- Changed design inputs: none.
- Matrix reference: Matrix Specification 1.18 remains a reference snapshot
  only; this UI robustness record is not Matrix full compliance.
- Started at: 2026-05-09T15:05:16+09:00
- Ended at: 2026-05-09T15:06:12+09:00
- Elapsed seconds: 56
- Timezone: Asia/Tokyo
- Codex usage: unavailable in the local Codex App session.

Client UI robustness evidence:

- Implementation repository: `imoyan/houra-client`
- Implementation issue: `imoyan/houra-client#31`
- Implementation pull request: `imoyan/houra-client#32`
- Implementation merge commit inspected:
  `86921a358b74e9de31d80d5a95b7030e0a0f6fc8`
- Implementation release: `v0.2.0-pre.15`
- Release URL:
  `https://github.com/imoyan/houra-client/releases/tag/v0.2.0-pre.15`
- Server target for live e2e smoke: `houra-server` v0.2.0-pre.13
- Scope: Expo MVP single-flight action guard, stored session restore
  validation, pending input disabling, stale media result clearing, README
  implementation record.

Observed checks:

| Check | Result | Notes |
|---|---|---|
| `houra-client` local `npm audit --omit=dev` | pass | 0 vulnerabilities |
| `houra-client` local `npm run typecheck` | pass | Core and Expo app typecheck |
| `houra-client` local `npm run build` | pass | TypeScript build |
| `houra-client` local `npm test` | pass | 51 passed, 1 live e2e skipped by default |
| `houra-client` local `HOURA_SPEC_ROOT=../houra-spec npm test` | pass | 51 passed, 1 live e2e skipped by default against sibling `houra-spec` v0.2.0-pre.13 |
| `houra-client` local Expo config/export | pass | `npx expo config --type public` and iOS export to `/tmp/houra-client-expo-export` |
| `houra-client` local live e2e | pass | Docker Compose `houra-server` v0.2.0-pre.13 at `http://127.0.0.1:3000` |
| `houra-client` GitHub Actions `CI / test` | pass | PR #32, UI robustness update |
| `houra-client` GitHub Actions `CI / e2e` | pass | PR #32, pinned `houra-server` v0.2.0-pre.13 |

No implementation repository was used as a behavior source. This record only
confirms that the Product MVP UI implementation is more robust while preserving
the existing public contract, vectors, and platform-neutral UI surface.

### Product MVP pre-release readiness after client UI robustness

- Release target: `v0.2.0-pre.14`
- Compatibility classification: workflow/adoption evidence update for the
  Product MVP client UI robustness maintenance release.
- Changed public behavior profiles: none.
- Changed contracts: none.
- Changed vectors: none.
- Changed design inputs: none.
- Implementation evidence added: `houra-client` v0.2.0-pre.15 Expo MVP UI
  robustness adoption.
- Completion claim: Houra Product MVP remains complete for the defined subset;
  this release updates adoption evidence only and is not a Matrix full-spec
  compliance claim.
