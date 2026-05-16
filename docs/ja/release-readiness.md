# Release 前の日英確認

このページは、キリのいい version tag を切る前に、日本語 reader surface を確認するための
checklist です。

英語の contract text は正本です。日本語は正本ではありませんが、採用者が release の意味を
理解するために重要です。

## 対象 release

次の release では、この checklist を release gate として扱います。

- `v0.X.0`
- `v1.0.0`
- 実装リポジトリが採用基準にする pre-release
- Matrix support や compatibility claim を含む release

## Checklist

確認対象の日本語 reader surface:

- [`README.md`](../../README.md) の日本語概要と release / adoption 関連説明
- [`docs/ja/README.md`](README.md)
- [`docs/ja/adoption-guide.md`](adoption-guide.md)
- [`docs/ja/matrix-v1-18.md`](matrix-v1-18.md)
- 変更した `contracts/SPEC-*.md` 内の短い Japanese reader note
- 変更した `design/` の UI surface / theme に対応する README または `docs/ja/` の説明

- 変更された `contracts/SPEC-*.md` が README または `docs/ja/` から辿れる
- 変更された `test-vectors/` の意味が日本語 guide から誤解なく読める
- `design/` の UI surface または theme 変更が、必要なら日本語 guide に反映されている
- Product MVP UI surface adoption evidence は、対象 `houra-spec` ref、consumer repo ref、
  screen / action mapping、duplicate-submit prevention、recoverable error display、
  accessibility 結果または blocker、acceptance flow coverage、redaction 方針を持つ
- `SPEC-070` を含む release candidate では、advertised capability、
  `product-mvp-account-recovery-vnext` flow coverage、reset token / email verification
  token / authorization code / callback query / IdP session identifier の redaction 方針が
  evidence に含まれている
- `SPEC-071` を含む release candidate では、advertised media metadata capability、
  `product-mvp-media-transfer-vnext` flow coverage、signed URL / local filesystem path /
  plaintext media bytes / media key / cache filename の redaction 方針が evidence に含まれている
- `SPEC-072` を含む release candidate では、advertised encrypted attachment capability、
  `product-mvp-encrypted-media-vnext` flow coverage、crypto-adapter handoff evidence、
  missing-key / wrong-key / redacted / recoverable-error state coverage、bounded trust copy、
  media key / room key / recovery key / signed URL / local filesystem path / plaintext media
  bytes / decrypted thumbnail / cache filename の redaction 方針が evidence に含まれている
- README の `Implementation Adoption Reports` と日本語説明が矛盾していない
- Matrix version、外部仕様、互換性 claim は source と `checked_at` を持つ snapshot として扱われている
- pre-1.0 の contract / vector / design input 変更は `breaking` / `additive` /
  `corrective` に分類され、breaking / deprecation の場合は replacement または
  out-of-scope 判断、migration note、affected implementation issue / PR、release
  notes evidence を持つ
- Product MVP release candidate は `/_houra/client/**` と Product MVP UI surface /
  adoption evidence の確認として扱い、Matrix v1.18 release candidate は
  `/_matrix/**` の domain evidence、advertisement gate、release notes evidence の
  確認として扱う
- Product MVP release candidate は `imoyan/houra-spec#190` と
  `test-vectors/core/product-mvp-release-candidate-plan.json` を確認し、
  `imoyan/houra-client#121`、`imoyan/houra-client#122`、`imoyan/houra-server#227`
  が対象 ref、commands、結果、blocker、claim boundary を記録するまで tag を切らない
- OSS 公開前には `test-vectors/core/oss-publication-readiness-plan.json` を確認し、
  `LICENSE`、`SECURITY.md`、GitHub Releases、GitHub topics、Context7、OpenSSF、
  package / container registry の順序と non-normative boundary が記録されている
  ことを確認する
- Houra Product MVP claim と Matrix compatibility claim は別々に扱われ、片方の
  evidence だけで他方の support claim を広げていない
- 未反映の日本語 drift がある場合は、release blocker、PR の未解決事項、または follow-up issue として明示されている
- `dart tool/check_spec.dart` が通る
- `git diff --check` が通る

## Drift の扱い

通常開発中の drift は許容します。ただし、release tag は英語正本と日本語 reader surface が
同じ commit で固定されるため、release 前には未確認 drift を棚卸しします。

drift が意図的な場合は、理由、blocker / non-blocker 判断、次回確認先を PR body、
release checklist、または follow-up issue に残します。記録先がない drift は release
blocker として扱います。

現時点では known untracked drift はありません。意図的に遅らせる日本語更新が出た場合は、
該当 PR body または follow-up issue に明示してから handoff します。
