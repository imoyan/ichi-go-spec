# Matrix v1.18 Compliance Matrix

This supporting document was split from the README so Matrix roadmap, release
evidence, and domain coverage details can evolve without making the repository
entrypoint hard to review. It does not supersede contracts, vectors, or release
gates.

This section is the planning boundary for moving from the Houra Product MVP
subset toward Matrix compliance. It does not by itself change any public
Houra contract, vector, design token, or UI surface.

Matrix reference snapshot:

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/>
- Release note: <https://matrix.org/blog/2026/03/26/matrix-v1.18-release/>
- Checked at: 2026-05-09T15:29:22+09:00
- Timezone: Asia/Tokyo

Matrix compliance must be tracked by API domain, not as a single vague label:

| Matrix domain | v1.18 scope source | Current Houra state | Target gate |
|---|---|---|---|
| Client-Server API | `/_matrix/client/*`, media, auth, sync, rooms, user data, devices, reporting, admin capabilities | Product MVP covers a small `/_houra/client/*` subset; `SPEC-030` through `SPEC-038` add Matrix versions, auth/session, registration, devices, room create/join/leave/state, send event/messages, sync, and media upload/download contracts; `SPEC-039` defines the integrated live e2e adoption gate; `SPEC-045` starts Client-Server breadth with profile, account data, and room tags; `SPEC-046` adds receipts, typing, and read markers; `SPEC-047` adds filters, presence, and capabilities; `SPEC-048` adds room directory, aliases, and invites; `SPEC-049` adds moderation, reporting, and admin controls | Matrix-compatible endpoint namespace, response shapes, error codes, representative conformance vectors, and live server/client MVP smoke pass |
| Server-Server API | federation discovery, signed transactions, PDUs/EDUs, event auth, joins/leaves, invites, backfill, key APIs, policy servers | Not implemented; `SPEC-055` adds server discovery, delegated well-known, signing-key publication/query, and destination resolution failure contracts; `SPEC-056` adds transaction send/receive, make/send join, and v2 invite contracts; `SPEC-057` adds backfill, event_auth, state_ids, and representative state-resolution interop gates; `SPEC-061` adds two-Houra and reference-homeserver smoke evidence gates | A second homeserver can federate, exchange signed room events, validate auth, and recover state across restart |
| Application Service API | appservice registration, namespace ownership, transactions, sender localpart, bridge-style event delivery | Not implemented; `SPEC-058` adds registration shape, namespace ownership, homeserver-to-appservice transactions, user queries, and room-alias queries; `SPEC-075` keeps the full-breadth Application Service API, third-party network, ping, Client-Server extension, and bridge behavior gaps explicit and non-advertised for the current release candidate | A registered appservice receives transactions and can puppet/send events within its declared namespaces |
| Identity Service API | third-party identifier validation and lookup | Not implemented; `SPEC-059` adds the separate service boundary, identity token scope, hash lookup, validation session, bind, unbind, and privacy/auth failure gate; `SPEC-076` keeps invitation storage, ephemeral invitation signing, provider delivery, consent UI, and full Identity Service API gaps explicit and non-advertised for the current release candidate | Either explicitly out of supported deployment scope or implemented as a separate identity component with conformance evidence |
| Push Gateway API | push notification gateway contracts | Not implemented; `SPEC-060` adds the separate push gateway boundary, notify payload, `event_id_only` privacy shape, pusher/push-rule setup, rejected pushkey, and delivery failure gate; `SPEC-077` keeps vendor provider credentials, device permission UI, notification rendering, background scheduling, and full Push Gateway API gaps explicit and non-advertised for the current release candidate | Either explicitly out of supported deployment scope or implemented with privacy-aware notification payload tests |
| Room Versions | room version algorithms, event authorization rules, state resolution, room upgrade behavior | MVP rooms do not implement Matrix room versions or event DAG auth; `SPEC-040` adds the first Matrix event DAG and auth-event reference contract, `SPEC-041` adds state snapshot / representative state-resolution vectors, `SPEC-042` defines the stable room versions 1-12 / default 12 gate, `SPEC-043` adds representative membership, power-level, and redaction auth vectors, `SPEC-044` adds alias / upgrade / restart persistence gates without full room-version auth completeness, and `SPEC-078` keeps full room-version algorithm and domain-wide advertisement gaps explicit and non-advertised for the current release candidate | Supported room versions are listed, default room version is declared, and auth/state-resolution tests pass |
| Olm & Megolm | E2EE primitives, one-time keys, device keys, encrypted room messaging, key backup, verification, cross-signing | Not implemented; `SPEC-050` defines the adapter ownership boundary and forbids local Olm/Megolm implementation; `SPEC-069` isolates the first client/parser-facing device-key query contract; `SPEC-051` adds device key, one-time key, and fallback key publication/claim contracts; `SPEC-052` adds to-device and encrypted-room send/receive gates; `SPEC-053` adds server-side key backup and logout/relogin restore gates; `SPEC-054` adds SAS verification, cross-signing, and wrong-device failure gates; `SPEC-072` defines optional Product MVP encrypted attachment evidence without widening E2EE support claims; `SPEC-079` keeps full Olm & Megolm E2EE breadth explicit and non-advertised for the current release candidate | Use a mainstream Matrix crypto stack; encrypted rooms, device trust, key backup, restore, verification, encrypted media, and wrong-device failure flows pass |
| Appendices/common rules | identifiers, timestamps, namespacing, error vocabulary, deprecation behavior | Partially aligned only where MVP contracts copied the concept | Shared parser and validation tests enforce Matrix grammar and compatibility claims |

Matrix domain coverage evidence report:

- `SPEC-062` defines the Matrix v1.18 stable-domain coverage report shape for
  contract refs, implementation repos, adoption issue refs, pass/fail evidence,
  known stable-domain gaps, artifact paths, and advertisement decisions.
- The report covers Client-Server API, Server-Server API, Application Service
  API, Identity Service API, Push Gateway API, Room Versions, Olm & Megolm, and
  Appendices/common rules.
- Unstable MSCs remain excluded unless a later issue explicitly adopts a
  specific MSC with its own contract, vector, adoption issue, and release note.
- After `SPEC-062` merges, create adoption issues for `houra-server` and
  `houra-client` to emit implementation evidence in the same shape. Create an
  `houra-labs` issue only if shared-core evidence becomes part of a domain gate.

Matrix Complement-compatible CI lane:

- `SPEC-063` defines the Complement-compatible homeserver black-box CI lane
  setup, minimum pass/fail report shape, artifact requirements, and release gate
  candidate rules.
- Passing this gate does not replace the domain-specific vectors in this
  repository and does not by itself allow Matrix version or domain
  advertisement.
- After `SPEC-063` merges, create an adoption issue for `houra-server`. Do not
  create `houra-client` or `houra-labs` adoption issues unless a later
  client-facing or shared-core Complement harness is intentionally scoped.

Matrix version advertisement release gate:

- `SPEC-064` defines the fail-closed release gate for
  `GET /_matrix/client/versions` and release notes. Matrix versions, domains,
  and unstable feature flags can be advertised only when the included behavior
  has passing contract and implementation evidence.
- Missing, failed, stale, or secret-leaking evidence keeps advertisement and
  release tags blocked.
- After `SPEC-064` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if shared-core release
  artifacts begin advertising Matrix support.

Matrix release notes evidence template:

- `SPEC-065` defines the release notes sections and evidence link fields
  required for any Houra release that mentions Matrix v1.18 support.
- Supported domains require passing evidence links; excluded domains require a
  reason or known-gap issue; unstable MSCs are excluded by default.
- After `SPEC-065` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if shared-core release
  artifacts begin publishing Matrix support claims.

Matrix v1.18 release readiness gate:

- `SPEC-066` defines the final readiness checklist, tag/release ordering,
  rollback criteria, and non-advertisement decision rules for a release that
  claims Matrix v1.18 stable-domain support.
- Passing this gate does not itself implement or advertise Matrix support; it
  requires `SPEC-062`, `SPEC-063`, `SPEC-064`, and `SPEC-065` evidence for the
  same checked release refs.
- After `SPEC-066` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if shared-core artifacts
  become part of the release candidate.

Canonical release evidence example bundle:

- `test-vectors/core/matrix-v1-18-release-evidence-example-bundle.json` shows
  one implementation-facing example that links the `SPEC-062` coverage report,
  `SPEC-063` Complement report, `SPEC-064` advertisement decision, `SPEC-065`
  release notes evidence, and `SPEC-066` readiness checklist for the same
  release candidate refs.
- The bundle is illustrative evidence wiring only. It does not replace the
  individual contract vectors, add endpoint behavior, or widen Matrix version
  advertisement beyond the listed domains with passing evidence.
- `test-vectors/core/matrix-v1-18-release-evidence-current-blocked-bundle.json`
  is the current #200 blocked bundle. It records real implementation refs from
  the latest `houra-server` and `houra-client` evidence, keeps the example
  bundle separate, and intentionally sets
  `stale_or_mismatched_refs_block_release: false`,
  `versions_advertisement_allowed: false`, and `ready_to_publish: false` until
  a publishable Matrix support claim is allowed.

Matrix v1.18 roadmap close-out snapshot:

- Snapshot checked at: 2026-05-18T09:35:03+09:00.
- #95 remains the parent Matrix v1.18 roadmap. #189 is the historical close-out
  snapshot lane; current issue sync is maintained here and in #95 so domain
  issues, implementation adoption refs, and release evidence do not drift.
- The `houra-spec` domain issue checklists for #97 through #101 have completed
  their contract/vector/gate children. That is contract coverage, not a release
  support claim.
- `houra-server` adoption refs named by #189 are closed:
  imoyan/houra-server#59 through imoyan/houra-server#69 and
  imoyan/houra-server#106 through imoyan/houra-server#108. imoyan/houra-server#145
  records the current-candidate release-scope exclusion decisions that closed
  imoyan/houra-server#133 as an active Complement/full-breadth blocker.
- Current open `houra-server` Matrix release-scope trackers are now limited to
  imoyan/houra-server#135 and imoyan/houra-server#136. PR #374 refreshed the
  Client-Server full-breadth rollup evidence for #135, and PR #375 updated the
  server CI spec checkout path without widening the Matrix claim surface. Former
  child trackers for Client-Server breadth, Room Versions, E2EE, Application
  Service, Identity Service, Push Gateway, and Appendices/common are closed at
  this snapshot unless they are reopened by a narrower future release scope.
- `houra-client` adoption refs named by #189 are closed:
  imoyan/houra-client#55 through imoyan/houra-client#66 and
  imoyan/houra-client#95 through imoyan/houra-client#97. No open
  `houra-client` issue remained in the checked issue list.
- `houra-labs` remains an optional shared-core/parser exploration lane, but the
  checked issue and PR lists are empty. The #173 parent tracker and #174
  through #180 evidence lanes are closed, including parser/normalizer inventory,
  shared-core benchmark, capability advertisement, negative capability, and
  theme-token sync evidence. Earlier parser/shared-core issues including
  imoyan/houra-labs#56 through #77 are also closed. These lab records do not
  widen Matrix version advertisement unless a later release candidate
  deliberately includes shared-core artifacts as required evidence.
- #200 records the current blocked release evidence bundle with real
  implementation refs and keeps Matrix version advertisement fail-closed.
  #201 records the `SPEC-068` OAuth account-management adoption boundary and
  keeps full Matrix OAuth 2.0 support out of scope. #202 records the `SPEC-069`
  device-key query-only adoption boundary and keeps full E2EE / Olm-Megolm
  support out of scope. #95 must still not be presented as release-ready until
  #97 through #101 link current pass/fail evidence and #95 records a
  publishable Matrix support claim or explicit blocked / out-of-scope decisions
  for the release candidate.
- The current blocked bundle was refreshed at 2026-05-18T07:14:22+09:00 and
  records the same candidate set from `houra-spec`
  39c3e98d8070dd86ef3440fe4a2f92fc9c2d0a89, `houra-server`
  b3b3eb2d98b1eb924084f6f07a653a1c01b92b03, and `houra-client`
  b7c31882dbc17c35a25215990e8b0ab86f38f777. It links every excluded stable
  domain to an explicit current-candidate release-scope decision:
  imoyan/houra-server#135 through imoyan/houra-server#142. Later child issues
  under the same domains track implementation breadth without changing that
  blocked candidate set. Client-Server API still references both #97 and #99
  because the MVP-equivalent slice and breadth slice share the same Matrix
  domain. Release readiness remains blocked by fail-closed Matrix version
  advertisement; `GET /_matrix/client/versions` still returns no Matrix
  versions and no publishable Matrix support claim is allowed. The refreshed
  refs include imoyan/houra-server#321 / #327 release-surface evidence and
  imoyan/houra-client#205 / #206 publish-readiness evidence.
- Post-bundle Client-Server registration classification sync:
  imoyan/houra-server#303 merged at 2026-05-16T23:29:29+09:00 and records the
  Complement `TestLogin` one-shot registration helper failure as a known
  non-advertised Client-Server registration breadth gap under
  imoyan/houra-server#135 and imoyan/houra-server#191. This sync does not
  change runtime behavior and is included in the refreshed blocked candidate
  refs above. `/versions` remains fail-closed with no Matrix support claim.
- `SPEC-073` decomposes `houra-server#135` Client-Server full-breadth gaps into
  discovery/support, auth refresh, event history, room breadth, sync extension,
  media breadth, and E2EE Client-Server lanes. It is a fail-closed gap
  inventory only; it does not widen Matrix version advertisement. It also
  orders the closed `houra-server#178` through `houra-server#184` release
  exclusions into contract/vector/server-gate promotion lanes so runtime
  compatibility is not inferred from closed exclusion trackers.
- `SPEC-074` decomposes `houra-server#136` Server-Server full-breadth gaps into
  discovery/key/auth, transaction/PDU/EDU, event retrieval, join/knock/leave,
  directory/query, federation E2EE/media, policy/ACL/signing, and Complement
  breadth lanes. It is a fail-closed gap inventory only; it does not claim full
  federation or Complement pass.
- `SPEC-075` decomposes `houra-server#137` Application Service full-breadth gaps
  into registration/token lifecycle, transaction delivery, user/room queries,
  third-party network directories, ping/liveness, Client-Server extension, and
  bridge evidence lanes. It is a fail-closed gap inventory only; it does not
  claim full Application Service API or bridge protocol support.
- `SPEC-076` decomposes `houra-server#138` Identity Service full-breadth gaps
  into service/account/terms, key/signature, lookup/privacy, validation/provider
  delivery, bind/unbind lifecycle, invitation storage, ephemeral signing,
  consent UI, and release-evidence lanes. It is a fail-closed gap inventory
  only; it does not claim full Identity Service API or external provider
  operation.
- `SPEC-077` decomposes `houra-server#139` Push Gateway full-breadth gaps into
  notify payload, pusher configuration, push rule evaluation, delivery retry,
  privacy payload minimization, vendor provider credentials, client permission
  and rendering, security/redaction, and release-evidence lanes. It is a
  fail-closed gap inventory only; it does not claim production push provider or
  client notification support.
- `SPEC-078` decomposes `houra-server#140` Room Versions full-algorithm gaps
  into stable-version metadata, event format, auth rules, state resolution,
  event acceptance/rejection, room upgrades, federation, shared helpers, and
  release-evidence lanes. It is a fail-closed gap inventory only; it does not
  claim full room-version algorithms or domain-wide room-version advertisement.
- `SPEC-079` decomposes `houra-server#141` Olm & Megolm full E2EE gaps into
  maintained crypto stack/local state ownership, device keys/device lists, Olm
  to-device, Megolm room sessions, key backup/secret storage, verification and
  cross-signing, encrypted media, cross-domain interaction, and release-evidence
  lanes. It is a fail-closed gap inventory only; it does not claim full E2EE or
  local Olm/Megolm support.
- `SPEC-080` splits the `m.room_versions.default` /
  `m.room_versions.available` capabilities advertisement boundary out of
  `SPEC-078`. It keeps `available` as an implementation-evidence list, not a
  copy of the Matrix v1.18 stable room-version registry, so the representative
  room version 12 subset does not become a full Room Versions claim.
- `SPEC-081` is the first `SPEC-079` child contract. It records the maintained
  Matrix crypto stack evidence gate and keeps secure storage, recovery keys,
  backup secrets, local deletion, and recovery UX host-owned. It does not select
  a crypto package, add endpoints, or widen Matrix version advertisement.
- `SPEC-085` splits the event retrieval, joined-members, historical-membership,
  timestamp-to-event, and deprecated compatibility descriptor/parser boundary
  out of `SPEC-073`. It gives `houra-labs` a parser-only adoption target while
  keeping runtime route behavior, history visibility, authorization, deprecated
  endpoint support, and Client-Server advertisement excluded.
- `SPEC-093` splits the `/sync` query descriptor and response-section parser
  boundary out of the `SPEC-073` `sync-breadth-extensions` lane. It gives
  `houra-labs` a parser-only adoption target for `full_state`, `filter`,
  `set_presence`, `use_state_after`, lazy-loading filter flags, presence,
  to-device, device-list, one-time-key-count, invite, leave, and knock sync
  envelopes while keeping long-poll timing, token persistence, fanout
  correctness, E2EE readiness, lazy-loading correctness, and Matrix
  Client-Server advertisement fail-closed.
- `SPEC-095` splits the media repository descriptor and metadata parser
  boundary out of the `SPEC-073` `media-repository-breadth` lane. It gives
  `houra-labs` a parser-only adoption target for media config, URL preview,
  thumbnail, create-upload, resumable-upload metadata, safe filename, and
  `mxc://` URI helpers while keeping binary transfer, thumbnail generation,
  preview crawling, remote fetch, range requests, encrypted attachment behavior,
  and Matrix Client-Server advertisement fail-closed.
- `SPEC-131` records the detailed Matrix v1.18 changelog-delta audit for
  `M_USER_LIMIT_EXCEEDED`, `m.recent_emoji`, invite blocking /
  `M_INVITE_BLOCKED`, media/rich-text presentation metadata, and Identity
  `submitToken` / `M_TOKEN_INCORRECT`. It is a fail-closed inventory for #369
  through #373 only; runtime support, release notes, `/versions`, and Matrix
  support claims remain unchanged until the owning domain has same-candidate
  evidence.
- #97 through #101 should not be closed merely because their spec-side
  checklists are complete or because the current release candidate excludes the
  domain from advertisement. Close them only when #95 links current pass/fail
  evidence and records the intended release outcome for that domain.
- Current-state refresh checked at 2026-05-18T09:35:03+09:00:
  #97 through #101 remain intentionally open as domain-level release outcome
  trackers, not as missing `houra-spec` decomposition work. #97 and #98 have
  adopted-subset evidence in the current blocked bundle, while #99, #100, and
  #101 keep full-breadth, E2EE, federation, Application Service, Identity
  Service, and Push Gateway claims out of scope until owner-repo leaf gates
  provide same-candidate pass evidence and an aligned `/versions` response.
  #314 records the fast `houra-spec` verification baseline and local `.claude/`
  failure classification. #323 adds the shared-core adoption evidence schema
  and keeps shared artifacts separate from required dependencies.
  imoyan/houra-server#321 is closed by #327, imoyan/houra-server#135 has the
  PR #374 current rollup evidence, imoyan/houra-client#205 is closed by #206,
  and `houra-labs` has no open issue or PR. The current #95 outcome remains an
  explicit blocked / not-advertised release candidate rather than an unresolved
  release-surface question. This note does not widen Matrix support claims.

Matrix readiness map:

- Readiness map checked at: 2026-05-18T09:35:03+09:00.
- The first publishable Matrix scope defaults to a Client-Server subset only.
  This still requires current pass/fail evidence, release notes, and
  `/versions` advertisement that name the included endpoint families exactly.
  Until that evidence is refreshed, `/versions` remains empty and no Matrix
  support claim is allowed.
- `houra-server#135` remains the release-blocker tracker for deciding whether
  the Client-Server subset can be advertised. PR #374 records the current
  Client-Server full-breadth rollup and keeps all SPEC-073 lanes
  `follow-up-required`, with `client_server_full_breadth_claimed=false`,
  `first_publishable_subset_advertised=false`, and
  `versions_advertisement_widened=false`. The 2026-05-16 Complement
  `TestLogin` narrow smoke reached the Houra server and failed at the adopted
  registration UIA `401` challenge; it is part of known non-advertised
  Client-Server registration breadth, not a support claim or advertisement
  blocker removal.
- Room Versions are explicitly out of scope for the first subset:
  former `houra-server#140` and related child records remain release-scope
  evidence only. Full room-version algorithms and domain-wide advertisement are
  not claimed until #98 and #95 record a widened release outcome.
- E2EE is explicitly out of scope for the first subset. Former
  `houra-server#141` and related child records remain release-scope evidence
  only; full E2EE support, local Olm/Megolm behavior, and E2EE advertisement
  are not claimed until #100 and #95 record a widened release outcome.
- Federation and ecosystem APIs are explicitly out of scope for the first
  subset: Server-Server `houra-server#136` remains open as the current
  release-scope tracker, while Application Service, Identity Service, and Push
  Gateway are covered by closed release-scope records that do not advertise
  support. Complement full breadth and full federation support are not claimed.
- `houra-client` has no open issue or PR in the checked lists. `houra-labs` also
  has no open issue or PR after closing #173 through #180. Create new adoption
  issues only when the selected release scope requires current client evidence
  or shared-core/parser artifacts.
- Performance work starts after the claim boundary is stable. Prioritize
  verification speed and stability first: vector batch runtime, server smoke
  runtime, release evidence generation runtime, and Complement-compatible lane
  stability. Record p95 runtime evidence only when a shared parser/core
  adoption or other hot-path change is introduced.
- Release verification baseline checked at 2026-05-17T08:20:00+09:00:
  `dart tool/check_spec.dart` completed in 0.872s in a clean detached
  `houra-spec` worktree at `511cb59b3011eb27cbb80003d0c4226436852036`;
  `git diff --check` completed in 0.022s in the same clean worktree. In the
  live checkout, `dart tool/check_spec.dart` completed its scan in 0.732s but
  failed on an unrelated local `.claude/` helper worktree under the repository
  root. That failure is classified as local verification-environment noise, not
  a Matrix claim or vector failure. `.claude/` is now ignored and treated as a
  generated local entry by `tool/check_spec.dart`; after that classification
  fix, the same live checkout passed in 0.711s.
- First improvement candidates: keep `houra-spec` vector validation as the
  fast local gate, record wall time for downstream `houra-server` smoke /
  request-vector / release-evidence generation and Complement-compatible lanes
  before optimizing them, and split or cache only duplicated fixture scans or
  evidence generation that dominate PR iteration. Do not use this baseline to
  widen `/versions`, release notes claims, or `publishable_matrix_support_claim`.
- 日本語メモ: 初回の広告可能範囲は Client-Server subset に限定し、Room Versions、
  E2EE、Federation、Application Service、Identity Service は明示的な対象外として
  fail-closed のまま扱う。速度改善は、claim 境界と evidence が揃った後に、まず
  検証時間と安定性から着手する。

Matrix 2.0 readiness preparation:

- Tracking parent issue: imoyan/houra-spec#377.
- `SPEC-133` and
  `test-vectors/core/matrix-2-snapshot-v1-18-diff-checklist.json` define the
  snapshot / v1.18 diff checklist for #380. They are planning evidence only:
  stable Matrix 2.0 sources are recorded as pending until the Matrix project
  publishes the stable specification source and release note to use for a
  release-candidate snapshot.
- `SPEC-134` and
  `test-vectors/core/matrix-2-versions-advertisement-evidence-gate.json`
  define the #381 advertisement gate. It blocks Matrix 2.0 in
  `GET /_matrix/client/versions`, release notes, release bundles, and
  `publishable_matrix_support_claim` until stable-source and same-candidate
  domain evidence pass.
- `SPEC-135` and `test-vectors/auth/matrix-2-oauth-oidc-readiness-gate.json`
  define the #382 OAuth/OIDC readiness gate. It keeps `SPEC-068`
  account-management behavior as a v1.18 boundary while blocking Matrix 2.0
  OAuth/OIDC support claims until stable requirements, provider-behavior
  separation, redacted evidence, and same-candidate release evidence pass.
- `SPEC-136` and `test-vectors/sync/matrix-2-sliding-sync-readiness-gate.json`
  define the #383 Sliding Sync readiness gate. It keeps `SPEC-037` and
  `SPEC-093` as v1.18 sync boundaries while blocking Sliding Sync, sync
  performance, proxy, and optional-extension claims until stable-source client
  and server evidence pass.
- `SPEC-137` and
  `test-vectors/messaging/matrix-2-e2ee-key-backup-verification-readiness-gate.json`
  define the #384 E2EE readiness gate. It keeps `SPEC-079` and `SPEC-081` as
  v1.18 gap/ownership boundaries while blocking E2EE, key backup, verification,
  cross-signing, encrypted-room, and maintained-crypto-stack claims until
  stable-source and secret-free same-candidate evidence pass.
- `SPEC-138` and
  `test-vectors/rooms/matrix-2-room-versions-auth-state-readiness-gate.json`
  define the #385 Room Versions readiness gate. It keeps `SPEC-078` and
  `SPEC-080` as v1.18 gap/capabilities boundaries while blocking Room Versions,
  event-auth, state-resolution, default/available room-version, and full
  algorithm claims until stable-source same-candidate evidence passes.
- Matrix 2.0 remains unadvertised until the Matrix project publishes a stable
  Matrix 2.0 specification release and Houra records same-candidate evidence
  for the advertised domains.
- Preparation issues are intentionally split by gate: snapshot / v1.18 diff
  checklist (#380), versions advertisement evidence (#381), OAuth/OIDC (#382),
  Sliding Sync / sync extension (#383), E2EE / key backup / verification (#384),
  Room Versions / auth / state resolution (#385), and Extensible Profiles /
  Events (#386).
- These issues are readiness lanes only. They do not widen the current Matrix
  v1.18 blocked candidate, `/versions`, release notes, Product MVP readiness,
  or any runtime support claim.
- When Matrix 2.0 is released, refresh the dated official reference snapshot
  first, then promote only the stable requirements with matching contract,
  vector, implementation, release evidence, and advertisement-gate results.

Matrix compliance phases:

1. **Audit and contract map**: add Matrix-domain coverage metadata to this
   repository, map current `SPEC-*` files to Matrix v1.18 domains, and create
   issues for each missing domain before implementation.
2. **Client-Server compatibility baseline**: add Matrix v3 endpoint contracts
   and vectors for the MVP-equivalent flow first: `/versions`, login, logout,
   whoami, registration, room create/join/leave, state, send event, timeline,
   sync, and media upload/download, then bind those families with the
   `SPEC-039` live server/client adoption gate.
3. **Matrix data model migration**: introduce Matrix-compatible identifiers,
   event IDs, event DAG storage, state snapshots, auth events, room versions,
   and sync token semantics in `houra-server`.
4. **Client-Server breadth**: add profile, account data, tags, receipts,
   typing, read markers, filters, presence, capabilities, devices, room
   directory, aliases, invites, kicks, bans, power levels, redactions, and
   reporting.
5. **E2EE**: adopt a maintained Matrix crypto implementation instead of
   hand-rolling Olm/Megolm behavior, then implement device keys, one-time keys,
   fallback keys, encrypted room send/receive, key backup, verification, and
   cross-signing.
6. **Federation**: implement server signing keys, well-known discovery,
   federation auth, transactions, make/send join, invites, backfill, event
   validation, state resolution, and policy-server interactions.
7. **Ecosystem APIs**: decide whether Identity Service and Push Gateway are
   in-process, separate services, or explicitly unsupported for the first
   compliance release; Application Service support should be tracked as its own
   implementation lane.
8. **Conformance harness**: wire official Matrix specification inputs and a
   Matrix compatibility test runner into CI, while keeping Houra vectors as
   regression coverage for the compatibility layer.

Matrix compliance advertisement gate:

- Do not claim `Matrix v1.18 compliant` for Houra until each included Matrix
  domain has an explicit pass/fail report and any excluded optional deployment
  domain is named as out of scope.
- Do not return Matrix spec versions from `/versions` as supported until the
  matching endpoint set, deprecated endpoint behavior, and advertised unstable
  features are verified for that release.
- Public behavior changes must land in `houra-spec` first, then be adopted by
  `houra-server` and `houra-client` with implementation metrics and clean-room
  notes.
- Issue and PR scopes should stay domain-sized: for example, Client-Server auth,
  Client-Server room state, Room Version 12 auth rules, Federation join, or
  Megolm key backup. Do not mix federation, E2EE, and client UI in one PR.

Matrix Client-Server MVP live e2e gate:

- `SPEC-039` is the integration gate for `SPEC-030` through `SPEC-038`. It
  requires a live `houra-client` core run against a live `houra-server` target
  for versions, login flows, registration, password login, whoami, devices,
  room create/join/state/leave, send event, messages, sync, media upload and
  download, and logout.
- A pass record must name the `houra-spec` ref, `houra-server` ref,
  `houra-client` ref, commands, per-step pass/fail results, `/versions`
  advertisement result, known exclusions, and clean-room confirmation.
- Product MVP happy path evidence and Docker Compose deploy smoke evidence are
  separate evidence classes. Happy path evidence covers contract/vector/UI
  behavior and server-client interaction; deploy smoke evidence covers startup,
  migration, health, connectivity, persistence/auth smoke, and redaction.
- Follow-up adoption tracking is split as `imoyan/houra-server#227` for Docker
  Compose deploy smoke evidence and `imoyan/houra-client#121` for Product MVP
  happy path evidence.
- After `SPEC-039` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only when the gate adopts or
  changes a shared parser, identifier helper, URI helper, or binding facade.
- Passing this gate does not claim Matrix v1.18 full compliance. It only closes
  the Client-Server MVP-equivalent integration milestone.

Matrix event DAG and auth-event reference gate:

- `SPEC-040` defines the first Matrix room data model gate after the
  Client-Server MVP-equivalent milestone. It covers server/storage-facing event
  envelopes, `prev_events` DAG reference integrity, `auth_events` reference
  integrity, and representative valid/invalid vectors.
- Passing this gate does not claim room versions 1 through 12 support, state
  resolution support, federation support, redaction correctness, or Matrix
  v1.18 full compliance.
- After `SPEC-040` merges, create an `houra-server` adoption issue for event
  DAG persistence. Create an `houra-labs` issue only if a shared parser or
  event validation helper is intentionally adopted, and do not create an
  `houra-client` issue unless the UI-free client core starts consuming these
  server/storage-facing envelopes.

Matrix state snapshot and state-resolution vector gate:

- `SPEC-041` defines state snapshot entries keyed by `(event_type, state_key)`,
  state event application, message event no-op behavior, unconflicted state
  classification, conflicted state event classification, and representative
  state resolution vectors.
- Passing this gate does not claim complete Matrix room version 12 state
  resolution, room versions 1 through 12 support, federation support, redaction
  correctness, or Matrix v1.18 full compliance.
- After `SPEC-041` merges, create an `houra-server` adoption issue for
  restart-safe state snapshots and state-set resolution vector coverage. Create
  an `houra-labs` issue only if a shared state map or room-version helper is
  intentionally adopted, and do not create an `houra-client` issue unless the
  UI-free client core starts consuming these storage-facing snapshots.

Matrix profile, account data, and room tags gate:

- `SPEC-045` defines the Matrix v1.18 profile, global account data,
  room-scoped account data, and room tag endpoint family. It also records that
  account data and `m.tag` updates must become visible through later `/sync`
  responses.
- Passing this gate does not claim receipts, typing, read markers, filters,
  presence, capabilities, room directory, invites, admin controls, E2EE,
  federation, or Matrix v1.18 full compliance.
- After `SPEC-045` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for profile keys, account-data event types,
  or `m.tag` content.

Matrix receipts, typing, and read markers gate:

- `SPEC-046` defines the Matrix v1.18 typing notification, receipt, and
  read-marker endpoint family. It records `/sync` visibility for `m.typing`,
  `m.receipt`, and `m.fully_read`, and it prevents direct `m.fully_read` room
  account-data writes.
- Passing this gate does not claim filters, presence, capabilities, push rules,
  federation EDU delivery, unread-marker UI policy, E2EE, or Matrix v1.18 full
  compliance.
- After `SPEC-046` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for receipt, typing, or read-marker event
  content.

Matrix filters, presence, and capabilities gate:

- `SPEC-047` defines the Matrix v1.18 filter create/read, presence set/get, and
  capabilities endpoint family. It records representative `/sync` visibility
  for `m.presence` and capabilities alignment with room version and profile
  field contracts.
- Passing this gate does not claim search, push rules, user directory, room
  directory, invites, admin controls, E2EE, federation, or Matrix v1.18 full
  compliance.
- After `SPEC-047` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for filters, presence, or capabilities.

Matrix room directory, aliases, and invites gate:

- `SPEC-048` defines the Matrix v1.18 public room directory, directory
  visibility, local alias listing, and invite endpoint family. It builds on
  alias persistence from `SPEC-044` and records `/sync` invite visibility for
  invited users.
- Passing this gate does not claim third-party invites, application service
  network directories, remote public room federation, spaces hierarchy,
  federation invite signing, admin controls, E2EE, or Matrix v1.18 full
  compliance.
- After `SPEC-048` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for public room summaries, alias lists, or
  stripped invite state.

Matrix moderation, reporting, and admin controls gate:

- `SPEC-049` defines the Matrix v1.18 kick, ban, unban, redaction, reporting,
  and account moderation admin endpoint family. It records representative
  permission failures and `m.account_moderation` capability evidence for
  server-local account lock/suspend controls.
- Passing this gate does not claim policy server signing, moderation queue UI,
  appeals, federation enforcement, E2EE, or Matrix v1.18 full compliance.
- After `SPEC-049` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for moderation, reporting, or admin response
  shapes.

Matrix crypto adapter boundary gate:

- `SPEC-050` defines the Matrix v1.18 E2EE adapter boundary before endpoint
  family contracts are added. It requires a maintained Matrix crypto stack and
  forbids local Olm, Megolm, SAS, cross-signing crypto, secret-storage crypto,
  and key-backup crypto implementations in Houra repositories.
- Passing this gate does not claim device key, one-time key, fallback key,
  to-device, encrypted room, key backup, verification, cross-signing, or secret
  storage support.
- After `SPEC-050` merges, create an `houra-client` adoption issue for crypto
  stack selection and adapter ownership. Create `houra-server` adoption issues
  only when server-side key-storage or to-device endpoint contracts merge.
  Create an `houra-labs` issue only if a parser-only shared helper is
  intentionally adopted with parity vectors and a performance gate.

Matrix device, one-time, and fallback keys gate:

- `SPEC-051` defines the Matrix v1.18 device key upload/query and one-time /
  fallback key upload/claim endpoint family. It records representative auth and
  malformed key-shape failures while preserving the `SPEC-050` rule that
  Houra does not implement Olm/Megolm locally.
- Passing this gate does not claim to-device messaging, encrypted rooms, key
  backup, verification, cross-signing, secret storage, federation, or Matrix
  v1.18 full compliance.
- After `SPEC-051` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for device key, one-time key, or fallback key
  payload shapes.

Matrix to-device and encrypted room gate:

- `SPEC-052` defines the Matrix v1.18 to-device send/receive surface,
  `m.room.encryption` setup, `m.room.encrypted` send/receive envelope, and a
  multi-device encrypted room smoke gate. It preserves the `SPEC-050` boundary
  that Houra repositories do not implement Olm/Megolm locally.
- Passing this gate does not claim key backup, verification, cross-signing,
  secret storage, encrypted attachments, federation to-device delivery, or
  Matrix v1.18 full compliance.
- After `SPEC-052` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for encrypted event envelope or to-device
  payload shape validation.

Matrix key backup and restore gate:

- `SPEC-053` defines the Matrix v1.18 server-side key backup version lifecycle,
  opaque room-key backup upload/restore, wrong-version failures, missing-session
  failures, and logout/relogin recovery evidence. It preserves the `SPEC-050`
  boundary that Houra repositories do not implement Megolm locally.
- Passing this gate does not claim verification, cross-signing, secret storage,
  backup deletion, federation, or Matrix v1.18 full compliance.
- After `SPEC-053` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for backup version metadata or room key
  backup payload shape validation.

Matrix verification and cross-signing gate:

- `SPEC-054` defines the Matrix v1.18 SAS verification message flow,
  `m.key.verification.cancel` mismatch behavior, public cross-signing key
  upload/query/signature publication, invalid signature failures, and a
  wrong-device/fingerprint mismatch evidence gate. It preserves the `SPEC-050`
  boundary that Houra repositories do not implement SAS or cross-signing crypto
  locally.
- Passing this gate does not claim secret storage, federation key forwarding,
  QR-code verification UX, full account recovery UX, or Matrix v1.18 full
  compliance.
- After `SPEC-054` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for verification event shape or
  cross-signing public key validation.

Matrix federation discovery and signing keys gate:

- `SPEC-055` defines the Matrix v1.18 Server-Server discovery bootstrap:
  delegated `/.well-known/matrix/server`, `/_matrix/key/v2/server`, batch
  `/_matrix/key/v2/query`, destination resolution fallback/failure evidence,
  and signing-key cache boundaries.
- Passing this gate does not claim federation transactions, make/send join,
  invite, backfill, event auth, state resolution, Application Service, Identity
  Service, Push Gateway, or Matrix v1.18 full federation compliance.
- After `SPEC-055` merges, create an adoption issue for `houra-server`. Do not
  create `houra-client` work unless a later client-visible federation
  configuration surface is intentionally added. Create an `houra-labs` issue
  only if parser-only helpers for server names, well-known bodies, or server-key
  objects are intentionally adopted.

Matrix federation transaction, join, and invite gate:

- `SPEC-056` defines the Matrix v1.18 Server-Server transaction envelope,
  `/_matrix/federation/v1/send/{txnId}` PDU/EDU delivery, make_join/send_join
  handshake, and v2 invite signing contract. It uses `SPEC-055` signing-key
  discovery as the request-authentication foundation.
- Passing this gate does not claim backfill, missing-event retrieval, full event
  authorization, state-resolution completeness, leave/knock, third-party
  invites, federation E2EE EDUs, policy-server hooks, or Matrix v1.18 full
  federation compliance.
- After `SPEC-056` merges, create an adoption issue for `houra-server`. Do not
  create `houra-client` work unless a later client-visible federation surface is
  intentionally added. Create an `houra-labs` issue only if parser-only helpers
  for federation request auth, transaction envelopes, or membership event shape
  are intentionally adopted.

Matrix federation backfill, event auth, and state interop gate:

- `SPEC-057` defines the Matrix v1.18 Server-Server backfill, event_auth,
  state_ids, and representative state-resolution interop gate. It uses
  `SPEC-055` for request authentication and `SPEC-056` for the initial
  transaction/join context.
- Passing this gate does not claim get_missing_events, timestamp lookup, full
  room auth/state-resolution completeness, federation E2EE EDU handling,
  reference homeserver interop, or Matrix v1.18 full federation compliance.
- After `SPEC-057` merges, create an adoption issue for `houra-server`. Do not
  create `houra-client` work unless a later client-visible federation surface is
  intentionally added. Create an `houra-labs` issue only if parser-only or
  room-version-helper adoption is intentionally scoped with parity vectors and
  performance gates.

Matrix Application Service registration and transaction gate:

- `SPEC-058` defines the Matrix v1.18 Application Service registration file
  shape, exclusive namespace ownership, homeserver-to-appservice authorization,
  transaction push, user query, room-alias query, and sender localpart boundary.
- Passing this gate does not claim third-party network APIs, appservice ping,
  bridge protocol behavior, identity, push gateway, or Matrix v1.18 full
  ecosystem compliance.
- `SPEC-075` records those excluded Application Service API lanes as the
  `houra-server#137` full-breadth gap inventory for the current blocked release
  candidate. It preserves the non-advertisement decision until each lane has
  passing evidence or an explicit release exclusion.
- After `SPEC-058` merges, create an adoption issue for `houra-server`. Do not
  create `houra-client` work unless a later user-facing appservice management
  surface is intentionally added. Create an `houra-labs` issue only if
  parser-only helpers for registration or namespace matching are intentionally
  adopted.

Matrix Identity Service boundary gate:

- `SPEC-059` defines the Matrix v1.18 Identity Service boundary for version and
  status checks, identity-service-scoped tokens, terms gate behavior, public key
  lookup shape, hash details, 3PID lookup, email/MSISDN validation sessions,
  bind, validated-3PID query, unbind, and representative privacy/auth failures.
- Passing this gate does not claim invitation storage, ephemeral invitation
  signing, email/SMS provider infrastructure, user-facing consent UI, push
  gateway behavior, or Matrix v1.18 full ecosystem compliance.
- `SPEC-076` records those excluded Identity Service API lanes as the
  `houra-server#138` full-breadth gap inventory for the current blocked release
  candidate. It preserves the non-advertisement decision until each lane has
  passing evidence or an explicit release exclusion.
- After `SPEC-059` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if parser-only helpers for
  3PID, token redaction, or signed association validation are intentionally
  adopted.

Matrix Push Gateway boundary gate:

- `SPEC-060` defines the Matrix v1.18 Push Gateway boundary for
  `POST /_matrix/push/v1/notify`, unsupported endpoint errors, rejected
  pushkeys, duplicate suppression, `event_id_only`, pusher setup, push rule
  setup, `m.push_rules` sync visibility, delivery retry, and privacy handling.
- Passing this gate does not claim APNS, FCM/GCM, Web Push, vendor credential
  handling, device permission UI, notification rendering, background tasks, or
  Matrix v1.18 full ecosystem compliance.
- `SPEC-077` records those excluded Push Gateway API lanes as the
  `houra-server#139` full-breadth gap inventory for the current blocked release
  candidate. It preserves the non-advertisement decision until each lane has
  passing evidence or an explicit release exclusion.
- After `SPEC-060` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if parser-only helpers for
  push notification payloads or pusher data validation are intentionally
  adopted.

Matrix federation interop smoke gate:

- `SPEC-061` defines the Matrix v1.18 federation adoption smoke for two Houra
  homeservers, one Houra plus one reference homeserver, and a Docker Compose or
  Complement-compatible CI lane. It binds `SPEC-055`, `SPEC-056`, and
  `SPEC-057` into runnable evidence.
- Passing this gate does not claim get_missing_events, timestamp lookup, leave,
  knock, third-party invites, federation E2EE EDU handling, policy servers,
  complete Complement coverage, or Matrix v1.18 full federation compliance.
- After `SPEC-061` merges, create an adoption issue for `houra-server`. Do not
  create `houra-client` work unless a later client-visible federation smoke
  surface is intentionally added. Create an `houra-labs` issue only if
  parser-only or room-version-helper adoption is intentionally scoped with
  parity vectors and performance gates.

Matrix room versions gate:

- `SPEC-042` defines the Matrix v1.18 stable room-version allowlist as `1`
  through `12`, requires new rooms to default to room version `12`, and adds
  create-room vectors for default selection and unsupported room-version errors.
- Passing this gate does not claim complete per-version auth/state resolution,
  federation, redaction, or room-upgrade support.
- Room-version support must not be advertised through
  `GET /_matrix/client/versions`. Future capabilities support must advertise
  only versions with implementation evidence.

Matrix room auth representative vectors:

- `SPEC-043` defines representative room version 12 authorization vectors for
  membership joins, power-level validation, creator handling, redaction send
  authorization, and redaction application allow/deny checks.
- Passing this gate does not claim complete Matrix room-version authorization,
  complete state resolution, federation auth-chain validation, or Matrix v1.18
  full compliance.

Matrix room alias, upgrade, and restart persistence gate:

- `SPEC-044` defines representative room alias create/resolve/delete behavior,
  room upgrade records for replacement room and tombstone links, and a restart
  persistence gate covering event graph, state snapshot, room version, alias,
  and upgrade records.
- Passing this gate does not claim full room directory, full room upgrade,
  federation upgrade interop, or Matrix v1.18 full compliance.
- `SPEC-078` records the remaining full-algorithm Room Versions lanes as the
  `houra-server#140` gap inventory for the current blocked release candidate.
  It keeps full auth/state-resolution algorithms and room-version advertisement
  out of the support claim until passing evidence or explicit release exclusion
  exists.
- `SPEC-080` records the independent capabilities advertisement boundary for
  `m.room_versions.default` and `m.room_versions.available`. The current
  representative subset may advertise only room version `12`; stable room
  versions `1` through `11` stay non-advertised until each version has current
  passing implementation evidence.
- `SPEC-079` records the remaining full E2EE Olm & Megolm lanes as the
  `houra-server#141` gap inventory for the current blocked release candidate.
  It keeps full encrypted-room, local crypto, verification, cross-signing,
  secret-storage, key-backup, and device-trust support out of the support claim
  until passing evidence or explicit release exclusion exists.
