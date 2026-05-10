# SPEC-066: Matrix v1.18 Release Readiness Gate

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Define the final readiness gate and tag sequence for an Houra release that
claims Matrix v1.18 stable-domain support.

## Scope

This contract is Matrix-defined, not Houra-defined. It defines readiness,
ordering, rollback, and non-advertisement decision criteria. It does not create
a release tag by itself and does not implement any Matrix endpoint behavior.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/>
- Release note: <https://matrix.org/blog/2026/03/26/matrix-v1.18-release/>
- Checked at: 2026-05-10T23:38:00+09:00
- Timezone: Asia/Tokyo

## Readiness checklist

A Matrix v1.18 release candidate is ready only when:

- `SPEC-062` domain coverage report exists for the same release ref;
- `SPEC-063` Complement-compatible lane has pass/fail evidence for the same
  release ref when homeserver support is claimed;
- `SPEC-064` advertisement gate passes for the exact advertised domains;
- `SPEC-065` release notes evidence template is complete;
- all supported domain implementation gates pass;
- all excluded domains have known-gap issues or explicit out-of-scope reasons;
- room versions are listed, including default room version;
- unstable MSCs are listed as excluded unless separately opted in;
- all release artifacts are secret-redacted.

## Tag and release ordering

The release process is:

1. Freeze the candidate refs for `houra-spec`, `houra-server`, and
   `houra-client`.
2. Run domain coverage and implementation evidence gates.
3. Run Complement-compatible lane for homeserver claims.
4. Run Matrix version advertisement gate.
5. Generate release notes from the evidence template.
6. Tag implementation repos.
7. Tag `houra-spec` with the evidence bundle ref.
8. Publish release notes only after all required tags point at the checked refs.

If any gate fails after a tag is created but before publication, do not publish
Matrix support claims. Create a follow-up issue, publish non-advertisement
notes if needed, and retag only after a new candidate passes all gates.

## Compatibility boundaries

- This contract defines release readiness only.
- Passing this contract does not itself implement or advertise Matrix support.
- Existing `/_houra/**` and `/_matrix/**` behavior stays available.
- After this spec PR is merged, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if shared-core artifacts
  become part of the release candidate.
