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
  "download_url": "https://example.test/_chawan/client/media/media1/content"
}
```

## Client expectations

- This contract covers metadata and base64 upload only.
- Binary streaming, encryption, thumbnails, and federation are out of scope.
