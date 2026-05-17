# Houra Product MVP / Encrypted Media Attachment Boundary

Status: draft
Feature profile: media
Contract type: boundary
Matrix domain: none
Primary reference: Houra Product MVP / Encrypted Media Attachment Boundary
Repository anchor: SPEC-072 Product MVP Encrypted Media Attachment Boundary
Canonical: yes

## Purpose

Define the Product MVP boundary for encrypted media attachments before any
Houra client or server implementation adds encrypted attachment metadata,
encrypted content transfer, media-key handling, decrypted preview behavior, or
trust copy.

This contract keeps the current Product MVP release candidate fail-closed, but
it also defines optional Product MVP vNext lanes that implementations may adopt
after the matching vectors, UI surface evidence, crypto ownership evidence, and
implementation adoption gates pass.

## Scope

This contract is Houra-defined Product MVP planning, with Matrix v1.18 media and
E2EE references used only to keep boundaries compatible with the existing Matrix
media MVP and encrypted-room contracts.

The current Product MVP media surface remains metadata upload, metadata read,
and same-origin binary download through `SPEC-020`, plus the Matrix media MVP
upload/download subset through `SPEC-038`. The current Matrix E2EE path remains
bounded by `SPEC-050` through `SPEC-054`, `SPEC-069`, `SPEC-079`, and
`SPEC-081`.

Encrypted media attachment support is optional Product MVP vNext behavior. It
does not become part of the current Product MVP happy path until a release
candidate explicitly includes it and records matching adoption evidence.
Thumbnail, range, and resumable transfer behavior is split into `SPEC-071` and
must not be used as encrypted attachment support evidence.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#media-repository>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#end-to-end-encryption>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#mroomencrypted>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#mroommessage-msgtypes>
- Checked at: 2026-05-13T18:35:00+09:00
- Timezone: Asia/Tokyo

## Current release decision

The current Product MVP media and E2EE scopes are not widened by this contract.

Servers must not advertise or expose Product MVP encrypted attachment behavior
as supported unless the optional lanes below are implemented and adoption
evidence names the `houra-spec`, implementation, UI surface, crypto ownership,
and verification refs.

Clients must fail closed:

- do not render encrypted attachment preview, upload, download, decrypt, retry,
  share, or export controls as Product MVP actions unless media metadata
  advertises the encrypted attachment lane;
- do not add SDK methods for encrypted attachment metadata parsing, encrypted
  content upload/download, media-key handling, decryption, or plaintext cache
  policy until the matching lane has vectors and adoption evidence;
- do not infer support from `m.room.encrypted` support, crypto stack selection,
  server media upload support, `SPEC-071` transfer metadata, a lab prototype, or
  implementation repository behavior;
- keep the existing media flows from `SPEC-020`, `SPEC-038`, and `SPEC-071`,
  and the crypto boundary from `SPEC-050`, unchanged.

## Encrypted attachment capability metadata

Product MVP vNext encrypted attachment support is discovered through the
existing Houra metadata response from `SPEC-020`. A server that supports this
lane may add an `encrypted_attachment` object:

```json
{
  "media_id": "media1",
  "filename": "photo.png",
  "content_type": "application/octet-stream",
  "download_url": "https://example.test/_houra/client/media/media1/content",
  "download_requires_auth": true,
  "encrypted_attachment": {
    "supported": true,
    "metadata_version": "product-mvp-vnext",
    "ciphertext": {
      "content_uri": "mxc://example.test/media1-ciphertext",
      "download_url": "https://example.test/_houra/client/media/media1/content",
      "download_requires_auth": true,
      "content_length": 512,
      "content_type": "application/octet-stream"
    },
    "crypto": {
      "algorithm": "encrypted-file-v2",
      "key_ref": "host-owned-media-key-redacted",
      "iv_ref": "iv-redacted",
      "hashes": {
        "sha256": "sha256-redacted"
      },
      "key_material_inline": false
    },
    "plaintext": {
      "filename": "photo.png",
      "content_type": "image/png"
    },
    "state": "available"
  }
}
```

If `encrypted_attachment` is missing, has `supported: false`, or has
`state: "unsupported"`, clients must hide or disable the matching Product MVP
action and must not probe server-specific endpoints.

The descriptor is public behavior metadata only. It must not reveal raw media
keys, recovery keys, room keys, private local paths, cache filenames, plaintext
bytes, decrypted thumbnails, signed URL credentials, or implementation storage
keys. `key_ref`, `iv_ref`, and hash values are handles or redacted descriptors
for evidence and adapter handoff; they are not permission to log actual key
material.

## Metadata validation lane

An adopting implementation must validate encrypted attachment metadata before
download or decrypt actions become available.

Required public fields are:

- `encrypted_attachment.supported: true`;
- `encrypted_attachment.metadata_version`;
- `ciphertext.download_url` or `ciphertext.content_uri`;
- `ciphertext.download_requires_auth`;
- `ciphertext.content_type`;
- `crypto.algorithm`;
- `crypto.key_ref`;
- `crypto.key_material_inline: false` unless a later contract explicitly
  adopts inline key material handling;
- `plaintext.content_type` when the attachment will be previewed or exported;
- `state`, one of `available`, `redacted`, `missing_key`, `wrong_key`,
  `recoverable_error`, or `unsupported`.

Malformed descriptors must be treated as unsupported encrypted media. Clients
must not continue with download/decrypt just because a `download_url` is
present.

## Download and decrypt handoff lane

Encrypted attachment download reuses the `download_url` from `SPEC-020` or the
`encrypted_attachment.ciphertext.download_url` descriptor. Clients must attach
authorization exactly as the descriptor requires and must treat the response
body as opaque ciphertext.

SDK core may parse request and response descriptors, but it must pass only
validated metadata, ciphertext byte handles, public byte counts, and redacted
diagnostics downstream. Decryption is a crypto-adapter operation through the
maintained Matrix crypto stack boundary from `SPEC-050` and `SPEC-081`.

The handoff from SDK/transport to crypto adapter must include:

- validated encrypted attachment descriptor;
- ciphertext byte source or host-owned byte handle;
- algorithm name and redacted key/IV/hash handles;
- expected plaintext descriptor, when available;
- cancellation and retry signal from the host;
- redacted diagnostic context with contract refs and implementation refs.

The handoff must not include unredacted local filesystem paths in evidence,
server logs, or release artifacts. Servers must remain opaque stores and must
not decrypt encrypted attachment content, media keys, recovery keys, room keys,
or plaintext media bytes.

## Failure and redaction behavior

Implementations that adopt the optional lane must preserve these public states:

- `missing_key`: the encrypted attachment descriptor is present, but the host
  or crypto adapter has no usable media key. Download may be skipped or kept as
  ciphertext-only; plaintext preview, share, and export must stay disabled.
- `wrong_key`: the crypto adapter rejects the available key, IV, hash, or
  authentication tag. Plaintext must not be rendered, cached, shared, exported,
  logged, or summarized.
- `redacted`: the event or attachment was redacted. Clients must not download
  or decrypt the prior attachment and should show a redacted attachment state.
- `recoverable_error`: authenticated download, network transfer, checksum, or
  decrypt handoff failed in a way that can be retried. Clients may keep
  host-owned ciphertext or retry state, but must not expose local paths or raw
  bytes.
- `unsupported`: metadata is absent, malformed, or not advertised. Clients must
  keep encrypted media controls hidden or disabled.

Server-side missing media and authentication errors remain governed by
`SPEC-020` and `SPEC-038`: missing metadata or binary content is `404` with
`HOURA_NOT_FOUND`, and missing or rejected bearer tokens for protected media are
`401` with `HOURA_UNAUTHORIZED`. Client-side decrypt states are local result
states, not new `SPEC-002` error codes.

## UI and trust expectations

Product MVP vNext UI evidence must show:

- encrypted attachment actions are visible only when the metadata capability is
  advertised;
- duplicate-submit prevention for download, decrypt, and retry actions;
- pending, blocked, redacted, recoverable error, and decrypted summary states;
- user-facing trust copy that does not claim complete E2EE, encrypted-room
  support, or Matrix full compliance;
- redaction of bearer tokens, media keys, room keys, recovery keys, signed URLs,
  local filesystem paths, plaintext bytes, decrypted thumbnails, and cache
  filenames.

The UI surface may show plaintext filename/content-type only when those values
come from the validated descriptor or the decrypt result. Preview rendering,
native image/video decoding, export/share policy, and local cache cleanup remain
adapter-owned.

## Boundary split

Further work must stay split into issue-sized gates. Later specs may refine one
or more of these lanes:

1. Encrypted attachment metadata parser and validation.
2. Encrypted attachment upload/download descriptors.
3. Crypto adapter responsibilities for encrypt/decrypt and media-key handling.
4. Host storage and secure deletion policy for encrypted and plaintext bytes.
5. Preview, share, export, and trust-copy UI surface updates.
6. Release evidence and advertisement wording for encrypted attachment support.

Encrypted attachment support must not be used as evidence of encrypted-room
support, complete E2EE support, key backup support, verification support, or
Matrix full compliance unless the corresponding contracts and release gates
explicitly say so.

## SDK, crypto adapter, and host ownership

SDK core may own only protocol-shaped helpers after the matching lane is
adopted:

- encrypted attachment metadata parser;
- request descriptors;
- response parsers;
- Matrix content URI validation;
- opaque encrypted content descriptor parsing;
- public error-envelope mapping;
- redacted decrypt-handoff diagnostic shaping.

Crypto-adapter responsibilities remain separate:

- encryption and decryption;
- media-key generation, import, export, and validation;
- authenticated encryption algorithm selection;
- integrity verification;
- integration with the maintained Matrix crypto stack required by `SPEC-050`
  and `SPEC-081`.

Host-owned responsibilities remain outside SDK core:

- filesystem paths and storage locations;
- cache policy, storage quota, and eviction;
- secure deletion;
- native secure storage selection;
- plaintext byte lifecycle;
- preview rendering and image/video decoding;
- share/export policy;
- background task policy;
- user-facing warning, trust, progress, cancellation, and retry copy.

Server-owned responsibilities must remain opaque unless a later contract narrows
them. The server must not decrypt encrypted attachment content, media keys,
recovery keys, room keys, or plaintext media bytes.

## Security and evidence

Future encrypted media work must not write these values to logs, issue
evidence, release evidence, screenshots, README examples, or test artifacts:

- bearer tokens;
- media keys;
- recovery keys;
- room keys;
- plaintext media bytes;
- decrypted thumbnails;
- local filesystem paths;
- signed or credentialed URLs;
- cache filenames that expose user data.

Evidence may record redacted presence flags, byte counts, contract refs,
implementation refs, crypto stack name/version, UI state ids, and clean-room
confirmation. It must not record secret values, local paths, plaintext bytes,
or decrypted previews.

## Compatibility boundaries

- `SPEC-020` remains the contract for Houra media metadata upload, download
  descriptors, and same-origin binary download.
- `SPEC-038` remains the contract for Matrix media MVP upload and authenticated
  download.
- `SPEC-050` remains the contract for Matrix crypto adapter ownership.
- `SPEC-052` remains the contract for to-device and encrypted room event
  envelopes.
- `SPEC-071` remains the boundary for thumbnails, range requests, and
  resumable download.
- `SPEC-079` remains the full Olm & Megolm E2EE gap inventory.
- `SPEC-081` remains the maintained crypto stack and host-owned secure storage
  boundary.
- Product MVP vNext encrypted media UI actions are optional and must remain
  hidden unless matching metadata capabilities are advertised and adoption
  evidence is recorded.
- This contract does not widen `GET /_matrix/client/versions` advertisement.
- This contract does not claim encrypted-room support, complete E2EE support,
  or Matrix v1.18 full compliance.

## Adoption decision checklist

After this contract merges:

- `houra-client` may cite this boundary to keep encrypted media attachments out
  of its exported SDK API and Expo Product MVP surface until capability,
  crypto-adapter, UI, and redaction evidence is ready.
- `houra-server` must not add supported public Product MVP behavior for
  encrypted attachments without adopting this optional lane and recording
  opaque-ciphertext behavior.
- `houra-labs` may prototype parser-only helpers only when the prototype output
  is clearly non-canonical and does not become implementation evidence by
  itself.
- Future implementation adoption must add or cite contract text, vectors, UI
  surface updates, crypto/security evidence requirements, and implementation
  adoption gates before encrypted media support is advertised.
