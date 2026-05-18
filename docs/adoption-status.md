# Adoption Status Board

This board is a cross-repository adoption index derived from `CONTRACT_MODULE_MAP.md`, `CHANGELOG.md`, and the current contract metadata. It is not conformance proof and does not widen Product MVP or Matrix advertisement claims. Runtime support remains fail-closed until the relevant contract, vector, implementation evidence, and release gate explicitly allow the claim. The board leads with `Primary reference`; `Repository anchor` is retained only for file-path and evidence joins.

Adoption states:

- `adopted`: implementation evidence is already recorded in `CHANGELOG.md` for the covered contract scope.
- `tracked`: an implementation repository issue or pull request is referenced, but the board does not claim release adoption.
- `planned`: no implementation repository reference is recorded yet.
- `blocked`: a gap inventory or release blocker records why advertisement remains fail-closed.
- `evidence-only`: schema or evidence-surface work used by adoption gates, not direct runtime behavior.

| Primary reference | Repository anchor | Contract type | Matrix domain | Server refs | Client refs | Labs refs | Adoption state | Claim impact |
|---|---|---|---|---|---|---|---|---|
| Houra public API / Discovery / Versions | SPEC-001 Discovery / Versions | endpoint | none | `houra-server#2` | `houra-client#2` | - | adopted | Product MVP |
| Houra public API / Error model | SPEC-002 Error model | boundary | none | `houra-server#2` | `houra-client#2` | - | adopted | Product MVP |
| Houra public API / Login flow discovery | SPEC-003 Login flow discovery | endpoint | none | `houra-server#2` | `houra-client#2` | - | adopted | Product MVP |
| Houra public API / Login/session | SPEC-004 Login/session | endpoint | none | `houra-server#2`<br>`houra-server#10` | `houra-client#2`<br>`houra-client#13` | - | adopted | Product MVP |
| Houra public API / Room model | SPEC-006 Room model | endpoint | none | `houra-server#2` | `houra-client#2` | - | adopted | Product MVP |
| Houra public API / Event model | SPEC-007 Event model | boundary | none | `houra-server#2` | `houra-client#2` | - | adopted | Product MVP |
| Houra public API / Send message | SPEC-008 Send message | endpoint | none | `houra-server#2` | `houra-client#2` | - | adopted | Product MVP |
| Houra public API / Room list | SPEC-009 Room list | endpoint | none | `houra-server#2` | `houra-client#2` | - | adopted | Product MVP |
| Houra public API / Timeline | SPEC-010 Timeline | endpoint | none | `houra-server#2` | `houra-client#2` | - | adopted | Product MVP |
| Houra public API / Basic sync | SPEC-011 Basic sync | endpoint | none | `houra-server#2` | `houra-client#2` | - | adopted | Product MVP |
| Houra public API / Media | SPEC-020 Media | endpoint | none | `houra-server#2`<br>`houra-server#8` | `houra-client#2`<br>`houra-client#11` | - | adopted | Product MVP |
| Matrix v1.18 / Client-Server API / GET /_matrix/client/versions | SPEC-030 Matrix Client Versions | endpoint | Client-Server API | `houra-server#22` | `houra-client#34` | - | adopted | Matrix |
| Matrix v1.18 / Appendices/common rules / identifiers, timestamps, namespacing, errors, and content URIs | SPEC-031 Matrix Foundation Common Rules | boundary | Appendices/common rules | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / login, logout, and whoami endpoints | SPEC-032 Matrix Client-Server Auth Session | endpoint | Client-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / registration and username availability endpoints | SPEC-033 Matrix Client-Server Registration | endpoint | Client-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / device management and session lifecycle endpoints | SPEC-034 Matrix Client-Server Devices and Sessions | endpoint | Client-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / POST /_matrix/client/v3/keys/query | SPEC-069 Matrix Device Key Query | boundary | Client-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / create, join, leave, and room state endpoints | SPEC-035 Matrix Client-Server Room Membership and State MVP | endpoint | Client-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / send event and messages pagination endpoints | SPEC-036 Matrix Client-Server Send Event and Messages MVP | endpoint | Client-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / GET /_matrix/client/v3/sync | SPEC-037 Matrix Client-Server Sync MVP | endpoint | Client-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / media upload and download endpoints | SPEC-038 Matrix Client-Server Media MVP | endpoint | Client-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / Client-Server endpoint smoke gate | SPEC-039 Matrix Client-Server MVP Live E2E Gate | gate | Client-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Room Versions / Matrix Event DAG and Auth Event References | SPEC-040 Matrix Event DAG and Auth Event References | boundary | Room Versions | - | - | - | planned | Matrix |
| Matrix v1.18 / Room Versions / Matrix State Snapshot and State Resolution Vectors | SPEC-041 Matrix State Snapshot and State Resolution Vectors | boundary | Room Versions | - | - | - | planned | Matrix |
| Matrix v1.18 / Room Versions / Matrix Room Versions 1-12 and Default Version Gate | SPEC-042 Matrix Room Versions 1-12 and Default Version Gate | gate | Room Versions | - | - | - | planned | Matrix |
| Matrix v1.18 / Room Versions / Matrix Room Auth Representative Vectors | SPEC-043 Matrix Room Auth Representative Vectors | boundary | Room Versions | - | - | - | planned | Matrix |
| Matrix v1.18 / Room Versions / Matrix Room Alias, Upgrade, and Restart Persistence Gate | SPEC-044 Matrix Room Alias, Upgrade, and Restart Persistence Gate | gate | Room Versions | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / profile, account data, and room tag endpoints | SPEC-045 Matrix Profile, Account Data, and Room Tags | endpoint | Client-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / typing, receipt, and read marker endpoints | SPEC-046 Matrix Receipts, Typing, and Read Markers | endpoint | Client-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / filter, presence, and capabilities endpoints | SPEC-047 Matrix Filters, Presence, and Capabilities | endpoint | Client-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / public rooms, directory aliases, and invites | SPEC-048 Matrix Room Directory, Aliases, and Invites | endpoint | Client-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / room moderation, redaction, reporting, and admin endpoints | SPEC-049 Matrix Moderation, Reporting, and Admin Controls | endpoint | Client-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / end-to-end encryption client integration boundary | SPEC-050 Matrix Crypto Adapter Boundary | boundary | Client-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / key upload and key claim endpoints | SPEC-051 Matrix Device, One-Time, and Fallback Keys | endpoint | Client-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / to-device messages and encrypted room event envelopes | SPEC-052 Matrix To-Device and Encrypted Room Gate | gate | Client-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / server-side key backup endpoints | SPEC-053 Matrix Key Backup and Restore Gate | gate | Client-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / verification and cross-signing endpoints | SPEC-054 Matrix Verification and Cross-Signing Gate | gate | Client-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Server-Server API / server discovery and signing key endpoints | SPEC-055 Matrix Federation Discovery and Signing Keys | endpoint | Server-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Server-Server API / federation send, join, and invite endpoints | SPEC-056 Matrix Federation Transaction, Join, and Invite | endpoint | Server-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Server-Server API / backfill, event auth, state, and state_ids endpoints | SPEC-057 Matrix Federation Backfill, Event Auth, and State Interop | endpoint | Server-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Application Service API / registration and username availability endpoints | SPEC-058 Matrix Application Service Registration and Transaction | endpoint | Application Service API | - | - | - | planned | Matrix |
| Matrix v1.18 / Identity Service API / identity lookup, validation, bind, and unbind endpoints | SPEC-059 Matrix Identity Service Boundary | endpoint | Identity Service API | - | - | - | planned | Matrix |
| Matrix v1.18 / Push Gateway API / POST /_matrix/push/v1/notify | SPEC-060 Matrix Push Gateway Boundary | endpoint | Push Gateway API | - | - | - | planned | Matrix |
| Matrix v1.18 / Server-Server API / federation interop smoke gate | SPEC-061 Matrix Federation Interop Smoke | gate | Server-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Appendices/common rules / domain coverage evidence report | SPEC-062 Matrix Domain Coverage Evidence Report | schema | Appendices/common rules | - | - | - | evidence-only | Matrix |
| Matrix v1.18 / Appendices/common rules / Complement-compatible homeserver CI lane | SPEC-063 Matrix Complement-Compatible CI Lane | gate | Appendices/common rules | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / version advertisement release gate | SPEC-064 Matrix Version Advertisement Release Gate | gate | Client-Server API | - | - | - | planned | Matrix |
| Matrix v1.18 / Appendices/common rules / release notes evidence template | SPEC-065 Matrix Release Notes Evidence Template | schema | Appendices/common rules | - | - | - | evidence-only | Matrix |
| Matrix v1.18 / Appendices/common rules / v1.18 release readiness gate | SPEC-066 Matrix v1.18 Release Readiness Gate | gate | Appendices/common rules | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / OAuth account management and device deletion flows | SPEC-068 Matrix OAuth Account Management and Device Deletion Flow | endpoint | Client-Server API | - | - | - | planned | Matrix |
| Houra Product MVP / Account Recovery and IdP Login Boundary | SPEC-070 Product MVP Account Recovery and IdP Login Boundary | boundary | none | - | - | - | planned | Product MVP |
| Houra Product MVP / Media Transfer Boundary | SPEC-071 Product MVP Media Transfer Boundary | boundary | none | - | - | - | planned | Product MVP |
| Houra Product MVP / Encrypted Media Attachment Boundary | SPEC-072 Product MVP Encrypted Media Attachment Boundary | boundary | none | - | - | - | planned | Product MVP |
| Matrix v1.18 / Client-Server API / full-breadth gap inventory | SPEC-073 Matrix Client-Server Full-Breadth Gap Inventory | gap-inventory | Client-Server API | `houra-server#135`<br>`houra-server#178`<br>`houra-server#184` | - | - | blocked | Matrix |
| Matrix v1.18 / Server-Server API / full-breadth gap inventory | SPEC-074 Matrix Server-Server Full-Breadth Gap Inventory | gap-inventory | Server-Server API | `houra-server#136` | - | - | blocked | Matrix |
| Matrix v1.18 / Application Service API / full-breadth gap inventory | SPEC-075 Matrix Application Service Full-Breadth Gap Inventory | gap-inventory | Application Service API | `houra-server#137` | - | - | blocked | Matrix |
| Matrix v1.18 / Identity Service API / full-breadth gap inventory | SPEC-076 Matrix Identity Service Full-Breadth Gap Inventory | gap-inventory | Identity Service API | `houra-server#138` | - | - | blocked | Matrix |
| Matrix v1.18 / Push Gateway API / full-breadth gap inventory | SPEC-077 Matrix Push Gateway Full-Breadth Gap Inventory | gap-inventory | Push Gateway API | `houra-server#139` | - | - | blocked | Matrix |
| Matrix v1.18 / Room Versions / full-algorithm gap inventory | SPEC-078 Matrix Room Versions Full Algorithm Gap Inventory | gap-inventory | Room Versions | `houra-server#140` | - | - | blocked | Matrix |
| Matrix v1.18 / Olm & Megolm / full E2EE gap inventory | SPEC-079 Matrix Olm and Megolm Full E2EE Gap Inventory | gap-inventory | Olm & Megolm | `houra-server#141` | - | - | blocked | Matrix |
| Matrix v1.18 / Room Versions / room versions capabilities advertisement | SPEC-080 Matrix Room Versions Capabilities Advertisement Boundary | boundary | Room Versions | - | - | - | planned | Matrix |
| Matrix v1.18 / Olm & Megolm / maintained crypto stack and storage ownership | SPEC-081 Matrix Maintained Crypto Stack and Storage Ownership Boundary | boundary | Olm & Megolm | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / .well-known client, support, and policy metadata | SPEC-082 Matrix Client Well-Known Discovery, Support, and Policy Boundary | boundary | Client-Server API | `houra-server#229` | - | - | tracked | Matrix |
| Matrix v1.18 / Room Versions / room version event decision artifacts | SPEC-083 Matrix Room Version Event Decision Artifacts | boundary | Room Versions | `houra-server#250` | - | - | tracked | Matrix |
| Matrix v1.18 / Room Versions / room-version-aware federation validation | SPEC-084 Matrix Room Version Federation Cross-Domain Validation | boundary | Room Versions | `houra-server#251` | - | - | tracked | Matrix |
| Matrix v1.18 / Client-Server API / event retrieval and membership history endpoints | SPEC-085 Matrix Client-Server Event Retrieval and Membership History | boundary | Client-Server API | - | - | `houra-labs#119` | tracked | Matrix |
| Matrix v1.18 / Push Gateway API / push payload minimization | SPEC-086 Matrix Push Payload Minimization Boundary | boundary | Push Gateway API | `houra-server#247` | - | - | tracked | Matrix |
| Matrix v1.18 / Client-Server API / relations, threads, and reactions endpoints | SPEC-090 Matrix Client-Server Relations, Threads, and Reactions | boundary | Client-Server API | - | - | `houra-labs#120` | tracked | Matrix |
| Matrix v1.18 / Push Gateway API / push notify payload and gateway endpoint | SPEC-091 Matrix Push Notify Payload and Gateway Endpoint Boundary | boundary | Push Gateway API | `houra-server#246` | - | - | tracked | Matrix |
| Matrix v1.18 / Identity Service API / bind and unbind lifecycle endpoints | SPEC-092 Matrix Identity Bind and Unbind Lifecycle Boundary | boundary | Identity Service API | `houra-server#245` | - | - | tracked | Matrix |
| Matrix v1.18 / Client-Server API / sync query and response sections | SPEC-093 Matrix Sync Breadth Extensions | boundary | Client-Server API | - | - | `houra-labs#121` | tracked | Matrix |
| Matrix v1.18 / Identity Service API / validation provider delivery flows | SPEC-094 Matrix Identity Validation Provider Delivery Boundary | boundary | Identity Service API | `houra-server#244` | - | - | tracked | Matrix |
| Matrix v1.18 / Client-Server API / media repository endpoint breadth | SPEC-095 Matrix Media Repository Breadth | boundary | Client-Server API | - | - | `houra-labs#122` | tracked | Matrix |
| Matrix v1.18 / Identity Service API / identity public key and signature validation | SPEC-096 Matrix Identity Public Key and Signature Boundary | boundary | Identity Service API | `houra-server#242` | - | - | tracked | Matrix |
| Matrix v1.18 / Server-Server API / federation version, key lifecycle, and request auth | SPEC-097 Matrix Federation Version, Key Lifecycle, and Request Auth | boundary | Server-Server API | - | - | `houra-labs#123` | tracked | Matrix |
| Matrix v1.18 / Push Gateway API / pusher, push rule, and redaction parser helpers | SPEC-098 Matrix Push Parser Helper Breadth | boundary | Push Gateway API | - | - | `houra-labs#128` | tracked | Matrix |
| Matrix v1.18 / Server-Server API / federation transaction PDU and EDU parser helpers | SPEC-099 Matrix Federation PDU / EDU Parser Helpers | boundary | Server-Server API | - | - | `houra-labs#124` | tracked | Matrix |
| Matrix v1.18 / Server-Server API / public rooms, hierarchy, directory query, and OpenID endpoints | SPEC-100 Matrix Federation Directory / Query / OpenID Parser Helpers | boundary | Server-Server API | - | - | `houra-labs#125` | tracked | Matrix |
| Matrix v1.18 / Room Versions / room version auth rule fixture runner | SPEC-101 Matrix Room Version Auth Rule Fixture Runner | boundary | Room Versions | - | - | `houra-labs#130` | tracked | Matrix |
| Matrix v1.18 / Olm & Megolm / encrypted event, key, backup, verification, and cross-signing artifacts | SPEC-102 Matrix E2EE Parser Artifact Breadth | boundary | Olm & Megolm | - | - | `houra-labs#132` | tracked | Matrix |
| Matrix v1.18 / Room Versions / event format, hash, signature, and redaction rules | SPEC-103 Matrix Room Version Event Format, Hash, and Signature Helpers | boundary | Room Versions | - | - | `houra-labs#129` | tracked | Matrix |
| Matrix v1.18 / Room Versions / state resolution fixture runner | SPEC-104 Matrix Room Version State Resolution Fixture Runner | boundary | Room Versions | - | - | `houra-labs#131` | tracked | Matrix |
| Matrix v1.18 / Application Service API / appservice parser artifact breadth | SPEC-105 Matrix Application Service Parser Artifact Breadth | boundary | Application Service API | - | - | `houra-labs#126` | tracked | Matrix |
| Matrix v1.18 / Identity Service API / identity service parser artifact breadth | SPEC-106 Matrix Identity Service Parser Artifact Breadth | boundary | Identity Service API | - | - | `houra-labs#127` | tracked | Matrix |
| Matrix v1.18 / Server-Server API / federation transaction event validation | SPEC-107 Matrix Federation Transaction Event Validation Runtime | boundary | Server-Server API | `houra-server#231` | - | - | tracked | Matrix |
| Matrix v1.18 / Server-Server API / federation directory, query, and OpenID runtime | SPEC-108 Matrix Federation Directory, Query, and OpenID Runtime | boundary | Server-Server API | `houra-server#232` | - | - | tracked | Matrix |
| Matrix v1.18 / Server-Server API / federation E2EE device and media runtime | SPEC-109 Matrix Federation E2EE Device and Media Runtime | boundary | Server-Server API | `houra-server#233` | - | - | tracked | Matrix |
| Matrix v1.18 / Server-Server API / federation ACL, policy, and signing runtime | SPEC-110 Matrix Federation ACL, Policy, and Signing Runtime | boundary | Server-Server API | `houra-server#234` | - | - | tracked | Matrix |
| Matrix v1.18 / Server-Server API / federation leave and knock runtime | SPEC-111 Matrix Federation Leave and Knock Runtime | boundary | Server-Server API | `houra-server#158` | - | - | tracked | Matrix |
| Matrix v1.18 / Server-Server API / federation event retrieval runtime | SPEC-112 Matrix Federation Event Retrieval Runtime | boundary | Server-Server API | `houra-server#159` | - | - | tracked | Matrix |
| Matrix v1.18 / Appendices/common rules / conformance tooling result schema | SPEC-113 Conformance Tooling Result Schema | schema | Appendices/common rules | - | - | - | evidence-only | neither |
| Matrix v1.18 / Appendices/common rules / shared-core adoption evidence schema | SPEC-114 Shared-Core Adoption Evidence Schema | schema | Appendices/common rules | - | - | - | evidence-only | neither |
| Matrix v1.18 / Application Service API / appservice masquerade and timestamp runtime | SPEC-115 Matrix Application Service Masquerade and Timestamp Runtime | boundary | Application Service API | `houra-server#238` | - | - | tracked | Matrix |
| Matrix v1.18 / Application Service API / appservice virtual user sync, directory, and device runtime | SPEC-116 Matrix Application Service Virtual User Directory and Device Runtime | boundary | Application Service API | `houra-server#239` | - | - | tracked | Matrix |
| Matrix v1.18 / Application Service API / appservice third-party network directory endpoints | SPEC-117 Matrix Application Service Third-Party Network Directory Breadth | boundary | Application Service API | - | - | `houra-labs#134` | tracked | Matrix |
| Matrix v1.18 / Application Service API / appservice ping liveness endpoints | SPEC-118 Matrix Application Service Ping Liveness Breadth | boundary | Application Service API | `houra-server#256` | - | - | tracked | Matrix |
| Matrix v1.18 / Application Service API / appservice Client-Server extension sync and device endpoints | SPEC-120 Matrix Application Service CS Extension Sync Device Breadth | boundary | Application Service API | - | - | `houra-labs#135` | tracked | Matrix |
| Matrix v1.18 / Application Service API / appservice bridge security and observability evidence | SPEC-121 Matrix Application Service Bridge Security Observability Breadth | boundary | Application Service API | - | - | - | planned | Matrix |
| Matrix v1.18 / Client-Server API / login token, refresh, and account deactivation endpoints | SPEC-122 Matrix Client-Server Auth Refresh Fallback Account Lifecycle | endpoint | Client-Server API | `houra-server#252` | - | `houra-labs#133` | tracked | Matrix |
| Matrix v1.18 / Application Service API / registration and username availability endpoints | SPEC-123 Matrix Application Service Registration Namespace Lifecycle Runtime | boundary | Application Service API | `houra-server#253` | - | - | tracked | Matrix |
| Matrix v1.18 / Application Service API / appservice transaction event delivery runtime | SPEC-124 Matrix Application Service Transaction Event Delivery Runtime | boundary | Application Service API | `houra-server#254` | - | - | tracked | Matrix |
| Matrix v1.18 / Application Service API / appservice user and room alias query runtime | SPEC-125 Matrix Application Service Query User Room Namespace Runtime | boundary | Application Service API | `houra-server#255` | - | - | tracked | Matrix |
| Houra Product MVP / Role Projection Boundary | SPEC-126 Product MVP Role Projection Boundary | boundary | none | `houra-server#337` | - | - | tracked | Product MVP |
| Houra Product MVP / PII Redaction Handoff Boundary | SPEC-127 Product MVP PII Redaction Handoff Boundary | boundary | none | `houra-server#340` | - | - | tracked | Product MVP |
| Houra Product MVP / Multilingual Handoff Boundary | SPEC-128 Product MVP Multilingual Handoff Boundary | boundary | none | `houra-server#339` | - | - | tracked | Product MVP |
| Houra Product MVP / Offline Queue Replay Boundary | SPEC-129 Product MVP Offline Queue Replay Boundary | boundary | none | `houra-server#338` | - | - | tracked | Product MVP |
| Matrix v1.18 / Olm & Megolm / Olm and Megolm to-device key event relay | SPEC-130 Matrix Olm Withheld-Key To-Device Relay Boundary | boundary | Olm & Megolm | `houra-server#252` | - | - | tracked | Matrix |
| Matrix v1.18 / Appendices/common rules / changelog delta boundary | SPEC-131 Matrix v1.18 Changelog Delta Boundary | gap-inventory | Appendices/common rules | - | - | - | tracked | Matrix |
| Houra Product MVP / Platform-native Adapter Policy | SPEC-132 Product MVP Platform-native Adapter Policy | boundary | none | - | - | - | planned | Product MVP |
| Matrix v1.18 / Appendices/common rules / Matrix 2.0 snapshot / v1.18 diff checklist | SPEC-133 Matrix 2.0 Snapshot and v1.18 Diff Checklist | gap-inventory | Appendices/common rules | - | - | - | tracked | Matrix |
| Matrix v1.18 / Client-Server API / Matrix 2.0 versions advertisement evidence gate | SPEC-134 Matrix 2.0 Versions Advertisement Evidence Gate | gate | Client-Server API | - | - | - | blocked | Matrix |

The board intentionally keeps implementation references lightweight. Detailed release evidence stays in `CHANGELOG.md`, and open roadmap or exclusion reasoning stays in `docs/matrix-compliance.md`.

Product MVP feature-addition candidate review for the next release candidate is
tracked in `imoyan/houra-spec#366` and
`test-vectors/core/product-mvp-release-candidate-plan.json`. Closed
implementation refs in this board remain adoption pointers until that candidate
review records current refs, commands, pass/fail results, redaction checks, and
claim boundaries. Capability-gated vNext flows and server-owned Product MVP
boundaries stay fail-closed when that evidence is missing or stale.
