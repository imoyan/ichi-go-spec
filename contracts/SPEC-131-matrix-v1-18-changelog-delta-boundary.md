# Matrix v1.18 / Appendices/common rules / changelog delta boundary

Status: draft
Feature profile: core
Contract type: gap-inventory
Matrix domain: Appendices/common rules
Primary reference: Matrix v1.18 / Appendices/common rules / changelog delta boundary
Repository anchor: SPEC-131 Matrix v1.18 Changelog Delta Boundary
Canonical: yes

## Purpose

Record the Matrix v1.18 changelog deltas that were not explicitly named by the
current Houra Matrix roadmap close-out snapshot.

This contract keeps those deltas visible without turning them into runtime
support or a Matrix v1.18 advertisement claim. It is a fail-closed bridge
between the official Matrix release notes, the existing domain gap inventories,
and future focused contracts or implementation issues.

## Scope

This boundary covers the following v1.18 deltas:

- `M_USER_LIMIT_EXCEEDED` common error handling;
- `m.recent_emoji` account-data handling;
- invite blocking and `M_INVITE_BLOCKED`;
- media and rich-text presentation metadata, including `is_animated` and HTML
  ordered-list `start`;
- Identity Service `submitToken` incorrect-token behavior and
  `M_TOKEN_INCORRECT`.

Each delta must stay linked to its owning Matrix domain and parent issue:

| Delta | Owning domain | Parent issue | Current classification |
|---|---|---|---|
| `M_USER_LIMIT_EXCEEDED` | Client-Server API / Appendices common error vocabulary | imoyan/houra-spec#369 | parser-only error vocabulary boundary until an implementation quota surface is scoped |
| `m.recent_emoji` | Client-Server API account data | imoyan/houra-spec#370 | bounded account-data runtime slice; generic storage does not imply UI or sync-rendering correctness |
| invite blocking / `M_INVITE_BLOCKED` | Client-Server API and Server-Server API | imoyan/houra-spec#371 | Client-Server blocked-invite error/sync boundary; federation policy runtime remains fail-closed |
| `is_animated` and HTML `ol start` | Client-Server API media/message presentation | imoyan/houra-spec#372 | parser/client-rendering descriptor boundary; no media playback or rich-text conformance claim |
| Identity `submitToken` / `M_TOKEN_INCORRECT` | Identity Service API | imoyan/houra-spec#373 | Identity validation runtime boundary; provider delivery and advertisement remain fail-closed |

## Matrix Reference

- Matrix specification version: `v1.18`
- Release note: <https://matrix.org/blog/2026/03/26/matrix-v1.18-release/>
- Client-Server API source: <https://spec.matrix.org/v1.18/client-server-api/>
- Server-Server API source: <https://spec.matrix.org/v1.18/server-server-api/>
- Identity Service API source:
  <https://spec.matrix.org/v1.18/identity-service-api/>
- Checked at: 2026-05-18T11:06:30+09:00
- Timezone: Asia/Tokyo

## Delta Boundaries

`M_USER_LIMIT_EXCEEDED` belongs to public Matrix error vocabulary handling.
Implementations may parse and preserve the error code in Matrix error
envelopes, but must not emit it from generic rate limiting or authorization
failures unless a quota or account-limit runtime contract defines that surface.
`M_LIMIT_EXCEEDED` remains the request-rate or retry-style limit error;
`M_FORBIDDEN` remains the permission failure error.

`m.recent_emoji` belongs to Client-Server account data. Generic account-data
storage may round-trip the event when the storage contract already allows
global account data and validates the v1.18 shape, but that is not enough to claim
`m.recent_emoji` UI ordering, emoji validation, sync rendering, or product
composer behavior. Those must be split into explicit server/client adoption
evidence before they affect a release claim.

Invite blocking belongs to both Client-Server invite behavior and Server-Server
invite handling. `M_INVITE_BLOCKED` must be parsed as a distinct Matrix error
code and must not be collapsed into `M_FORBIDDEN` in public Matrix-facing
evidence. Client-Server blocked invite responses must also suppress the blocked
room from the invitee's `/sync` invite section. Federation invite propagation,
broader policy evaluation, blocklist ownership, and audit artifacts remain out
of scope until server adoption is explicitly opened.

Media and rich-text presentation deltas are client-visible metadata
boundaries. `is_animated` may be parsed on `m.image` and `m.sticker` info
objects, but parsing the flag does not claim animation playback, thumbnail
generation, encrypted media handling, remote media fetch, or media repository
breadth. HTML ordered-list `start` belongs to client rendering evidence only
when a client already supports Matrix-formatted HTML and the `ol` element.

Identity Service `submitToken` incorrect-token behavior belongs to the
validation/provider-delivery lane. `M_TOKEN_INCORRECT` must be preserved as a
specific Matrix error code for email and MSISDN submit-token attempts. Expired
sessions must use `M_SESSION_EXPIRED`; malformed token payloads must use
`M_INVALID_PARAM`. Optional `submit_url` handling must remain a public
response-field parser boundary. Provider delivery, token issuance, token
storage, consent UI, retry policy, and external email/SMS operations remain out
of scope.

## Fail-Closed Behavior

Implementations must fail closed:

- do not widen `GET /_matrix/client/versions`;
- do not advertise Matrix v1.18, Client-Server API, Server-Server API, or
  Identity Service API support from this inventory;
- do not infer runtime support from parser-only or descriptor-only evidence;
- keep each delta tied to a parent issue and owning domain before opening
  implementation adoption work;
- require release notes and release-bundle evidence before any delta affects a
  publishable Matrix support claim.

## Adoption Decision Checklist

After this contract merges:

- #369 through #373 may cite `SPEC-131` as the first explicit contract/vector
  inventory for the detailed Matrix v1.18 changelog-delta audit.
- Future server, client, or labs work should split by the owning domain in the
  table above, not by this cross-domain inventory as a runtime unit.
- Release evidence must keep `advertisement_allowed=false` until the owning
  domain gate has same-candidate pass evidence and matching release notes.

## Compatibility Boundaries

- `SPEC-031` remains the Matrix foundation and error-envelope boundary.
- `SPEC-036`, `SPEC-045`, `SPEC-048`, `SPEC-049`, `SPEC-073`, and `SPEC-095`
  remain the relevant Client-Server parent boundaries.
- `SPEC-056` and `SPEC-074` remain the federation invite parent boundaries.
- `SPEC-076`, `SPEC-094`, and `SPEC-106` remain the Identity Service parent
  boundaries.
- Passing this contract does not claim Matrix v1.18 full compliance or change
  the current blocked release bundle.
