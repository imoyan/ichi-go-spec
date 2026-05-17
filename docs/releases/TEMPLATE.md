# Release Record Template

Copy this template to `docs/releases/<tag>.md` before cutting a pre-1.0 freeze
candidate, milestone release, Product MVP release candidate, Matrix
compatibility release candidate, or OSS publication readiness release. The
record is release evidence only; it does not create a tag and does not widen
Product MVP or Matrix support claims by itself.

## Release Identity

- Release tag or candidate ref: `<tag-or-commit>`
- Release kind: `Product MVP|Matrix compatibility|OSS publication|maintenance|neither`
- Source issue or PR: `<imoyan/houra-spec#...>`
- Checked at: `<YYYY-MM-DDTHH:MM:SS+09:00>`
- Recorder: `<person-or-agent>`

## Compatibility and Claim Boundary

- Compatibility classification: `breaking|additive|corrective`
- Claim impact: `Product MVP|Matrix|both|neither`
- Product MVP claim boundary:
  - Claimed: `<scope-or-none>`
  - Excluded: `<scope-or-none>`
- Matrix compatibility claim boundary:
  - Claimed: `<domains-or-none>`
  - Excluded: `<domains-or-none>`
- Advertisement decision:
  - Product MVP: `allowed|blocked|not-applicable`
  - Matrix: `allowed|blocked|not-applicable`

## Changed Inputs

List only inputs that changed between the previous release record and this
candidate. Use `none` when a category has no change.

| Category | Changed refs | Notes |
|---|---|---|
| Contracts | `none` |  |
| Test vectors | `none` |  |
| Design inputs | `none` |  |
| Supporting docs | `none` |  |
| Release evidence | `none` |  |

## Implementation Adoption Evidence

| Repository | Issue or PR refs | Consumed spec ref | Verification | Claim contribution |
|---|---|---|---|---|
| `houra-server` | `none` | `none` | `none` | `none` |
| `houra-client` | `none` | `none` | `none` | `none` |
| `houra-labs` | `none` | `none` | `none` | `none` |

Implementation repositories are evidence consumers only. They are not behavior
sources for this repository.

## Verification

| Command or check | Result | Evidence |
|---|---|---|
| `dart tool/check_spec.dart` | `pending` |  |
| `git diff --check` | `pending` |  |

## Known Exclusions and Blockers

- Product MVP exclusions: `none`
- Matrix compatibility exclusions: `none`
- Open blockers before tag: `none`
- Follow-up issues after tag: `none`

## Japanese Reader Surface

- Reviewed Japanese reader surface: `docs/ja/README.md`, `docs/ja/adoption-guide.md`, `docs/ja/release-readiness.md`
- Known Japanese drift: `none`
- Drift decision: `blocked|accepted-with-follow-up|not-applicable`

## Publication Notes

- Git tag creation: `not-started`
- GitHub Release creation: `not-started`
- Package or container publication: `not-started`
- Security reporting readiness: `not-started`
