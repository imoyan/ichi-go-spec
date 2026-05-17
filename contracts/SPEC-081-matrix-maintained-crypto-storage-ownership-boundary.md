# SPEC-081: Matrix Maintained Crypto Stack and Storage Ownership Boundary

Status: draft
Feature profile: messaging
Contract type: boundary
Matrix domain: Olm & Megolm
Canonical: yes

## Purpose

Define the first child contract under `SPEC-079` for Matrix v1.18 Olm & Megolm
work: maintained crypto stack selection evidence and host-owned secure storage,
recovery secret, and local state ownership.

This contract does not select a production package, implement cryptographic
behavior, add endpoints, widen Matrix `/versions`, or claim full E2EE support.
It defines the minimum boundary that implementation repositories must satisfy
before adopting any narrower Olm, Megolm, backup, verification, cross-signing,
or encrypted-media behavior.

## Scope

This contract consumes the `maintained-crypto-stack-local-state-ownership-
breadth` lane from `SPEC-079`.

It separates three responsibilities:

- maintained Matrix crypto stack evidence;
- crypto-adapter-owned cryptographic operations and key material managed by the
  maintained stack;
- host-owned secure storage, recovery secret lifecycle, local deletion, and
  user-facing recovery ownership.

Server repositories remain storage and routing owners for public Matrix
endpoint data only. They must not own local secure storage, recovery secrets,
private keys, plaintext, or decrypted session material.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/olm-megolm/>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#end-to-end-encryption>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#server-side-key-backups>
- Checked at: 2026-05-14T20:30:56+09:00
- Timezone: Asia/Tokyo

## Maintained crypto stack gate

Any adopting implementation must record all of the following before claiming
support for a child E2EE lane:

- upstream project or package name and exact version;
- target runtime and platform support list;
- license compatibility with the adopting repository;
- active maintenance and security-update evidence;
- covered Matrix algorithm families, including Olm and Megolm;
- adapter surface used by Houra and the operations intentionally not exposed;
- interop or vector evidence for the adopted child lane;
- rollback or disablement path if the stack becomes unmaintained.

Houra repositories must not implement Olm, Megolm, SAS, cross-signing crypto,
secret-storage crypto, key-backup crypto, or authenticated media crypto
primitives locally.

## Host-owned secure storage and recovery secret ownership

Host applications own the lifecycle, UX, and persistence policy for:

- access tokens and refresh tokens;
- private identity keys;
- recovery keys and recovery passphrases;
- backup secrets and secret-storage key material;
- platform keychain or secure enclave selection;
- account lock, logout, device deletion, and local data deletion;
- backup setup, recovery prompts, trust warnings, and recovery UX;
- redaction of local paths, secure-storage handles, and secret-bearing
  diagnostics.

The crypto adapter may encrypt, decrypt, import, export, or validate key
material through the maintained stack. It must not decide where secrets are
persisted, when the user is prompted, how recovery is presented, or which host
storage backend is trusted.

## Server and artifact boundary

Servers may store Matrix public keys, one-time keys, fallback keys, to-device
payloads, encrypted room events, and opaque key-backup payloads only as defined
by narrower endpoint contracts.

Servers and release artifacts must not store or log:

- plaintext room content;
- room keys or Megolm session keys;
- private identity keys;
- private cross-signing keys;
- recovery keys, recovery passphrases, backup secrets, or secret-storage key
  material;
- platform secure-storage handles;
- local filesystem paths that identify secret storage.

Evidence artifacts may name the crypto stack, version, platform list, contract
refs, and pass/fail results. They must be redacted before publication.

## Adoption decision checklist

After this contract merges:

- `SPEC-079` child work may cite `SPEC-081` as the ownership boundary for the
  maintained crypto stack and host-owned recovery secret lane.
- `houra-client` implementation issues may select a maintained crypto stack and
  host-owned secure storage policy against this contract.
- `houra-server` work may cite this contract only to prove it does not own local
  secrets, plaintext, or private key material.
- `houra-labs` work remains limited to parser-only helpers and redacted
  evidence tooling unless a later contract explicitly expands that scope.
- Matrix `/versions` advertisement remains unchanged until release evidence
  passes the `SPEC-062`, `SPEC-064`, `SPEC-065`, and `SPEC-066` gates.

## Compatibility boundaries

- `SPEC-050` remains the broad crypto-adapter boundary.
- `SPEC-079` remains the full Olm & Megolm gap inventory.
- This contract does not replace endpoint gates in `SPEC-051`, `SPEC-052`,
  `SPEC-053`, `SPEC-054`, `SPEC-069`, or `SPEC-072`.
- This contract does not add secure storage APIs to shared core or require
  server-side handling of recovery secrets.
