# Security Policy

## Supported Scope

This repository is the canonical source for Houra contracts, test vectors,
design schemas, theme inputs, and platform-neutral UI surfaces.

Report issues here when they affect:

- public contract behavior in `contracts/SPEC-*.md`;
- canonical fixtures under `test-vectors/`;
- design schemas, theme inputs, or UI surface definitions under `design/`;
- release-readiness, advertisement, or evidence gates that could cause an
  implementation to claim unsupported behavior.

Implementation vulnerabilities in a server, client, SDK, package, deployment
artifact, or container image should be reported in the affected implementation
repository as well. If the implementation behavior reveals an ambiguity in this
specification root, open or reference a follow-up issue here before changing
the implementation contract.

## Reporting

For now, use a private GitHub security advisory or direct maintainer contact
when a report includes exploit details, credentials, private paths, tokens,
database URLs, registry credentials, or non-public deployment information.

Public GitHub issues are appropriate for contract ambiguities, missing vectors,
documentation drift, release-readiness gaps, and claim-boundary bugs that do
not expose private security details.

## Disclosure Handling

- Do not include raw secrets, bearer tokens, refresh tokens, database URLs,
  registry credentials, private local paths, or machine-specific environment
  values in reports, screenshots, logs, vectors, or release evidence.
- Keep Product MVP claims and Matrix compatibility claims separate. A security
  fix or evidence update must not widen advertised Matrix support unless the
  matching contract, vector, implementation evidence, and release note are
  present.
- If a report affects an implementation repository, track the implementation
  fix separately and reference the spec issue or PR that defines the public
  behavior boundary.
