# Reference Policy

Allowed sources:

- Okomedev contracts
- Okomedev test vectors
- Stable public protocol specifications when a contract explicitly points to them
- Official Dart, Flutter, Swift, Kotlin, TypeScript, and platform documentation

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

- Swift, Kotlin, and TypeScript/React clients may share only contracts, vectors,
  and theme JSON from this root.
- Each client owns its native adapter, package shape, examples, and tests.
- Feature examples should wait until the implementation passes the canonical
  vectors for that feature.
