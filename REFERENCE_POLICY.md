# Reference Policy

Allowed sources:

- Houra contracts
- Houra test vectors
- Stable public protocol specifications when a contract explicitly points to them
- Official Dart, Flutter, Rust, Swift, Kotlin, TypeScript, and platform
  documentation

Disallowed sources:

- Existing client implementation code
- Existing server implementation code
- Existing server database schemas or migrations
- Existing server storage, sync, state, or event-auth algorithms

If behavior is unclear, add or update a contract before implementing it.

## Implementation Boundary

- Implementation repositories may use this repository's contracts, vectors, and
  design tokens.
- Client and server implementation repositories are peers. Neither is
  canonical, and neither may backfill missing public behavior from the other.
- Implementation repositories must not backfill missing behavior from server
  code, storage design, or client implementation details.
- If a vector is insufficient, update this repository first.

## Future Clients

- Swift, Kotlin, TypeScript/React, Vue, Next.js, React Native, and other clients
  may share only contracts, vectors, theme JSON, and UI surface JSON from this
  root as canonical specification input.
- Shared implementation artifacts, such as a Rust protocol core, may be
  consumed from their own implementation repositories after parity evidence
  exists. They must not become sources for public behavior in this repository.
- If one language or platform needs a separate implementation while others can
  share code, record that split in the implementation sharing matrix or the
  relevant adoption report instead of changing the contract boundary.
- Each client owns its native adapter, package shape, examples, and tests.
- Feature examples should wait until the implementation passes the canonical
  vectors for that feature.
