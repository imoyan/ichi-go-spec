# SPEC-050: Matrix Crypto Adapter Boundary

Status: draft
Feature profile: core
Contract type: boundary
Matrix domain: Client-Server API
Canonical: yes

## Purpose

Define the Matrix v1.18 E2EE implementation boundary before adding device key,
one-time key, fallback key, encrypted room, key backup, verification, and
cross-signing endpoint contracts.

## Scope

This contract is Matrix-defined, not Houra-defined. It records the E2EE
boundary needed to prevent local Olm/Megolm reimplementation while keeping
Houra token, secure-storage, key-storage, and UI ownership clear.

This contract does not add new `/_matrix/**` endpoints by itself. It defines
adapter requirements, forbidden local crypto ownership, host-owned storage
boundaries, server/client/labs adoption decision rules, and the evidence
required before later E2EE contracts may be implemented or advertised.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#end-to-end-encryption>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#one-time-and-fallback-keys>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#device-verification>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#cross-signing>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#server-side-key-backups>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#molmv1curve25519-aes-sha2>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#mmegolmv1aes-sha2>
- Checked at: 2026-05-10T19:28:06+09:00
- Timezone: Asia/Tokyo

## Maintained crypto stack requirement

Any Houra E2EE implementation must use a maintained Matrix crypto stack through
an adapter boundary. Houra repositories must not implement Olm, Megolm, SAS,
cross-signing cryptographic operations, secret-storage encryption, or key
backup cryptographic algorithms locally.

A crypto stack is acceptable only when the adopting repository records:

- upstream project or package name and version;
- target runtime and supported platform list;
- license compatibility;
- active maintenance and security-update evidence;
- known Matrix algorithm coverage for `m.olm.v1.curve25519-aes-sha2` and
  `m.megolm.v1.aes-sha2`;
- explicit host-owned storage and token boundary;
- regression vectors or interoperability smoke evidence for the E2EE contract
  being adopted.

The adapter may expose typed facades for Matrix payloads and lifecycle methods.
It must not hide token persistence, secure storage, recovery key storage,
device trust UI policy, push notification policy, or background task policy
inside the crypto stack.

## Ownership boundary

Host-owned responsibilities:

- access-token and refresh-token persistence;
- platform secure storage selection and lifecycle;
- private key, recovery key, passphrase, and backup secret storage policy;
- device trust UI and warning policy;
- logout, account lock, account suspension, and local data deletion policy;
- background sync/task policy;
- user prompts for verification, backup, and recovery.

Crypto-adapter responsibilities:

- Olm session and Megolm group-session operations through the maintained stack;
- device key, one-time key, and fallback key generation/signing through the
  maintained stack;
- encrypted room event encrypt/decrypt operations;
- key backup encrypt/decrypt operations;
- verification and cross-signing cryptographic operations;
- import/export format validation for keys owned by the maintained stack.

Server-owned responsibilities:

- store and serve Matrix public device keys, one-time keys, fallback keys, and
  cross-signing public key data;
- enforce one-time key claim semantics at most once;
- route to-device messages without decrypting client payloads;
- store server-side key backup payloads as opaque encrypted data;
- expose Matrix `M_*` error envelopes for E2EE endpoint failures.

The server must not decrypt encrypted room content, to-device payloads, private
cross-signing keys, recovery keys, or key backup session data.

Labs-owned responsibilities are limited to parser-only shared helpers when a
later issue explicitly adopts them. Candidate helpers may cover identifiers,
Matrix URI/content URI parsing, canonical JSON, event validation, room-version
helpers, and typed payload shape validation. Labs must not own crypto,
transport, storage, UI, retry policy, secure storage, or Olm/Megolm behavior.

## Adoption decision checklist

After this contract merges:

- create an `houra-client` adoption issue for selecting and wrapping a
  maintained Matrix crypto stack;
- create an `houra-server` adoption issue only when an endpoint contract needs
  server-side key storage, to-device delivery, or key-backup storage;
- create an `houra-labs` adoption issue only when a parser-only shared helper
  is intentionally adopted and has parity vectors;
- do not create an `houra-labs` issue for crypto primitives, secure storage,
  transport, UI, retry, or platform keychain behavior.

Every later E2EE spec PR must name which part of this checklist it consumes and
must include vectors or interop smoke evidence for that narrower scope.

## Compatibility boundaries

- Existing `/_houra/client/**` behavior stays available.
- This contract does not by itself implement or advertise E2EE support.
- This contract does not add device key, one-time key, fallback key, to-device,
  encrypted room, key backup, verification, cross-signing, or secret-storage
  endpoint vectors.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030` and `SPEC-031`.
- Unstable MSC behavior is out of scope unless a later contract explicitly
  opts in.
