# Matrix v1.18 / Olm & Megolm / secret storage and cross-signing account data shape parser boundary

Status: draft
Feature profile: messaging
Contract type: boundary
Matrix domain: Olm & Megolm
Primary reference: Matrix v1.18 / Olm & Megolm / secret storage and cross-signing account data shape parser boundary
Repository anchor: SPEC-148 Matrix Secret Storage Account Data Parser Boundary
Canonical: yes

## Purpose

Define a parser-only boundary for Matrix v1.18 Secret Storage and Sharing
(SSSS) account-data event content shapes:

- `m.secret_storage.default_key`;
- `m.secret_storage.key.{key_id}`;
- `m.cross_signing.master`, `m.cross_signing.self_signing`,
  `m.cross_signing.user_signing`;
- `m.megolm_backup.v1`.

This contract is a child gate of `SPEC-079`
`server-side-key-backup-recovery-secret-storage-breadth`. It is sibling to
`SPEC-102` E2EE parser artifact breadth and `SPEC-146` encrypted attachment
parser boundary. It does not implement key derivation, AES, HMAC, or any
cryptographic primitive; it does not infer trust; and it does not widen
`GET /_matrix/client/versions`.

The Matrix v1.18 account-data endpoint stores any JSON value the client
uploads, so the server itself does not validate SSSS shape. This contract
is intended for `houra-labs` parser-only adoption and for `houra-client`
crypto adapter input validation before passing values to the maintained
crypto stack.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#secret-storage>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#key-storage>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#secrets>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#cross-signing>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#server-side-key-backups>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#put_matrixclientv3useruseridaccount_datatype>
- Checked at: 2026-05-18T22:00:00+09:00
- Timezone: Asia/Tokyo

## Scope

The parser boundary covers the public content shape of the account-data
event types listed above as defined by Matrix v1.18.

The boundary does not cover:

- the `PUT /_matrix/client/v3/user/{userId}/account_data/{type}` HTTP
  endpoint itself, which accepts any JSON object as documented by
  `SPEC-045`;
- AES, HMAC, PBKDF2, or any cryptographic primitive used to derive secret
  storage keys from passphrases, encrypt secrets, or verify MACs;
- recovery key import, export, or display UX;
- key backup `auth_data` shape beyond `SPEC-053`;
- cross-signing key publication on `keys/device_signing/upload` beyond
  `SPEC-054` and `SPEC-144`;
- federation distribution of SSSS account data;
- Matrix v1.18 full E2EE support advertisement.

## `m.secret_storage.default_key`

The content object must contain:

- `key`: a string identifying the default secret storage key id.

The content must not contain raw passphrase material, AES key bytes, or
recovery-key seed bytes.

## `m.secret_storage.key.{key_id}`

The account-data event type embeds the key id in the type suffix. The
content object must contain:

- `algorithm`: a string identifying the secret storage encryption
  algorithm. The representative value is
  `m.secret_storage.v1.aes-hmac-sha2`.
- `iv`: a base64 string for the AES initialisation vector;
- `mac`: a base64 string for the integrity MAC over the all-zero AES
  test plaintext, used to verify that a derived key matches the stored
  key without exposing the key itself.

The content may optionally contain:

- `name`: a string display name;
- `passphrase`: an object with PBKDF2 derivation parameters:
  - `algorithm`: must be `m.pbkdf2`;
  - `salt`: a base64 string salt;
  - `iterations`: a positive integer iteration count;
  - `bits`: a positive integer key length, default `256` when omitted.

The content must not include the derived key bytes, the passphrase
plaintext, or AES-decrypted secret bytes.

## `m.cross_signing.master`, `m.cross_signing.self_signing`, `m.cross_signing.user_signing`

The content object must contain:

- `encrypted`: an object keyed by secret storage key id whose values
  contain `ciphertext`, `iv`, and `mac` base64 strings produced by the
  `m.secret_storage.v1.aes-hmac-sha2` algorithm.

The content must not include the AES key, the recovery key, the
unencrypted cross-signing private signing key, or the seed used to
derive cross-signing keys.

## `m.megolm_backup.v1`

The content object must contain:

- `encrypted`: an object keyed by secret storage key id whose values
  contain `ciphertext`, `iv`, and `mac` base64 strings.

The content must not include the AES key, the recovery key, the
unencrypted Megolm backup recovery key, or the decrypted backup payload.

## Parser Output Shape

A parser-only output records:

- the account-data event type (and `key_id` suffix when applicable);
- whether the public shape parses successfully;
- the algorithm string;
- the secret storage key id(s) referenced by `encrypted` entries;
- whether the artifact carries any secret-bearing fields that the
  parser must omit from shared output (`iv`, `mac`, `ciphertext`,
  `salt`, `passphrase`, and any derived key material are treated as
  opaque carry-through values that must be redacted from cross-process
  output and release evidence per `SPEC-137`).

The parser must reject artifacts that:

- omit `algorithm` on a key descriptor or encrypted secret event;
- set `algorithm` to a value other than `m.secret_storage.v1.aes-hmac-sha2`
  for the current v1.18 baseline;
- omit `iv` or `mac` on a key descriptor;
- omit `encrypted` on a `m.cross_signing.*` or `m.megolm_backup.v1`
  event;
- carry an `encrypted` value that is not a non-empty object keyed by
  string secret storage key ids;
- carry a `passphrase` object whose `algorithm` is not `m.pbkdf2`,
  whose `salt` is missing, or whose `iterations` is not a positive
  integer;
- carry `m.secret_storage.default_key` without a string `key` field.

## Fail-Closed Behavior

Implementations must fail closed:

- do not implement AES, HMAC, PBKDF2, or any cryptographic primitive
  locally;
- do not retain `iv`, `mac`, `ciphertext`, `salt`, raw passphrase, or
  derived key bytes in shared parser artifact output intended for
  cross-process telemetry, release evidence, or external upload;
- do not perform secret storage decryption on the parser side;
- do not infer SSSS or key backup support from parser-only evidence;
- treat malformed SSSS content as unsupported secret storage and stop
  the adoption flow.

The parser may carry opaque `iv`, `mac`, `ciphertext`, `salt`, and
`passphrase` values through to a client-owned crypto adapter inside the
same process boundary, provided release-evidence emission redacts these
fields per the secret redaction rules in `SPEC-137`.

## Claim Boundary

Passing this contract does not claim:

- correct AES, HMAC, or PBKDF2 implementation;
- correct recovery key import or recovery from a passphrase;
- server-side validation of SSSS account-data shape (Matrix v1.18 does
  not require it);
- secret storage and cross-signing flow integration beyond `SPEC-054`,
  `SPEC-053`, `SPEC-143`, `SPEC-144`;
- federation distribution of SSSS account data;
- Matrix v1.18 full E2EE support or `/versions` advertisement
  widening.

## Japanese Guidance

この contract は Matrix v1.18 の Secret Storage and Sharing (SSSS) と
cross-signing / megolm backup の account-data 各 event content の
parser-only boundary を `houra-labs` および client crypto adapter の
入力検証用に固定する。AES / HMAC / PBKDF2 の primitive、recovery key の
import / export、Matrix `/versions` の E2EE 広告は引き続き広げない。

Matrix v1.18 の `PUT /user/{userId}/account_data/{type}` 自体は任意の JSON
を受理するため、server boundary ではなく parser boundary として扱う。

## Adoption Decision Checklist

After this contract merges:

- `houra-labs` parser-only adoption issue may cite `SPEC-148` and
  `test-vectors/messaging/matrix-secret-storage-account-data-shape-parser-boundary.json`;
- `houra-client` crypto adapter input validation may cite this contract
  but must keep `iv`, `mac`, `ciphertext`, `salt`, and `passphrase`
  values within the adapter process boundary;
- `SPEC-079` remains the full Olm & Megolm E2EE gap inventory until
  all child lanes provide runtime and release evidence;
- representative evidence from this contract must not widen Matrix
  `/versions`, release notes, or the publishable Matrix support
  claim.

## Compatibility Boundaries

- `SPEC-053` remains the server-side key backup version, upload, and
  restore endpoint boundary; `SPEC-143` extends it with bulk and
  better-session replacement breadth.
- `SPEC-054` remains the verification and cross-signing endpoint
  boundary; sibling SSSS account-data parsing is opaque to that
  contract.
- `SPEC-102` remains the broader E2EE parser artifact breadth boundary;
  this contract narrows it to SSSS account-data shapes.
- `SPEC-045` remains the generic account-data endpoint boundary; this
  contract does not change its acceptance behavior, since SSSS shape
  validation is client-side.
