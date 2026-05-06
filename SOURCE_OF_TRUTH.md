# Source of Truth

Canonical behavior is defined by this repository only.

After this root is published as a standalone repository, the contracts, test
vectors, and shared design tokens here remain the only canonical source for
the covered client behavior.

Priority order:

1. `contracts/SPEC-*.md`
2. `test-vectors/`
3. `design/theme.schema.json` and `design/themes/*.json`
4. Supporting docs

If an implementation differs from this repository, the implementation should be
updated unless the contract is changed first.

## Contract Changes

- Change or add a contract before changing implementation behavior.
- Add or update a test vector with every behavior change.
- Keep shared theme token changes in `design/` first, then copy them into
  implementation packages that need bundled assets.
- Do not use a server implementation as the source for client behavior.

## Versioning

- Contracts are draft profiles until a pre-1.0 release decision is made.
- Public client APIs may be added only after a matching `SPEC-*` contract and
  vector exist here.
- Release notes should describe changed feature profiles, not implementation
  internals.
