# SPEC-071: Product MVP Media Transfer Boundary

Status: draft
Feature profile: media
Canonical: yes

## Purpose

Define the Product MVP next-step boundary for media thumbnails, range requests,
and resumable download before any Houra client or server implementation adds
those flows.

This contract keeps the current Product MVP release candidate fail-closed, but
it also defines optional Product MVP vNext lanes that implementations may adopt
after the matching vectors, UI surface evidence, and implementation adoption
gates pass.

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

## Current release decision

The current Product MVP media baseline is not widened by this contract.
Metadata upload, metadata read, and same-origin binary download from `SPEC-020`
remain the only required Houra Product MVP media behavior.

Servers must not advertise or expose Product MVP thumbnail, range request, or
resumable download behavior as supported unless the matching optional lane
below is implemented and adoption evidence names the `houra-spec`,
implementation, UI surface, and verification refs.

Clients must fail closed:

- do not render thumbnail preview, download progress, or resume controls as
  Product MVP actions unless media metadata advertises the matching lane;
- do not call thumbnail, ranged media, or resumable download behavior unless
  media metadata advertises the matching lane;
- do not infer support from `Accept-Ranges`, `Content-Range`, `ETag`, CDN
  behavior, a server-specific endpoint, or a lab prototype;
- keep the existing media upload/metadata/download flows from `SPEC-020` and
  `SPEC-038` unchanged.

## Media transfer capability metadata

Product MVP vNext media transfer support is discovered through the existing
Houra metadata response from `SPEC-020`. A server that supports vNext lanes may
add a `transfer` object:

```json
{
  "media_id": "media1",
  "filename": "avatar.png",
  "content_type": "image/png",
  "download_url": "https://example.test/_houra/client/media/media1/content",
  "download_requires_auth": false,
  "download_expires_at": "2030-01-01T00:00:00Z",
  "transfer": {
    "thumbnail": {
      "supported": true,
      "url": "https://example.test/_houra/client/media/media1/thumbnail",
      "methods": ["crop", "scale"],
      "max_width": 1024,
      "max_height": 1024
    },
    "byte_ranges": {
      "supported": true,
      "unit": "bytes",
      "etag": "\"media1-v1\"",
      "content_length": 5
    },
    "resumable_download": {
      "supported": true,
      "validator": "etag",
      "max_resume_window_ms": 3600000
    }
  }
}
```

If a lane is missing or has `supported: false`, clients must hide or disable the
matching Product MVP action and must not probe server-specific endpoints. The
`transfer` object describes public behavior only; it must not reveal object
storage keys, cache filenames, local paths, CDN credentials, signed URLs, or
encrypted attachment keys.

## Thumbnail lane

Thumbnail requests are authenticated exactly like the media content descriptor
requires. If the latest metadata has `download_requires_auth: true`, clients
must send `Authorization: Bearer`. If it is `false`, clients must not send
bearer-token authorization.

```text
GET /_houra/client/media/{media_id}/thumbnail?width=64&height=64&method=scale
```

`width` and `height` must be positive integers no greater than the advertised
maximums. `method` is either `crop` or `scale`. Servers should return the
thumbnail bytes with `Content-Type` matching the generated thumbnail payload.

```text
HTTP/1.1 200 OK
Content-Type: image/png
Content-Length: 5
Cache-Control: private, max-age=3600
ETag: "media1-thumb-64"
```

The response body is raw thumbnail bytes. This contract does not require image
format conversion, preview crawling, animated preview behavior, or remote media
fetching.

## Range request lane

Range requests reuse the `download_url` from `SPEC-020`. Clients may send one
single-byte range after metadata advertises `byte_ranges.supported: true`.
Multi-range requests are out of scope.

```text
GET /_houra/client/media/{media_id}/content
Range: bytes=0-2
If-Range: "media1-v1"
```

Successful partial content returns `206`:

```text
HTTP/1.1 206 Partial Content
Content-Type: image/png
Content-Length: 3
Content-Range: bytes 0-2/5
Accept-Ranges: bytes
ETag: "media1-v1"
```

The response body is the requested raw byte range. If the range is syntactically
invalid or unsatisfied, servers should return `416` with `HOURA_BAD_REQUEST`
and must not return partial bytes.

## Resumable download lane

Resumable download is a host-owned retry flow built from metadata refresh,
`ETag` or equivalent validator checks, and single-range requests. SDK core may
own request descriptors and response parsers; hosts own storage, partial-file
tracking, retry scheduling, cancellation, and cleanup.

A client may resume only when:

- latest metadata still advertises `resumable_download.supported: true`;
- the stored validator matches the latest `byte_ranges.etag`;
- the host has a known downloaded byte count; and
- the next request is a single range beginning at the known byte count.

If the validator is stale, metadata is missing, or the partial content response
does not match the requested range and total size, clients must discard the
partial resume state and restart a normal download after user-visible recovery.

## Progress and UI expectations

Download progress is derived from public `Content-Length`, `Content-Range`, and
metadata `transfer.byte_ranges.content_length` values. UI evidence must show
duplicate-submit prevention, visible progress or retry state, recoverable error
visibility, and redaction of local paths, signed URLs, tokens, and media bytes.

Progress UI must not turn a cache policy, filesystem path, or background
download behavior into a Product MVP contract.

## Boundary split

Further work must stay split into issue-sized gates. Later specs may refine one
or more of these lanes:

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

## Error behavior

Implementations that adopt the optional lanes must use these public failures:

- missing media metadata;
- missing binary content;
- unsupported range requests;
- invalid or unsatisfied range requests;
- stale validators such as `ETag` / `If-Range`;
- partial content whose size or content type conflicts with metadata;
- interruption and resume failure;
- authentication failure for protected media.

Missing metadata and missing binary content remain `404` with
`HOURA_NOT_FOUND`. Missing or rejected bearer tokens for protected media remain
`401` with `HOURA_UNAUTHORIZED`. Malformed thumbnail parameters, unsupported
range units, multi-range requests, unsatisfied ranges, stale validators, and
partial content metadata mismatches should fail with `HOURA_BAD_REQUEST` and a
status appropriate to the request phase, such as `400` or `416`.

Clients must preserve recoverable error visibility without deleting the host's
saved media file, partial download state, or retry controls unless the host
explicitly chooses that cleanup policy.

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
- Product MVP vNext media transfer UI actions are optional and must remain
  hidden unless matching metadata capabilities are advertised and adoption
  evidence is recorded.
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
