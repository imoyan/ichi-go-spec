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

- 変更された `contracts/SPEC-*.md` が README または `docs/ja/` から辿れる
- 変更された `test-vectors/` の意味が日本語 guide から誤解なく読める
- `design/` の UI surface または theme 変更が、必要なら日本語 guide に反映されている
- Product MVP UI surface adoption evidence は、対象 `houra-spec` ref、consumer repo ref、
  screen / action mapping、duplicate-submit prevention、recoverable error display、
  accessibility 結果または blocker、acceptance flow coverage、redaction 方針を持つ
- README の `Implementation Adoption Reports` と日本語説明が矛盾していない
- Matrix version、外部仕様、互換性 claim は source と `checked_at` を持つ snapshot として扱われている
- 未反映の日本語 drift がある場合は、release blocker、PR の未解決事項、または follow-up issue として明示されている
- `dart tool/check_spec.dart` が通る
- `git diff --check` が通る

## Drift の扱い

通常開発中の drift は許容します。ただし、release tag は英語正本と日本語 reader surface が
同じ commit で固定されるため、release 前には未確認 drift を棚卸しします。

drift が意図的な場合は、理由と次回確認先を release note または follow-up issue に残します。
