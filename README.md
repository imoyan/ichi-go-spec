# chawan-product-spec

`chawan-product-spec` is the canonical source of truth for the Okomedev Chawan
client API subset.

Implementation repositories must follow this repository's contracts and test
vectors. They must not derive behavior from a server implementation.

This root is intended to become a standalone public specification repository.
It contains canonical contracts, test vectors, and shared design tokens only;
implementation behavior, package adapters, and server-specific details belong
in implementation repositories.

## Layout

- `contracts/`: normative API behavior.
- `test-vectors/`: request and response fixtures implementations must pass.
- `design/`: shared platform-neutral theme tokens.
- `SOURCE_OF_TRUTH.md`: precedence and change rules.
- `REFERENCE_POLICY.md`: clean-room source policy.
- `FEATURE_PROFILES.md`: feature slices.
- `MODULE_DEPENDENCIES.md`: allowed dependency direction.
- `CONTRACT_MODULE_MAP.md`: contract-to-profile table.
- `tool/check_spec.dart`: local consistency check for contracts, vectors, and
  design tokens.

## Contracts

- `contracts/SPEC-001-discovery-versions.md`
- `contracts/SPEC-002-error-model.md`
- `contracts/SPEC-003-login-flow-discovery.md`
- `contracts/SPEC-004-login-session.md`
- `contracts/SPEC-006-room-model.md`
- `contracts/SPEC-007-event-model.md`
- `contracts/SPEC-008-send-message.md`
- `contracts/SPEC-009-room-list.md`
- `contracts/SPEC-010-timeline.md`
- `contracts/SPEC-011-basic-sync.md`
- `contracts/SPEC-020-media.md`

## Shared Design Tokens

- `design/theme.schema.json`
- `design/themes/smoke.json`

## Validation

Client implementations should validate request paths, response parsing, and
theme-token adapters against the contracts and test vectors in this repository.

Change contracts before implementation behavior when expected behavior changes.

Run the local consistency check before publishing or consuming changes:

```bash
dart tool/check_spec.dart
```

## Long-Term Role

This root should be published before any client implementation. It owns draft
contract profiles, canonical vectors, and platform-neutral theme files. Client
repositories should add native adapters and package metadata only after this
root passes its local checks.

## Local Checks

```bash
dart tool/check_spec.dart
```

## License

This specification root is licensed under the Apache License, Version 2.0. See
`LICENSE`.
