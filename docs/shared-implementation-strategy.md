# Shared Implementation Strategy

This supporting document was split from the README so the repository entrypoint
stays focused on orientation and current release state. Canonical behavior
remains in contracts, test vectors, design inputs, and UI surfaces.

This section is non-normative implementation guidance for readers evaluating
Houra's long-term multi-language direction. It does not define a public Houra
contract, Matrix compliance claim, test vector, design token, or UI surface.

Houra is expected to support multiple implementation ecosystems over time:
TypeScript clients and servers, Dart and Flutter clients, and later native
Swift, Kotlin, or other adapters. The project should avoid making any one
implementation repository canonical. Public behavior remains fixed here, in
`contracts/SPEC-*.md`, `test-vectors/`, and shared design inputs. Shared
implementation artifacts are allowed only as consumers of those inputs.

Houra's production default is TypeScript for both `houra-client` and
`houra-server`. Rust, WASM, N-API, Dart FFI, and other shared-core experiments
belong in `houra-labs` as benchmark and future-commonization candidates, not as
the default implementation path. Each protocol area may stay implementation-owned
in TypeScript, move into a shared artifact later, or split by language when that
is more practical for performance, packaging, or ecosystem fit.

The goal is to share the protocol logic that most often drifts between client
and server implementations: request and response parsing, validation,
identifier grammar, URI grammar, event content shape, transaction and
idempotency semantics, canonical JSON, signing inputs, and reusable vector
assertions. Sharing those areas can reduce mismatches between a TypeScript
client, a TypeScript server, a Dart client, and later native clients.

The goal is not to centralize application policy. Transport, database storage,
secure storage, auth token persistence, retry scheduling, logging, UI state,
framework lifecycle, packaging, and deployment policy remain adapter-owned
unless a later `SPEC-*` contract defines public behavior. Those parts differ
too much across Vue, Next, Node.js, Expo, Flutter native, Flutter web, and
server runtimes to force into a single core without harming flexibility.

### Shared boundary and risk rule

Shared implementation should start at dangerous or drift-prone protocol
boundaries, not at broad application architecture. The preferred shape is:

1. parse the external payload;
2. normalize only contract-visible values;
3. validate identifiers, payload shape, limits, and feature gates;
4. authorize against adapter-provided context; and
5. execute through host-owned transport, storage, crypto, UI, and lifecycle
   code.

After this boundary, downstream code should receive a structured result and
should not re-parse or re-validate the same payload unless the contract requires
a separate phase. Validators and parsers should be compiled or initialized once
where possible, batch representative vector payloads across FFI, WASM, or
N-API boundaries, and avoid hidden network, disk, storage, logging, or crypto
work inside the pure shared path. Caches must have explicit size, lifetime, and
invalidation policy owned by the adapter.

Security-sensitive handling should be shared only when it reduces ambiguity at
the public protocol boundary. Good candidates include identifier grammar,
content URI grammar, error-envelope mapping, protocol payload validation,
redaction of diagnostic fields, and fail-closed capability or version
advertisement. Token persistence, secure key storage, transport retry,
permission prompts, UI trust state, and deployment policy remain host-owned
unless a public Houra contract says otherwise.

If compatibility, security, or performance evidence is incomplete, the shared
boundary must fail closed: do not advertise support, do not widen feature
profiles, and do not turn a local implementation into a required shared
dependency. Record the area as `spec-only`, `adapter-owned`,
`split-by-language`, or `avoid-shared` until parity, security, packaging, and
performance evidence supports a wider adoption.

Existing implementations should not be migrated into shared code as a broad
cleanup by default. Use a next-touch rule for narrow maintenance: when a change
already modifies protocol parsing, normalization, validation, authorization, or
advertisement behavior, decide whether the touched boundary can move into the
shared path without widening the issue. If the migration would change the
feature scope, hot-path cost, packaging model, or security boundary, leave the
local implementation in place and create a planned adoption gate instead.

日本語メモ: 共通化は「危険な境界を一度だけ通す」ために使います。入力の
parse / normalize / validate / authorize は共通化候補ですが、token 保管、
secure storage、transport、retry、UI state、deployment policy は実装側の責務に
残します。証拠が揃わない機能は advertise せず fail-closed にします。既存実装は
一括移行せず、触った箇所で小さく判断し、大きい移行は adoption gate として分けます。

### Current shared-core status

The current shared-core work is still pre-adoption. `houra-client` and
`houra-server` remain TypeScript implementations. `houra-labs` contains the Rust
protocol-core prototype, a `wasm-bindgen` wrapper prototype, and a TypeScript
WASM facade prototype for parser, validation, compatibility, and benchmark
experiments. Those artifacts are implementation experiments, not public
contracts, published packages, or required dependencies for `houra-client` or
`houra-server`.

The next shared-core sequence is:

1. Keep `houra-spec` contracts and vectors as the source of truth.
2. Keep production client and server work on the TypeScript path unless a
   focused adoption issue says otherwise.
3. Use `SPEC-114` evidence bundles to collect parity, packaging, binary-size,
   startup, p95 benchmark, redaction, facade-stability, and rollback evidence
   for representative vector batches.
4. Keep Rust/WASM/N-API/Dart FFI artifacts private or unpublished until a
   focused release decision exists.
5. Adopt a shared artifact from implementation repositories only after the
   relevant area reaches `shared-adopted` status with the required evidence.

Until those steps are complete, implementation repositories should keep local
parser or validator code unless a focused adoption issue explicitly wires the
shared artifact into that repository.

日本語メモ: Houra の production 方針は `houra-client` / `houra-server` の
TypeScript 実装を正道にします。`houra-labs` の Rust/WASM/N-API/Dart FFI は
benchmark と将来の共通化候補であり、parity / performance evidence、package 方針、
rollback 方針、実装 repo への明示 adoption issue が揃うまでは required dependency
として扱いません。

### Coupling and dependency policy

Shared code should be deliberately small, but it should not avoid mainstream
dependencies just to look dependency-free. Well-established libraries that are
central to protocol correctness may be direct dependencies of the pure core.
Dependencies that are heavy, platform-shaped, frequently replaced, or close to
host-application policy should live outside the core.

Dependency policy values:

- `core-hard-dep`: a mainstream, low-risk dependency that is directly useful for
  protocol correctness and acceptable in the pure Rust core.
- `extension-dep`: a heavy or optional dependency, such as crypto, that may be
  shared but should live in an extension crate or optional package.
- `binding-dep`: a dependency needed only to expose Rust to an ecosystem, such
  as `wasm-bindgen`, N-API, or Dart FFI glue.
- `adapter-owned`: an implementation or host-application dependency, such as
  HTTP clients, secure storage, UI frameworks, retry schedulers, or logging.
- `avoid-shared`: a dependency or behavior that should not be shared because it
  would make the common path slower, brittle, or unnatural for one ecosystem.

The shared core should expose coarse-grained APIs so bindings do not pay a large
FFI, WASM, or N-API call cost for every small field. A parser or validator
should accept one protocol payload and return one structured result, rather
than requiring many cross-boundary calls. Public TypeScript and Dart facades
should remain stable even if the Rust implementation changes internally. Rust
ABI compatibility should be tracked with an `abi_version` and artifact manifest
before any implementation repository treats a shared artifact as adopted.

### TypeScript and Dart backend strategy

The production TypeScript path is native TypeScript unless a focused shared-core
adoption issue proves that a lab artifact is smaller, faster enough, or safer
enough to justify the extra runtime boundary. If a shared artifact is adopted
later, the TypeScript and Dart ecosystems need different bindings for different
runtimes:

- TypeScript browser, Vue, and Next client code may use WebAssembly built from a
  lab shared core only after artifact, bundler, startup, and p95 evidence exists.
- TypeScript Node.js and Next server code may use N-API bindings only after
  native packaging, prebuild, fallback, and p95 evidence beats or matches local
  TypeScript for the target boundary.
- TypeScript edge or restricted serverless runtimes should keep local
  TypeScript unless a WebAssembly fallback has explicit startup and binary-size
  evidence.
- Dart CLI, Dart server, and Flutter native code should use a C ABI exposed to
  `dart:ffi` only for adopted shared artifacts.
- Dart web and Flutter web should call a WebAssembly JavaScript wrapper through
  `dart:js_interop` only for adopted shared artifacts; they should not depend on
  `dart:ffi`.

This split follows the current Dart direction where `dart:js_interop` is the
web interop layer and `package:web` is the long-term web API package designed
with Wasm compatibility in mind. The Dart native path and Dart web path should
therefore share the same Dart facade API while using different backends through
conditional imports.

### Build and distribution policy

Rust compile time should not become a tax on every application developer. If a
shared Rust artifact is adopted later, implementation packages should publish
prebuilt artifacts for supported platforms wherever practical:

- npm packages can include WebAssembly artifacts for browsers and N-API
  binaries for Node.js platforms.
- Dart packages can include or download native libraries for supported Flutter
  and Dart native platforms, while using the WebAssembly JavaScript wrapper on
  web.
- CI should rebuild Rust artifacts when the shared core, extension crates, or
  binding crates change, not when an application changes only adapter policy,
  UI, transport, or storage.

Feature flags are useful for stable build variants, but frequently changed
policy should not become a Cargo feature. Changing Cargo features usually means
rebuilding the Rust artifact. Runtime policy and ecosystem-specific behavior
should stay in the TypeScript or Dart facade when that keeps application
iteration faster.

### Performance rule

Sharing is optional. Local TypeScript is the production baseline for the current
Houra client and server. An area should not be moved into shared code if the
cross-language boundary, binary size, startup cost, or packaging cost makes the
result meaningfully worse than a local implementation. The default performance
gate is that shared protocol logic should stay within roughly a p95 `+10%` cost
of the adapter-native implementation for representative vector batches, or be
clearly hidden by network, disk, or UI latency. If that gate fails, record the
area as `adapter-owned`, `language-family`, or `avoid-shared` instead of forcing
common code.

Reference documents for the current binding direction:

- Dart JavaScript interop:
  <https://dart.dev/interop/js-interop>
- Dart `package:web` migration and Wasm-compatible web interop direction:
  <https://dart.dev/interop/js-interop/package-web>
- Dart C interop with `dart:ffi`:
  <https://dart.dev/interop/c-interop>
- Rust/WebAssembly bindings:
  <https://rustwasm.github.io/docs/wasm-bindgen/>
- Rust Node.js bindings:
  <https://napi.rs/>

External reference snapshot:

- Checked at: 2026-05-12T09:00:00+09:00
- Timezone: Asia/Tokyo
- Documentation lookup: Context7
- Dart reference: official Dart docs describe `dart:js_interop` and
  `package:web` as the current web interop direction, including Wasm-compatible
  browser API access, while `dart:ffi` remains the native C interop path.
- Rust/WebAssembly reference: `wasm-bindgen` is the current Rust-focused bridge
  for rich interaction between WebAssembly modules and JavaScript, including
  generated JavaScript and TypeScript binding support.
- Rust/Node reference: NAPI-RS targets Rust-built Node.js native add-ons and
  supports cross-platform prebuilt package distribution to avoid making every
  Node consumer compile Rust locally.

This snapshot is planning evidence for the non-normative shared implementation
strategy. It does not create a public Houra contract, require Rust adoption, or
replace per-implementation verification.

Implementation sharing statuses:

- `spec-only`: only the specification inputs are shared; implementation stays
  per repository or per language.
- `lab-candidate`: suitable for a lab shared-core experiment, but not a required
  dependency until parity, packaging, rollback, and performance evidence exists.
- `shared-adopted`: a shared artifact has passed parity and performance gates
  for the area and may be used by adapters through a focused adoption issue.
- `adapter-owned`: framework, runtime, or host-application behavior should stay
  in the adapter or application layer.
- `split-by-language`: many languages can share one implementation, but one or
  more languages may reasonably keep a separate implementation.

Implementation reach values:

- `client+server`: the same pure protocol logic can be consumed by client and
  server implementations.
- `client-only`: the logic is reusable across clients but not expected to run
  in servers.
- `server-only`: the logic is reusable across servers but not expected to run
  in clients.
- `adapter-only`: the behavior belongs to framework, runtime, or host
  application adapters.
- `language-family`: the behavior may be shared inside one language ecosystem
  while other languages keep separate implementations.

### Implementation Sharing Matrix

This matrix tracks sharing intent and evidence. It is a planning and adoption
record, not a conformance checklist. Rows should explicitly identify whether an
area is shared across clients, servers, both sides, or only inside adapters so
client/server commonality is not lost during planning.

| Area | Current sharing status | Implementation reach | Dependency policy | TS backend | Dart backend | Shared candidate | Adapter-owned responsibilities | Split trigger | Rebuild impact | Prebuilt artifact | Performance gate |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Matrix versions request/response handling | `lab-candidate` | `client+server` | `core-hard-dep` allowed for JSON parsing only inside the lab artifact | Local TypeScript by default; WASM/N-API only after adoption evidence | `dart:ffi` or `dart:js_interop` only after adoption evidence | Lab parser and validator for `SPEC-030` request and response shape | Fetching `/_matrix/client/versions`, cache policy, and feature gating | A runtime cannot consume the shared artifact without larger packaging cost than local parsing | Low after prebuilt artifacts; changing facade policy should not rebuild core | Optional npm WASM, npm N-API, Dart native library, or Dart web WASM wrapper | Server emission and client parsing pass against `test-vectors/core/matrix-client-versions-basic.json`; p95 within `+10%` of local TypeScript parsing |
| Matrix / Houra error parsing and emission | `lab-candidate` | `client+server` | `core-hard-dep` allowed for stable JSON and enum helpers only inside the lab artifact | Local TypeScript by default; WASM/N-API only after adoption evidence | Dart facade dispatches to FFI or JS interop backend only after adoption evidence | Shared error envelope and Matrix `M_*` vocabulary parser / builder | HTTP status handling, retry policy, telemetry, and user-facing messages | Platform error models require native exception or result types outside the shared ABI | Low; adding host-specific error text stays outside the lab artifact | Optional protocol-core artifacts | Vectors cover client parsing and server emission without adapter-specific fields; no measurable UI-path regression |
| Identifier and URI validation | `lab-candidate` | `client+server` | `core-hard-dep` allowed for regex or parser utilities if they are mainstream and portable | Local TypeScript by default; WASM/N-API only after adoption evidence | FFI on native and JS interop on web only after adoption evidence | Matrix and Houra identifier, room ID, event ID, user ID, content URI, and namespace validators | Input timing, UI validation display, and normalization before storage | A platform requires native text or URL APIs for correctness, accessibility, or locale behavior | Medium if parser dependencies change; stable grammar updates should be batched | Optional prebuilt parser artifacts per supported runtime | Positive and negative grammar vectors pass in client and server harnesses; boundary overhead is hidden by validation batch size |
| Event content and message schema validation | `lab-candidate` | `client+server` | `core-hard-dep` allowed for JSON schema-like validation only when it stays protocol-focused | Local TypeScript by default; TS may keep permissive draft typing | FFI / JS interop for canonical validation only after adoption evidence; Dart may keep permissive draft models | Shared event type, message content, state key, and redaction shape validators | Rich composer UX, server persistence, timeline indexing, moderation policy, and draft states | A client needs permissive draft validation while servers require stricter acceptance rules | Medium; schema changes rebuild shared validators but not UI composer policy | Optional protocol validator artifacts plus native/web facade packages | Client compose fixtures and server acceptance/rejection vectors agree on canonical shapes; validation batch p95 stays within `+10%` |
| Transaction ID and idempotency semantics | `lab-candidate` | `client+server` | `core-hard-dep` only for small deterministic helpers | Local TypeScript by default; WASM/N-API helper only after adoption evidence | FFI / JS interop helper only after adoption evidence | Transaction ID grammar, idempotency-key comparison, and replay classification helpers | Retry scheduling, persistence of sent-message state, offline queueing, and conflict UI | Offline clients need language-native queue behavior that cannot share the same runtime | Low; queue policy changes should not rebuild the lab artifact | Optional small helper artifact bundled with protocol core | Retry and conflict vectors pass with identical transaction classification; local queue performance is not gated on shared-core calls |
| Canonical JSON / signing helpers | `lab-candidate` | `client+server` | `core-hard-dep` for canonicalization and hash primitives; `extension-dep` for heavier signing stacks | Local TypeScript by default; WASM/N-API only when canonicalization evidence justifies it | FFI for native signing helpers; JS interop/WASM for web canonicalization only after adoption evidence | Canonical JSON, hash, and signing input helper primitives | Key storage, key rotation policy, secure enclave integration, and request transport | Native crypto policy or platform keychain constraints require separate bindings | Medium to high when crypto dependencies change; isolate heavy crypto outside the pure core | Optional separate core and crypto extension artifacts | Cross-language canonicalization fixtures produce byte-identical output; crypto extension has its own p95 and binary-size gate |
| Room version auth/state resolution | `lab-candidate` | `server-only` | `extension-dep` unless the algorithm is small enough for pure core | Local TypeScript by default; N-API only when server-side evidence justifies it | Usually not used by Dart clients; Dart server may use FFI if adopted | Room-version-aware auth events, state resolution, and event validation helpers | Persistent event store layout, indexing, sync pagination, conflict recovery UI, and federation policy | Performance, database coupling, or federation deployment needs a server-native path | High; keep database and storage policy outside the lab artifact | Optional server-side native artifact only until a client/tooling use case exists | Room-version fixtures and restart-safe server integration tests pass; algorithm cost improves or matches local implementation |
| E2EE bridge | `split-by-language` | `language-family` | `extension-dep`; never hand-roll Olm or Megolm in this repository | Use maintained Matrix crypto bindings where available; TS facade should not own secure storage | Use maintained native or Dart-compatible crypto binding when it fits the target | Wrapper around a maintained Matrix crypto implementation, not hand-rolled Olm or Megolm | Secure storage, device trust UI, backup UX, native keychain access, and background task policy | A target ecosystem already has a maintained native Matrix crypto binding with better support | High; isolate from pure core and publish separately | Separate crypto artifacts per ecosystem and platform | Encrypted-room send, receive, backup, restore, and verification flows pass in each adopted language |
| HTTP transport / retry / cancellation | `adapter-owned` | `adapter-only` | `adapter-owned` or `avoid-shared` | Native `fetch`, framework client, or Node HTTP stack chosen by the host | Dart `http`, platform channel, or framework-owned client chosen by the host | None by default; shared code may expose request descriptors only | Fetch/client selection, retry, timeout, cancellation, proxy, cookies, and platform network policy | A language family shares a transport runtime and can add it without constraining others | None for Rust when policy changes stay in adapters | No Rust artifact required | Adapter tests prove host-owned cancellation and retry behavior; shared descriptors do not add request latency |
| Token storage / secure storage | `adapter-owned` | `adapter-only` | `adapter-owned` | Browser storage, server secret store, or Expo secure storage selected by the host | Flutter secure storage, platform keychain, or server secret store selected by the host | None | Secure storage, token refresh timing, logout cleanup, and process lifecycle | A platform has a common secure-storage abstraction that still keeps host ownership explicit | None for Rust | No Rust artifact required | Logout and restore tests prove tokens are not persisted by the UI-free core |
| UI surface rendering | `adapter-owned` | `adapter-only` | `adapter-owned` | Vue, Next.js, React Native, or other UI layer renders platform-neutral surfaces | Flutter, native Dart UI, or other UI layer renders platform-neutral surfaces | Platform-neutral UI surface JSON only | Component hierarchy, accessibility affordances, navigation, layout, gestures, and framework state | A design-system adapter can be shared within one ecosystem without leaking into protocol behavior | None for Rust | No Rust artifact required | UI surface conformance maps required operation and acceptance-flow IDs without forcing component structure |

### Initial Shared-Core Adoption Gates

The first shared-core work should prove the adoption loop before larger
domains move. Start with small, observable protocol boundaries that can pass the
same vectors in `houra-spec`, `houra-labs`, `houra-server`, and `houra-client`
without turning adapter policy into shared code.

`SPEC-114` defines the evidence bundle shape for these gates. A candidate can
remain `lab-candidate`, or it can be closed as `adapter-owned`,
`split-by-language`, or `avoid-shared`; those outcomes are valid when the
evidence does not justify shared adoption. `shared-adopted` still requires a
focused implementation issue before any repository treats a shared artifact as
an active dependency.

| Candidate | Scope | Spec and vectors | Consumer repos | Shared artifact boundary | Adapter-owned boundary | Timing rule | Evidence before adoption |
|---|---|---|---|---|---|---|---|
| Matrix versions request/response handling | Parse and validate `GET /_matrix/client/versions` request/response shape and release-advertisement result fields | `SPEC-030`, `SPEC-064`, `test-vectors/core/matrix-client-versions-basic.json`, `test-vectors/core/matrix-version-advertisement-*.json` | `houra-labs` first for evidence; `houra-server` and `houra-client` stay TypeScript unless a later adoption issue is opened | Optional lab parser / validator plus TypeScript WASM or N-API facade and Dart facade only after artifact evidence exists | Fetching the endpoint, cache policy, runtime feature gating, release decision ownership, and all network behavior | Benchmark gate; do not migrate existing implementations only because adjacent code was touched | Vector parity, p95 `+10%` or hidden latency evidence, secret-free diagnostics, artifact manifest, `abi_version`, facade stability notes, rollback to local parser |
| Matrix / Houra error parsing and emission | Parse and build public error envelopes and stable Matrix `M_*` vocabulary without owning user-facing messages or retry policy | `SPEC-002`, `SPEC-031`, `test-vectors/core/error-basic.json`, `test-vectors/core/matrix-foundation-error-basic.json`, `test-vectors/auth/auth-error-basic.json`, `test-vectors/media/matrix-media-download-not-found.json` | `houra-labs` first for evidence; `houra-server` and `houra-client` stay TypeScript unless a later adoption issue is opened | Optional shared error enum, envelope parser, and serializer with stable host-language result types | HTTP status selection, retry/cancellation, telemetry, localization, UI copy, and product-specific recovery flow | Benchmark gate; next-touch swaps require an explicit adoption decision | Cross-repo vector parity, no adapter-specific fields in shared output, redaction review, p95 evidence, packaging notes, rollback to local error mapping |

Deferred candidates:

- Identifier and URI validation should follow once the versions and error
  gates prove the artifact manifest and facade stability flow.
- Transaction ID and idempotency helpers should follow only when retry and
  offline queue policy can stay adapter-owned.
- Event content validation, canonical JSON / signing helpers, room-version
  algorithms, and E2EE bridges stay planned gates until domain-specific parity,
  security, and packaging evidence exists.
- HTTP transport, token storage, secure storage, and UI rendering remain
  non-targets for shared protocol core adoption.

日本語メモ: production は TypeScript 実装を正道にし、`versions` と error envelope も
まず `houra-labs` で artifact / parity / performance evidence を見るだけにします。
`houra-server` と `houra-client` へ入れるのは、TS 実装より小さい・速い・安全などの
理由が揃い、明示の adoption issue を切った場合に限ります。

### Security, Privacy, and Abuse-Case Review

This cross-cutting review tracks specification guardrails that prevent Houra
contracts from leaving security-sensitive behavior ambiguous. It does not
collect implementation secrets, production configuration, raw tokens, private
keys, push provider credentials, or unredacted release artifacts.

| Review area | Contract coverage | Current follow-up | Adoption rule |
|---|---|---|---|
| Auth/session lifecycle and owner scope | `SPEC-004`, `SPEC-032`, `SPEC-034`, `SPEC-053` cover bearer-token attachment, logout invalidation, device APIs, and key-backup surfaces | #180 closes the missing Houra stale-token logout vector plus Matrix device and key-backup owner-scope negative vectors | Do not record implementation adoption unless stale-token and cross-user negative vectors pass |
| Protected key and verification operations | `SPEC-050`, `SPEC-054`, `SPEC-069` keep crypto operations adapter-owned and define parser-facing device-key / verification surfaces | #179 tracked the original `SPEC-054` auth precondition mismatch; `SPEC-054` now requires auth before signature or query semantics | Protected key operations must fail authentication before semantic signature errors are evaluated |
| Media filename and download metadata | `SPEC-020`, `SPEC-038`, `SPEC-071`, `SPEC-072` cover MVP media, Matrix media, optional range/thumbnail/resume behavior, and encrypted-media boundaries | #181 closes `Content-Disposition` filename safety for CR/LF, control characters, separators, traversal-like names, and MVP quoting policy; #320 expands `SPEC-071` into optional Product MVP vNext media transfer vectors and UI surface evidence; #321 expands `SPEC-072` into optional encrypted attachment vectors and UI surface evidence | Download metadata must not permit header injection, unsafe path-shaped filenames, signed URL leakage, local path leakage, plaintext media byte evidence, media-key leakage, decrypted thumbnail evidence, or cache filenames that expose user data |
| Federation and push outbound destinations | `SPEC-055`, `SPEC-060`, and `SPEC-061` define federation bootstrap, push gateway, and federation smoke boundaries | #182 closes SSRF-oriented destination controls for well-known redirects, DNS rebinding, private ranges, and push gateway URLs | Outbound request contracts must fail closed on unsafe internal destinations while preserving legitimate public federation and push gateway paths |
| Error envelopes, diagnostics, and release evidence | `SPEC-002`, `SPEC-031`, `SPEC-064`, `SPEC-065`, `SPEC-070`, `SPEC-071`, and `SPEC-072` define public error shape, fail-closed advertisement, release evidence fields, optional vNext recovery/media evidence, and redacted boundary evidence | #319 expands `SPEC-070` into optional Product MVP vNext recovery / IdP vectors and UI surface evidence; #321 expands `SPEC-072` into optional encrypted media state/retry/trust-copy evidence; Matrix release evidence implementation refs remain tracked by #200 and must cite redacted artifacts only | Public errors and release evidence must not expose bearer tokens, refresh tokens, reset tokens, email verification tokens, authorization codes, callback query values, private keys, media keys, room keys, recovery keys, pushkeys, vendor tokens, raw secrets, plaintext bytes, or internal state beyond the contract vector |
| Shared-core security boundary | `SPEC-114`, `Shared boundary and risk rule`, and `Initial Shared-Core Adoption Gates` keep shared parser/validator work separate from host-owned transport, storage, token, crypto, retry, and UI policy | Future adoption issues should inherit #198 and #323 evidence requirements instead of moving host-owned secrets into shared code | Shared artifacts require vector parity, p95 evidence, redaction review, artifact manifest, `abi_version`, facade stability notes, and rollback before adoption |

Security and privacy review issue handling:

- #179 closed the highest-priority protected-key auth-precedence gap by adding
  authenticated positive vectors and missing-token negative coverage to
  `SPEC-054`.
- #180 closes the auth owner-scope gap by adding Houra logout-token
  invalidation and Matrix cross-user device / key-backup negative vectors.
- #181 closes the media header-safety gap by requiring unsafe filename download
  variants to fail before `Content-Disposition` is emitted.
- #182 closes the outbound egress gap by requiring federation discovery and push
  gateway destinations to reject unsafe internal ranges, redirect-to-private,
  and DNS rebinding before sending traffic.
- Do not create implementation-repository adoption issues for future security
  review gaps until the corresponding contract and vector changes land in
  `houra-spec`.
- If a later review finds only implementation-owned configuration or storage
  policy, record it in the implementation repository; do not turn it into a
  normative `houra-spec` contract unless public behavior is ambiguous.

日本語メモ: security / privacy の横断レビューでは、新規に広い実装監査を増やさず、
仕様が曖昧な箇所だけを issue-sized に分けます。#179 は protected key endpoint の
auth precedence と missing-token coverage で閉じ、残る具体 gap は #180〜#182 で
追跡します。release evidence や shared-core adoption は secret を含まない redacted
artifact / ref / command evidence に限定します。
