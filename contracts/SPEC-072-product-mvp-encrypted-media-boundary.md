# SPEC-072: Product MVP Encrypted Media Attachment Boundary

Status: draft
Feature profile: media
Canonical: yes

## Purpose

Define the Product MVP boundary for encrypted media attachments before any
Houra client or server implementation adds encrypted attachment metadata,
encrypted content transfer, media-key handling, or preview behavior.

This contract records a fail-closed defer decision. It intentionally does not
add encrypted attachment endpoints, event content schemas, crypto adapter APIs,
media-key storage, plaintext cache behavior, preview UI, or E2EE support claims
by itself.

## Scope

This contract is Houra-defined Product MVP planning, with Matrix v1.18 media and
E2EE references used only to keep boundaries compatible with the existing Matrix
media MVP and encrypted-room contracts.

The current Product MVP media surface remains metadata upload, metadata read,
and same-origin binary download through `SPEC-020`, plus the Matrix media MVP
upload/download subset through `SPEC-038`. The current Matrix E2EE path remains
bounded by `SPEC-050` through `SPEC-054`.

Encrypted media attachments are not adopted by this contract. Thumbnail, range,
and resumable transfer behavior is split into `SPEC-071` and must not be mixed
with this encrypted attachment boundary.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#media-repository>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#end-to-end-encryption>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#mroomencrypted>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#mroommessage-msgtypes>
- Checked at: 2026-05-13T18:35:00+09:00
- Timezone: Asia/Tokyo

## Current decision

The Product MVP media and E2EE scopes are not widened by this contract.

Servers must not advertise or expose Product MVP encrypted attachment behavior
as supported unless a later contract defines the public event/content shape,
metadata, key-handling boundary, transfer behavior, error behavior, UI surface,
security evidence, and implementation adoption gates.

Clients must fail closed:

- do not render encrypted attachment preview, upload, download, share, or export
  controls as Product MVP actions;
- do not add SDK methods for encrypted attachment metadata parsing, encrypted
  content upload/download, media-key handling, decryption, or plaintext cache
  policy until a later contract defines them;
- do not infer support from `m.room.encrypted` support, crypto stack selection,
  server media upload support, a lab prototype, or implementation repository
  behavior;
- keep the existing media flows from `SPEC-020`, `SPEC-038`, and the crypto
  boundary from `SPEC-050` unchanged.

## Boundary split

Future work must be split into issue-sized gates. A later spec may adopt one or
more of these lanes:

1. Encrypted attachment metadata parser and validation.
2. Encrypted attachment upload/download descriptors.
3. Crypto adapter responsibilities for encrypt/decrypt and media-key handling.
4. Host storage and secure deletion policy for encrypted and plaintext bytes.
5. Preview, share, and export UI surface updates.
6. Release evidence and advertisement wording for encrypted attachment support.

Encrypted attachment support must not be used as evidence of encrypted-room
support, complete E2EE support, key backup support, verification support, or
Matrix full compliance unless the corresponding contracts and release gates
explicitly say so.

## SDK, crypto adapter, and host ownership

SDK core may own only protocol-shaped helpers after a later contract exists:

- encrypted attachment metadata parser;
- request descriptors;
- response parsers;
- Matrix content URI validation;
- opaque encrypted content descriptor parsing;
- public error-envelope mapping.

Crypto-adapter responsibilities remain separate:

- encryption and decryption;
- media-key generation, import, export, and validation;
- authenticated encryption algorithm selection;
- integrity verification;
- integration with the maintained Matrix crypto stack required by `SPEC-050`.

Host-owned responsibilities remain outside SDK core:

- filesystem paths and storage locations;
- cache policy, storage quota, and eviction;
- secure deletion;
- native secure storage selection;
- plaintext byte lifecycle;
- preview rendering and image/video decoding;
- share/export policy;
- background task policy;
- user-facing warning, progress, cancellation, and retry copy.

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
implementation refs, crypto stack name/version, and clean-room confirmation. It
must not record secret values, local paths, plaintext bytes, or decrypted
previews.

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
- The Product MVP UI surface remains unchanged by this contract.
- This contract does not widen `GET /_matrix/client/versions` advertisement.
- This contract does not claim encrypted attachment support, encrypted-room
  support, complete E2EE support, or Matrix v1.18 full compliance.

## Adoption decision checklist

After this contract merges:

- `houra-client` may cite this boundary to keep encrypted media attachments out
  of its exported SDK API and Expo Product MVP surface.
- `houra-server` must not add supported public Product MVP behavior for
  encrypted attachments without a narrower follow-up contract.
- `houra-labs` may prototype parser-only helpers only when the prototype output
  is clearly non-canonical and does not become implementation evidence by
  itself.
- Future spec work must add contract text, vectors, UI surface updates when UI
  changes, crypto/security evidence requirements, and implementation adoption
  gates before implementation adoption.
