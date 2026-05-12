# Matrix v1.18 の読み方

このページは、README の `Matrix v1.18 Compliance Matrix` を日本語で読むための補助です。

Matrix 関連の英語 contract と vector が正本です。このページは、それらをどの順で読むか、
どの claim を避けるかを説明します。

## 現在の位置づけ

Houra Product MVP と Matrix full compliance は別の目標です。

Matrix v1.18 対応は、domain ごとの evidence が揃った範囲だけを扱います。
Client-Server API、Server-Server API、Application Service API、Identity Service API、
Push Gateway API、Room Versions、Olm & Megolm、Appendices/common rules は別々に確認します。

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
