# Houra 仕様ドキュメント 日本語入口

この directory は、日本語で Houra 仕様を読むための入口です。

英語の `contracts/SPEC-*.md`、`test-vectors/`、`design/` が正本です。
日本語ドキュメントは正本を置き換えませんが、実装採用者が仕様を読み違えないための
重要な reader surface として維持します。

## まず読むもの

- 実装採用者向けガイド: [`adoption-guide.md`](adoption-guide.md)
- release 前の日英確認: [`release-readiness.md`](release-readiness.md)
- Matrix v1.18 の読み方: [`matrix-v1-18.md`](matrix-v1-18.md)
- Matrix アプリ拡張境界: [`matrix-application-extension-boundary.md`](matrix-application-extension-boundary.md)

## 正本へのリンク

- 仕様の優先順位: [`../../SOURCE_OF_TRUTH.md`](../../SOURCE_OF_TRUTH.md)
- clean-room 方針: [`../../REFERENCE_POLICY.md`](../../REFERENCE_POLICY.md)
- 機能 profile: [`../../FEATURE_PROFILES.md`](../../FEATURE_PROFILES.md)
- contract と profile の対応: [`../../CONTRACT_MODULE_MAP.md`](../../CONTRACT_MODULE_MAP.md)
- API contract: [`../../contracts/`](../../contracts/)
- test vector: [`../../test-vectors/`](../../test-vectors/)
- design input: [`../../design/`](../../design/)

## 運用方針

日本語説明は英語正本と完全同期し続ける前提ではありません。通常の開発中は drift を許容し、
定期監視と release 前確認で補正します。

ただし、キリのいい version tag を切る前は、変更された contract、vector、design input、
adoption evidence、release note に対応する日本語説明を確認します。未確認のまま release する場合は、
blocker、PR の未解決事項、または follow-up issue として明示します。

Product MVP release candidate と Matrix v1.18 release candidate は確認観点を分けます。
Product MVP は `/_houra/client/**`、Product MVP UI surface、adoption evidence を中心に
確認します。Matrix v1.18 は `/_matrix/**` domain evidence、advertisement gate、
release notes evidence を中心に確認します。片方の evidence だけで他方の support claim を
広げません。

`SPEC-070` の account recovery / IdP login は Product MVP vNext の optional flow です。
現行 Product MVP happy path には含めず、server capability、UI surface adoption evidence、
token / authorization code / callback query の redaction 方針が揃うまで fail-closed として
扱います。

`SPEC-071` の media transfer は thumbnails、range request、resumable download の
optional flow です。現行 Product MVP happy path には含めず、media metadata capability、
UI surface adoption evidence、signed URL / local path / plaintext bytes の redaction 方針が
揃うまで fail-closed として扱います。encrypted attachment は `SPEC-072` 側で分けます。

`SPEC-072` の encrypted media attachment は metadata validation、ciphertext download /
decrypt handoff、missing / wrong key、redaction、recoverable error の optional flow です。
現行 Product MVP happy path には含めず、encrypted attachment capability、crypto-adapter
handoff evidence、trust copy、media key / room key / recovery key / plaintext bytes /
decrypted thumbnail の redaction 方針が揃うまで fail-closed として扱います。この flow だけで
encrypted-room や complete E2EE support claim は広げません。

`SPEC-126` の role projection は、Product MVP server が同一 subject を role / audience
ごとの allowlist で返すための境界です。server implementation evidence が揃うまで Product MVP
release readiness は広げず、UI role management、sample runner compatibility、enterprise RBAC
とは別の scope として扱います。

`SPEC-127` の PII redaction handoff は、Product MVP server が raw report を外部 handoff
候補にする前に classification、redaction、human approval、approved handoff を分けて扱うための
境界です。server implementation evidence が揃うまで Product MVP release readiness は広げず、
production external adapter delivery、legal PII taxonomy、client approval UI、sample runner
compatibility とは別の scope として扱います。

`SPEC-128` の multilingual handoff は、Product MVP server が canonical source language と
reviewed confirmed translation を分け、audience に出す translation を confirmed state に限定する
境界です。server implementation evidence が揃うまで Product MVP release readiness は広げず、
translation provider integration、automatic quality judgment、client review UI、sample runner
compatibility とは別の scope として扱います。

## 書き方

日本語ページは、GitHub の表示で読みやすいように短い段落とリンク中心にします。
巨大な表や英語正本の全文翻訳は避け、必要なときに該当する英語正本へリンクします。
