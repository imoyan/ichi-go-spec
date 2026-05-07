# SPEC-020: Media

Status: draft
Feature profile: media
Canonical: yes

## Purpose

Define minimal media metadata upload and download descriptors.

## Upload request

```text
POST /_chawan/client/media
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
  "content_uri": "chawan://media/media1"
}
```

## Download metadata request

```text
GET /_chawan/client/media/{media_id}
Authorization: Bearer token-1
```

## Download metadata response

```json
{
  "media_id": "media1",
  "filename": "avatar.png",
  "content_type": "image/png",
  "download_url": "https://example.test/_chawan/client/media/media1/content",
  "download_requires_auth": false,
  "download_expires_at": "2030-01-01T00:00:00Z"
}
```

`download_expires_at` is optional.

## Missing media response

```json
{
  "code": "CHAWAN_NOT_FOUND",
  "message": "Media not found."
}
```

## Client expectations

- This contract covers metadata and base64 upload only.
- `download_url` is an opaque URL. Clients must not parse it, rewrite it, or
  infer server storage layout from it.
- `content_type` is the expected Content-Type for the downloaded media bytes.
- `download_requires_auth` tells clients whether the download URL expects the
  same bearer token authorization model as the metadata request.
- `download_expires_at`, when present, is an RFC 3339 timestamp after which
  clients should refresh metadata before attempting a new download.
- Missing media should use HTTP 404 with `CHAWAN_NOT_FOUND` when a structured
  error body is available.
- Binary streaming, encryption, thumbnails, and federation are out of scope.
