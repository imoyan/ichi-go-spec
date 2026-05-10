# SPEC-038: Matrix Client-Server Media MVP

Status: draft
Feature profile: media
Canonical: yes

## Purpose

Define the Matrix v1.18 Client-Server media upload and download surface closest
to the existing Houra Product MVP media flow.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds `/_matrix/**` media
behavior without changing the existing `/_houra/client/media/**` upload,
metadata, or binary download routes from `SPEC-020`.

This is an MVP-equivalent media contract. It covers authenticated raw-byte
upload, Matrix Content URI return shape, authenticated download by `mxc://`
authority/path components, the filename download variant, required download
headers, and representative Matrix auth/not-found/size errors. It does not
define thumbnails, URL previews, asynchronous upload creation, remote media
federation, range requests, encrypted attachment metadata, or unauthenticated
deprecated media download behavior.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixmediav3upload>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv1mediadownloadservernamemediaid>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv1mediadownloadservernamemediaidfilename>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#matrix-content-mxc-uris>
- Checked at: 2026-05-10T13:13:59+09:00
- Timezone: Asia/Tokyo

## Upload request

```text
POST /_matrix/media/v3/upload?filename=avatar.png
Authorization: Bearer token-1
Content-Type: image/png
```

The request body is the raw media byte stream. The `filename` query parameter is
optional. `Content-Type` is optional in Matrix v1.18 and defaults to
`application/octet-stream` when omitted, but clients should still supply it when
known.

Servers must not require clients to put access tokens in query parameters.

## Upload response

A successful upload returns `200` with a Matrix Content URI:

```json
{
  "content_uri": "mxc://example.test/media1"
}
```

`content_uri` must use the `mxc://{serverName}/{mediaId}` form. `serverName`
is the Matrix server name that owns the media object. `mediaId` is an opaque
non-empty path component selected by the server.

## Download request

```text
GET /_matrix/client/v1/media/download/example.test/media1
Authorization: Bearer token-1
```

The `{serverName}` path segment is the authority component of the `mxc://` URI
and `{mediaId}` is the path component. The filename variant:

```text
GET /_matrix/client/v1/media/download/example.test/media1/avatar.png
Authorization: Bearer token-1
```

returns the same bytes but must use the supplied path filename in
`Content-Disposition`.

`timeout_ms`, when present, is the maximum number of milliseconds the client is
willing to wait for media that is not yet available. The MVP vectors do not
exercise delayed media availability.

## Download response

Successful download returns the raw media byte stream and must include:

- `Content-Type`: the original upload content type or a Matrix-permitted
  reasonable equivalent.
- `Content-Disposition`: `inline` or `attachment`. When the media was uploaded
  with a filename, the header must contain that filename. For the filename
  variant, the header must contain the filename from the download path.

The MVP vectors use `media1` as local media with bytes represented by base64
`aGVsbG8=`, `Content-Type: image/png`, and `Content-Disposition:
inline; filename="avatar.png"`.

## Authentication and errors

Missing bearer tokens must return `401` with `M_MISSING_TOKEN`. Invalid bearer
tokens must return `401` with `M_UNKNOWN_TOKEN`.

Missing media must return `404` with `M_NOT_FOUND`. Uploads rejected by server
policy must return `403` with `M_FORBIDDEN`. Uploads larger than the configured
server limit must return `413` with `M_TOO_LARGE`.

## Compatibility boundaries

- Existing `/_houra/client/media/**` behavior stays available.
- Matrix media endpoints must use Matrix `M_*` error envelopes, not Houra
  `code` envelopes.
- Matrix v1.18 deprecates unauthenticated `/_matrix/media/v3/download/**`
  downloads in favor of authenticated `/_matrix/client/v1/media/download/**`.
  This contract does not require the deprecated unauthenticated download
  endpoints.
- This contract does not advertise thumbnail, URL preview, async upload,
  remote/federated media fetching, encrypted attachment metadata, range
  requests, or CDN redirect behavior.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if parser-only shared-core
  adoption is useful for Matrix media response parsing or `mxc://` validation.
