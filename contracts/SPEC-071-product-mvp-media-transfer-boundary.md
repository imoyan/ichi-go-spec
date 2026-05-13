# SPEC-071: Product MVP Media Transfer Boundary

Status: draft
Feature profile: media
Canonical: yes

## Purpose

Define the Product MVP next-step boundary for media thumbnails, range requests,
and resumable download before any Houra client or server implementation adds
those flows.

This contract records a fail-closed defer decision. It intentionally does not
add thumbnail endpoints, partial-content responses, resume tokens, cache
metadata, filesystem behavior, preview UI, or encrypted attachment behavior by
itself.

## Scope

This contract is Houra-defined Product MVP planning, with Matrix v1.18 media
references used only to keep boundaries compatible with the existing Matrix
media MVP contract.

The current Product MVP media surface remains metadata upload, metadata read,
and same-origin binary download through `SPEC-020`, plus the Matrix media MVP
upload/download subset through `SPEC-038`. Thumbnails, range requests,
resumable download, URL previews, asynchronous upload creation, remote media
federation, and encrypted attachment metadata remain out of scope until a later
contract and vector set explicitly adopts them.

Encrypted media attachments are intentionally split from this contract. They
must use a separate E2EE-aware boundary because media keys, plaintext bytes,
crypto adapter behavior, and E2EE advertisement evidence have different risks
from thumbnail generation or transfer resume.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#media-repository>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv1mediathumbnailservernamemediaid>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv1mediadownloadservernamemediaid>
- Checked at: 2026-05-13T18:25:00+09:00
- Timezone: Asia/Tokyo

## Current decision

The Product MVP media scope is not widened by this contract.

Servers must not advertise or expose Product MVP thumbnail, range request, or
resumable download behavior as supported unless a later contract defines the
request/response shape, headers, failure behavior, UI surface, security
evidence, and implementation adoption gates.

Clients must fail closed:

- do not render thumbnail preview, download progress, or resume controls as
  Product MVP actions;
- do not add SDK methods for thumbnail request, ranged media request,
  resumable download state, cache metadata, or preview policy until a later
  contract defines them;
- do not infer support from `Accept-Ranges`, `Content-Range`, `ETag`, CDN
  behavior, a server-specific endpoint, or a lab prototype;
- keep the existing media upload/metadata/download flows from `SPEC-020` and
  `SPEC-038` unchanged.

## Boundary split

Future work must be split into issue-sized gates. A later spec may adopt one or
more of these lanes:

1. Thumbnail request/response parsing and preview descriptor shape.
2. HTTP range request and partial-content response behavior.
3. Resumable download state, retry, and completion evidence.
4. Download progress or preview UI surface updates.
5. Remote/federated media behavior, if Product MVP ever owns it.

Encrypted attachment metadata, encrypted content transfer, media-key handling,
and plaintext-cache policy are out of scope for this contract and must remain
in a separate E2EE-aware gate.

## SDK and host ownership

SDK core may own only protocol-shaped helpers after a later contract exists:

- request descriptors;
- response parsers;
- Matrix content URI validation;
- media descriptor parsing;
- `Content-Type`, `Content-Length`, `Content-Range`, `Accept-Ranges`, `ETag`,
  and `If-Range` header parsing;
- public error-envelope mapping.

Host-owned responsibilities remain outside SDK core:

- filesystem paths and storage locations;
- cache policy, storage quota, and eviction;
- retry and resume scheduling;
- background download policy;
- preview rendering and image decoding;
- network reachability policy;
- secure deletion;
- user-facing progress, cancellation, and retry copy.

## Error behavior to define later

A later contract must define public behavior for:

- missing media metadata;
- missing binary content;
- unsupported range requests;
- invalid or unsatisfied range requests;
- stale validators such as `ETag` / `If-Range`;
- partial content whose size or content type conflicts with metadata;
- interruption and resume failure;
- authentication failure for protected media.

Until that contract exists, implementations must not turn those cases into
Product MVP support claims.

## Security and evidence

Future media transfer work must not write these values to logs, issue evidence,
release evidence, screenshots, README examples, or test artifacts:

- bearer tokens;
- signed or credentialed URLs;
- local filesystem paths;
- plaintext media bytes;
- media keys or recovery keys;
- cache filenames that expose user data.

Evidence may record redacted presence flags, byte counts, contract refs,
implementation refs, and clean-room confirmation. It must not record secret
values, local paths, or media payload content.

## Compatibility boundaries

- `SPEC-020` remains the contract for Houra media metadata upload, download
  descriptors, and same-origin binary download.
- `SPEC-038` remains the contract for Matrix media MVP upload and authenticated
  download.
- The Product MVP UI surface remains unchanged by this contract.
- This contract does not define encrypted attachment metadata.
- This contract does not widen `GET /_matrix/client/versions` advertisement.
- This contract does not claim Matrix media repository completeness, encrypted
  attachment support, E2EE support, or Matrix v1.18 full compliance.

## Adoption decision checklist

After this contract merges:

- `houra-client` may cite this boundary to keep thumbnails, range requests, and
  resumable download out of its exported SDK API and Expo Product MVP surface.
- `houra-server` must not add supported public Product MVP behavior for these
  flows without a narrower follow-up contract.
- `houra-labs` may prototype only when the prototype output is clearly
  non-canonical and does not become implementation evidence by itself.
- Future spec work must add contract text, vectors, UI surface updates when UI
  changes, and security evidence requirements before implementation adoption.
