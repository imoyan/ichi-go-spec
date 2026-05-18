# Matrix v1.18 / Olm & Megolm / encrypted attachment EncryptedFile metadata parser boundary

Status: draft
Feature profile: messaging
Contract type: boundary
Matrix domain: Olm & Megolm
Primary reference: Matrix v1.18 / Olm & Megolm / encrypted attachment EncryptedFile metadata parser boundary
Repository anchor: SPEC-146 Matrix Encrypted Attachment EncryptedFile Parser Boundary
Canonical: yes

## Purpose

Define a parser-only boundary for Matrix v1.18 encrypted attachment
metadata (the `EncryptedFile` JSON object) that appears inside encrypted
`m.room.message` content for `m.file`, `m.image`, `m.video`, and `m.audio`
message types, and for encrypted thumbnails under `info.thumbnail_file`.

This contract is a child gate of `SPEC-079`
`encrypted-media-attachment-breadth`. It is sibling to `SPEC-102` E2EE
parser artifact breadth and complements `SPEC-072` Product MVP encrypted
attachment boundary. It does not implement local AES-CTR decryption,
own client-side media keys, decode media bytes, or widen
`GET /_matrix/client/versions`.

The server is opaque to this metadata because it lives inside encrypted
`m.room.encrypted` content (`SPEC-052`, `SPEC-142`). This contract is
intended for `houra-labs` parser-only adoption and for client adapter
input validation, not for server-side runtime adoption.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#sending-encrypted-attachments>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#extensions-to-mroommessage-msgtypes>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#mfile>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#mimage>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#mvideo>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#maudio>
- Checked at: 2026-05-18T20:30:00+09:00
- Timezone: Asia/Tokyo

## Scope

The parser boundary covers the public `EncryptedFile` JSON object as
defined by Matrix v1.18 for encrypted attachments.

The boundary does not cover:

- AES-CTR decryption of attachment ciphertext;
- media upload or download transport beyond `SPEC-038` and `SPEC-071`;
- thumbnail generation, encrypted preview, or range-request semantics
  beyond `SPEC-071`;
- the `encrypted_attachment` Product MVP capability metadata in
  `SPEC-072`;
- runtime trust evaluation of remote `mxc://` content;
- Matrix v1.18 full E2EE support advertisement.

## EncryptedFile Object Shape

An `EncryptedFile` value is a JSON object with these required fields:

- `url`: a string `mxc://` URI pointing to the ciphertext upload;
- `key`: a JSON Web Key (JWK) object describing the AES-CTR key;
- `iv`: a base64-encoded string carrying the 16-byte AES-CTR
  initialisation vector;
- `hashes`: an object mapping hash algorithm name to base64-encoded
  digest; the `sha256` entry over the ciphertext is required;
- `v`: a string version identifier; the canonical Matrix v1.18 value is
  `"v2"`.

The `key` JWK object must include:

- `kty`: `"oct"`;
- `alg`: `"A256CTR"`;
- `k`: a base64url-encoded 32-byte AES key value;
- `ext`: `true`;
- `key_ops`: a list containing at least `"encrypt"` and `"decrypt"`.

`EncryptedFile` appears under:

- `content.file` on `m.file`, `m.image`, `m.video`, and `m.audio`
  messages that carry an encrypted attachment;
- `content.info.thumbnail_file` when an encrypted thumbnail is present
  alongside the main attachment.

`content.url` (plaintext mxc) must not appear alongside `content.file`
in the same message content; encrypted and plaintext URI fields are
mutually exclusive.

## Parser Output Shape

A parser-only output of an `EncryptedFile` artifact records:

- whether the public shape parses successfully;
- whether the artifact carries any secret-bearing fields that the parser
  must omit from output (the entire `key` object including `k`, the
  `iv`, and `hashes` values are treated as opaque carry-through, not
  parser-derived);
- the `url` mxc reference;
- the `v` version string;
- the location (`content.file` or `content.info.thumbnail_file`).

The parser must reject artifacts that:

- omit `url`, `key`, `iv`, `hashes`, or `v`;
- omit any of `kty`, `alg`, `k`, `ext`, `key_ops` from the inner JWK;
- set `kty` to a value other than `"oct"`;
- set `alg` to a value other than `"A256CTR"`;
- set `ext` to anything other than `true`;
- set `key_ops` without both `"encrypt"` and `"decrypt"`;
- omit the `sha256` entry from `hashes`;
- set `v` to a value other than `"v2"` for current Matrix v1.18
  decryption-compatible content (a parser may surface other values for
  diagnostics but must not claim decryption compatibility);
- set `url` to anything other than an `mxc://` URI.

## Fail-Closed Behavior

Implementations must fail closed:

- do not implement AES-CTR or any cryptographic primitive locally;
- do not retain the decrypted plaintext, the JWK `k` material, the
  `iv` bytes, or the `hashes` digest values in shared parser artifact
  output that is intended for cross-process telemetry, release
  evidence, or external upload;
- do not perform `mxc://` fetch on the parser side;
- do not infer encrypted attachment support from parser-only evidence;
- treat malformed `EncryptedFile` content as unsupported encrypted
  media and stop the adoption flow.

The artifact may carry through opaque `k`, `iv`, and `hashes` values
to a client-owned crypto adapter inside a single process boundary,
provided that release-evidence emission redacts these fields per the
secret redaction rules in `SPEC-137`.

## Claim Boundary

Passing this contract does not claim:

- AES-CTR decryption correctness;
- thumbnail or preview rendering of encrypted attachments;
- encrypted attachment upload/download integration with `mxc://` media
  beyond `SPEC-038`, `SPEC-071`, and `SPEC-072`;
- support for plaintext / encrypted attachment switching beyond the
  mutual-exclusion rule above;
- Matrix v1.18 full E2EE support or `/versions` advertisement
  widening.

## Japanese Guidance

この contract は Matrix v1.18 の暗号化添付ファイル metadata
(`EncryptedFile` JWK) の parser-only boundary を `houra-labs` および
client adapter の入力検証用に固定する。AES-CTR 復号、`mxc://` の取得、
encrypted thumbnail 生成、Matrix `/versions` の E2EE 広告は引き続き
広げない。server は `m.room.encrypted` の中身を見ないため、本 contract
は server boundary ではない。

## Adoption Decision Checklist

After this contract merges:

- `houra-labs` parser-only adoption issue may cite `SPEC-146` and
  `test-vectors/messaging/matrix-encrypted-attachment-encryptedfile-parser-boundary.json`;
- `houra-client` crypto adapter input validation may cite this contract
  but must keep `k`, `iv`, and `hashes` values within the adapter
  process boundary;
- `SPEC-079` remains the full Olm & Megolm E2EE gap inventory until all
  child lanes provide runtime and release evidence;
- representative evidence from this contract must not widen Matrix
  `/versions`, release notes, or the publishable Matrix support
  claim.

## Compatibility Boundaries

- `SPEC-052`, `SPEC-142`, and the `SPEC-079` Olm session lane remain
  the encrypted-room timeline boundaries; the server cannot observe
  `EncryptedFile` because it lives inside encrypted content.
- `SPEC-072` remains the Product MVP encrypted attachment capability
  metadata boundary.
- `SPEC-071` remains the Product MVP media transfer boundary for
  thumbnail, range, and resumable behavior.
- `SPEC-102` remains the broader E2EE parser artifact breadth
  boundary; this contract narrows it to the encrypted attachment
  metadata family.
