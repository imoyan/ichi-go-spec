# SPEC-095: Matrix Media Repository Breadth

Status: draft
Feature profile: media
Contract type: boundary
Matrix domain: Client-Server API
Canonical: yes

## Purpose

Define the focused Matrix Client-Server media repository parser boundary
promoted from the `SPEC-073` `media-repository-breadth` lane.

This contract lets implementation repositories adopt request descriptors,
metadata response parsers, safe filename helpers, and `mxc://` URI validation
without turning parser evidence into binary transfer support, cache ownership,
thumbnail generation, resumable upload runtime, remote media fetching, encrypted
attachment support, or full Matrix Client-Server API advertisement.

## Scope

This contract covers parser and request-descriptor shape for:

```text
GET  /_matrix/client/v1/media/config
GET  /_matrix/client/v1/media/preview_url
GET  /_matrix/client/v1/media/thumbnail/{serverName}/{mediaId}
POST /_matrix/media/v1/create
PUT  /_matrix/media/v3/upload/{serverName}/{mediaId}
```

Only these public envelopes are adopted:

- request descriptors for media config, URL preview, thumbnail request,
  upload-create metadata, and resumable upload metadata;
- media config responses with `m.upload.size`;
- URL preview responses for `og:*` metadata and image dimensions;
- thumbnail metadata descriptors with parsed `mxc://` output;
- upload-create and upload-resume metadata responses;
- safe `Content-Disposition` filename extraction helpers;
- Matrix error envelopes for malformed or unsupported media metadata.

This contract does not define binary upload/download transfer, byte-range
serving, cache persistence, thumbnail image generation, preview crawling,
federated remote media fetching, resumable upload chunk storage, encrypted
attachment metadata, or a widened Matrix `/versions` advertisement.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#media-repository>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv1mediaconfig>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv1mediapreview_url>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv1mediathumbnailservernamemediaid>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixmediav1create>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#put_matrixmediav3uploadservernamemediaid>
- Parent contract: `SPEC-038`
- Gap inventory: `SPEC-073`
- Checked at: 2026-05-16T07:05:00+09:00
- Timezone: Asia/Tokyo

## Adopted Descriptors

Implementations may expose parser-only descriptors for the adopted media
repository surface. Descriptors must keep query and path variables typed and
bounded:

```json
{
  "id": "media-thumbnail",
  "method": "GET",
  "path": "/_matrix/client/v1/media/thumbnail/{serverName}/{mediaId}",
  "path_params": {
    "serverName": "example.test",
    "mediaId": "media1"
  },
  "query_params": {
    "width": 64,
    "height": 64,
    "method": "scale",
    "timeout_ms": 0,
    "allow_remote": false,
    "animated": false
  },
  "requires_auth": true,
  "adopted_runtime_behavior": false,
  "response_parser": "media_thumbnail_metadata"
}
```

`method` is limited to `scale` or `crop`. Numeric query values must be
non-negative integers. `allow_remote` and `animated` are booleans. Parser-only
adoption must preserve those values without claiming remote fetch, thumbnail
generation, or animated thumbnail support.

## Adopted Response Metadata

Media config parsers may expose:

```json
{
  "m.upload.size": 10485760
}
```

`m.upload.size` is optional and, when present, must be a non-negative integer.

URL preview parsers may preserve public Open Graph-style metadata:

```json
{
  "og:title": "Example",
  "og:description": "Preview text",
  "og:image": "mxc://example.test/preview1",
  "og:image:type": "image/png",
  "matrix:image:size": 12345,
  "og:image:width": 640,
  "og:image:height": 480
}
```

`og:image`, upload-created `content_uri`, thumbnail metadata `content_uri`, and
resumable-upload `content_uri` must use `mxc://{serverName}/{mediaId}`.
`serverName` and `mediaId` must be non-empty. Parsers must not treat the media
ID as a local path, storage key, or URL.

Safe filename helpers may extract a filename from `Content-Disposition` only
when it is free of CR/LF, control characters, path separators, traversal-like
segments, and quotes that would break the adopted MVP quoting policy.

## Fail-Closed Behavior

Implementations must fail closed:

- do not advertise full Client-Server media repository support from these
  descriptors or parsers;
- do not widen `GET /_matrix/client/versions`;
- reject malformed `mxc://` URIs and path-shaped media IDs;
- reject negative media config sizes, preview image sizes, dimensions, and
  thumbnail dimensions;
- reject unsupported thumbnail methods;
- reject malformed `allow_remote`, `animated`, or timeout query values;
- reject unsafe filename values from `Content-Disposition`;
- keep encrypted attachment, binary transfer, cache, remote fetch, and
  resumable upload runtime support unclaimed unless later implementation
  evidence passes.

## Adoption Decision Checklist

After this contract merges:

- `houra-labs#122` may add parser-only helper coverage for the adopted
  descriptors, response metadata, filename safety, and `mxc://` validation.
- Server implementation work requires a separate adoption issue before runtime
  media config behavior, preview crawling, thumbnail generation, remote fetch,
  resumable upload chunking, byte ranges, or cache policy is added.
- Client work is needed only if a public SDK or UI surface intentionally exposes
  these descriptors or parsed metadata.
- Release evidence must keep `advertisement_allowed=false` for Client-Server API
  until the broader `SPEC-073` lanes are resolved for the release.

## Compatibility Boundaries

- `SPEC-020` remains the Houra Product MVP media metadata and content contract.
- `SPEC-038` remains the Matrix media upload/download MVP contract.
- `SPEC-071` remains the Product MVP thumbnail, range, and resumable download
  fail-closed boundary.
- `SPEC-072` remains the encrypted media attachment fail-closed boundary.
- `SPEC-073` remains the Client-Server full-breadth gap inventory.
- Passing this contract does not claim thumbnail generation, preview crawling,
  range support, resumable upload runtime, remote media fetching, encrypted
  media attachment support, or Matrix v1.18 full compliance.
