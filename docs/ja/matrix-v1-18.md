# Matrix v1.18 の読み方

このページは、README の `Matrix v1.18 Compliance Matrix` を日本語で読むための補助です。

Matrix 関連の英語 contract と vector が正本です。このページは、それらをどの順で読むか、
どの claim を避けるかを説明します。

## 現在の位置づけ

Houra Product MVP と Matrix full compliance は別の目標です。

Matrix v1.18 対応は、domain ごとの evidence が揃った範囲だけを扱います。
Client-Server API、Server-Server API、Application Service API、Identity Service API、
Push Gateway API、Room Versions、Olm & Megolm、Appendices/common rules は別々に確認します。

## close-out snapshot

2026-05-13 時点では、#95 が Matrix v1.18 roadmap の親 issue です。#189 は
README の close-out snapshot を通じて、domain issue、implementation adoption refs、
release evidence の対応関係を読むための整理 lane です。

#97 から #101 の spec 側 contract / vector / gate 子 issue は完了済みとして扱えます。
ただし、それだけでは release support claim にはなりません。実 release candidate の
implementation refs と evidence bundle は #200 で追跡します。
`test-vectors/core/matrix-v1-18-release-evidence-current-blocked-bundle.json`
は現在の blocked bundle で、example bundle とは分けて実 implementation refs と
refs 不一致による fail-closed 判定を記録します。

`houra-server` と `houra-client` の #189 で列挙された adoption refs は閉じています。
一方で `houra-labs` の parser / shared-core 探索 issue は一部 open のままです。
これらは release candidate が shared-core artifact を evidence に含めない限り、
Matrix version advertisement の blocker ではありません。

#200 は current blocked bundle として、実 implementation refs と fail-closed の判断を
記録しました。#201 は `SPEC-068` の OAuth account-management adoption boundary を
記録し、full Matrix OAuth 2.0 support claim とは分けます。#202 が残る間は、#95 を
release-ready として読ませないでください。#97 から #101 も、pass/fail evidence
または blocked / out-of-scope の判断が #95 にリンクされるまでは、単なる spec
checklist 完了だけで close しません。

## 広告してよいこと

Matrix version や domain support は、contract、test vector、implementation evidence、
release note evidence が揃った範囲だけ広告します。

evidence がない場合は、対応済みとして広告せず fail-closed にします。
`GET /_matrix/client/versions` のような public advertisement は、release gate の対象です。

## 読む順番

1. README の `Matrix v1.18 Compliance Matrix`
2. `CONTRACT_MODULE_MAP.md` の該当 SPEC
3. 該当する `contracts/SPEC-*.md`
4. 対応する `test-vectors/**/*.json`
5. 実装採用 evidence

## 外部仕様の扱い

Matrix の外部仕様情報は、永続的な「現在値」として書きません。
source、version、`checked_at`、timezone を持つ dated snapshot として記録します。
