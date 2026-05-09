# Contract Module Map

| Contract | Feature profile | Matrix domain | Current Matrix alignment | Next compliance action |
|---|---|---|---|---|
| SPEC-001 Discovery / Versions | core | Client-Server API | Houra-only discovery namespace; conceptually nearest to `GET /_matrix/client/versions` | Add Matrix v3 versions contract, response shape, unstable feature advertisement rules, and deprecation gate |
| SPEC-002 Error model | core | Appendices/common rules | Houra error envelope only partially aligns with Matrix `M_*` error vocabulary | Add Matrix error vocabulary, HTTP status mapping, and per-endpoint error vectors |
| SPEC-003 Login flow discovery | auth | Client-Server API | Houra login flow discovery is password-focused and path-incompatible | Add Matrix `GET /_matrix/client/v3/login` flows and v1.18 auth metadata planning |
| SPEC-004 Login/session | auth | Client-Server API | Houra password login/session lifecycle exists, but device/session semantics are incomplete for Matrix | Add Matrix login, registration, logout, whoami, device, token, and OAuth-aware auth contracts |
| SPEC-006 Room model | rooms | Client-Server API; Room Versions | Houra room create/join/leave/state subset lacks Matrix room version auth and power-level semantics | Add Matrix room create/join/leave/state/power-level contracts and room-version-aware state validation |
| SPEC-007 Event model | events | Client-Server API; Room Versions | Houra events are timeline objects, not Matrix event DAG/auth/state events | Add Matrix event envelope, state key, auth events, prev events, redaction, and room-version validation |
| SPEC-008 Send message | messaging | Client-Server API | Houra text send supports idempotency but not Matrix event type/msgtype breadth | Add `PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}` vectors, msgtypes, redactions, and transaction semantics |
| SPEC-009 Room list | sync | Client-Server API | Houra room list is a simple joined-room query, not Matrix sync room membership sections | Add joined/invited/left room sections through `/sync` and room list compatibility vectors |
| SPEC-010 Timeline | sync | Client-Server API | Houra timeline is a simple forward query, not Matrix `/messages` pagination semantics | Add Matrix `/rooms/{roomId}/messages` direction, filter, visibility, and pagination token vectors |
| SPEC-011 Basic sync | sync | Client-Server API | Houra sync is a small incremental update model | Add Matrix `/sync` rooms, account data, presence, to-device, device lists, e2ee hooks, and filter semantics |
| SPEC-020 Media | media | Client-Server API | Houra media covers upload, metadata, and binary download subset | Add Matrix media upload/download/thumbnail endpoint contracts, content URI grammar, and encrypted attachment metadata vectors |
| SPEC-030 Matrix Client Versions | core | Client-Server API | First Matrix compatibility contract; implementation must not advertise unsupported Matrix versions | Implement `GET /_matrix/client/versions` only with matching endpoint evidence and CI coverage |
