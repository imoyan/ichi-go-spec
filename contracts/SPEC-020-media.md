# SPEC-020: Media

Status: draft
Feature profile: media
Canonical: yes

## Purpose

Define minimal media metadata upload and download descriptors.

## Upload request

```text
POST /_houra/client/media
Authorization: Bearer token-1
```

```json
{
  "filename": "avatar.png",
  "content_type": "image/png",
  "bytes_base64": "aGVsbG8="
}
```

## Upload response

```json
{
  "media_id": "media1",
  "content_uri": "houra://media/media1"
}
```

## Download metadata request

```text
GET /_houra/client/media/{media_id}
Authorization: Bearer token-1
```

## Download metadata response

```json
{
  "media_id": "media1",
  "filename": "avatar.png",
  "content_type": "image/png",
  "download_url": "https://example.test/_houra/client/media/media1/content",
  "download_requires_auth": false,
  "download_expires_at": "2030-01-01T00:00:00Z"
}
```

Required response fields are `media_id`, `filename`, `content_type`,
`download_url`, and `download_requires_auth`.

`download_expires_at` is optional.

## Download content request

```text
GET /_houra/client/media/{media_id}/content
```

Clients must use the exact `download_url` returned by metadata. The path above
is the project-defined form of the URL for same-origin Houra servers.

If the latest metadata for the media object says `download_requires_auth` is
`true`, clients must send:

```text
Authorization: Bearer token-1
```

If `download_requires_auth` is `false`, clients must not send bearer-token
authorization for the content request.

## Download content response

The successful response body is the raw binary media payload. The
`Content-Type` header must match the metadata `content_type` value for the same
`media_id`.

For the MVP vectors, the canonical media objects are:

- `media1` is `download_requires_auth: false` and contains the bytes
  represented by base64 `aGVsbG8=`.
- `media2` is `download_requires_auth: true` and contains the same bytes; it
  exists only to exercise the auth-required download path without changing
  `media1`'s public state.

How a media object becomes auth-required is implementation-defined and outside
this contract; the MVP vectors only assert the per-`media_id` public response
shape.

## Missing media response

```json
{
  "code": "HOURA_NOT_FOUND",
  "message": "Media not found."
}
```

## Client expectations

- This contract covers metadata, base64 upload, and same-origin binary download.
- `download_url` is an opaque URL. Clients must not parse it, rewrite it, or
  infer server storage layout from it.
- `content_type` is the expected Content-Type for the downloaded media bytes.
- `download_requires_auth` tells clients whether the download URL expects
  bearer token authorization. Clients must attach `Authorization: Bearer` only
  when this value is `true`; clients must not attach bearer tokens when this
  value is `false`.
- `download_expires_at`, when present, is an RFC 3339 timestamp after which
  clients should refresh metadata before attempting a new download.
- Missing media should use HTTP 404 with `HOURA_NOT_FOUND` when a structured
  error body is available.
- Range requests, resumable download, encryption, thumbnails, and federation
  are out of scope.
