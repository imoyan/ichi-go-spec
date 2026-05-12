# 実装採用者向けガイド

このページは、`houra-server`、`houra-client`、`houra-labs` などの実装リポジトリが
`houra-spec` を採用するときの読み方をまとめます。

## 基本原則

実装リポジトリは peer であり、どれか 1 つの実装が正本になることはありません。
公開動作は `houra-spec` の英語 contract、test vector、design input を基準にします。

実装が変えたい公開動作がある場合は、先にこのリポジトリの contract または vector を更新します。
実装側だけで behavior を決めて、後から仕様へ逆輸入する流れは避けます。

## 採用時に見る場所

- API behavior: [`../../contracts/`](../../contracts/)
- request / response fixture: [`../../test-vectors/`](../../test-vectors/)
- feature profile: [`../../CONTRACT_MODULE_MAP.md`](../../CONTRACT_MODULE_MAP.md)
- UI surface: [`../../design/ui-surfaces/`](../../design/ui-surfaces/)
- theme token: [`../../design/themes/`](../../design/themes/)

## 採用 evidence

実装リポジトリが仕様変更を採用したら、README の `Implementation Adoption Reports` に
採用 evidence を残します。

詳細な implementation metrics は、まず実装リポジトリ側の issue / PR に残します。
`houra-spec` の adoption report は release-facing な要約とリンクを残す場所であり、
作業ごとの timing や Codex usage を重複して書く場所ではありません。

記録する内容は次を基本にします。

- `houra-spec` の ref
- 実装リポジトリの ref
- 実装 issue / PR
- 実行した verification command
- pass / fail と known gap
- clean-room 確認
- timing と outcome
- Codex usage は取得できる場合だけ。取得できない場合は推測せず `unavailable` として扱う
- Matrix や外部仕様に触れる場合は、source と `checked_at` をコピーせず、README と
  `contracts/SPEC-030-matrix-client-versions.md` の snapshot を参照する

## 実装側に残すもの

storage、SDK convenience API、secure storage、token persistence、retry policy、
deployment policy、framework-specific UI は実装リポジトリ側の責務です。
公開 contract に必要な場合だけ、このリポジトリに仕様として追加します。
