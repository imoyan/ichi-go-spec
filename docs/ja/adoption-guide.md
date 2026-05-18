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

## Conformance report

実装リポジトリが vector runner や acceptance runner の結果を残す場合は、`SPEC-113` の
`conformance-report-v1` shape を使います。最低限、`houra-spec` ref / commit、実装 repo
ref、runner name / command、target profile、vector path、contract id、feature profile、
status、redacted failure detail、claim boundary を残します。

status は `pass`、`fail`、`skipped`、`blocked`、`out_of_scope` です。`skipped`、
`blocked`、`out_of_scope` は pass evidence ではありません。Product MVP release evidence や
Matrix advertisement に使う場合は、別の adoption / release gate が excluded behavior と
fail-closed 判断を説明している必要があります。

stale spec ref、unknown vector、unknown contract id、profile mismatch、unredacted failure
detail は report invalid として扱います。failure detail には bearer token、database URL、
signed URL、private local path、key material、plaintext payload を記録しません。

## Shared-core adoption evidence

`houra-labs` の shared-core 実験を実装リポジトリへ採用候補として戻す場合は、
`SPEC-114` の `shared-core-adoption-evidence-v1` shape を使います。これは
`SPEC-113` の conformance report だけでは足りない、artifact manifest、`abi_version`、
facade stability、binary size、startup、p95 `+10%` gate、secret-free diagnostics、
adapter-owned boundary、rollback-to-local-parser を残すための evidence です。

初期候補は Matrix versions request / response handling と Matrix / Houra error
envelope です。どちらも `houra-server` / `houra-client` の production TypeScript path を
置き換えるものではなく、`houra-labs` で evidence を集める段階では `lab-candidate` として
扱います。

`shared-adopted` は required dependency ではありません。実装リポジトリが採用するには
別途 focused adoption issue が必要で、Product MVP release、Matrix advertisement、
release readiness の claim はその issue と release gate が通るまで fail-closed のままにします。

## 実装側に残すもの

storage、SDK convenience API、secure storage、token persistence、retry policy、
deployment policy、framework-specific UI は実装リポジトリ側の責務です。
公開 contract に必要な場合だけ、このリポジトリに仕様として追加します。

## Product MVP vNext の account recovery / IdP login

`SPEC-070` は email verification、password reset、identity provider login の
Product MVP vNext contract / vector / UI surface を定義します。ただし、現行 Product MVP
release candidate の必須 happy path ではありません。

実装リポジトリで採用する場合は、先に `GET /_houra/client/login` の capability discovery、
`test-vectors/auth/product-mvp-account-recovery-*.json`、`product-mvp-email-verification-*`、
`product-mvp-password-reset-*`、`product-mvp-idp-login-*`、および
`design/ui-surfaces/product-mvp.json` の `product-mvp-account-recovery-vnext` flow を確認します。

server が capability を advertise していない場合、client は account recovery / IdP login
UI を隠すか disabled にし、未広告 endpoint を probe しません。採用 evidence には
advertised capability、consumer repo ref、screen/action mapping、recoverable error 表示、
duplicate-submit prevention、redaction 方針を残します。reset token、email verification
token、authorization code、callback query、IdP session identifier は記録しません。

この vNext flow は Matrix OAuth full support claim、Matrix auth full compliance、
`/_matrix/client/versions` advertisement を広げません。

## Product MVP vNext の media transfer

`SPEC-071` は thumbnails、range request、resumable download の Product MVP vNext
contract / vector / UI surface を定義します。ただし、現行 Product MVP release candidate
の必須 happy path ではありません。encrypted attachment は `SPEC-072` 側で分けて扱います。

実装リポジトリで採用する場合は、先に `SPEC-020` の media metadata に追加される
`transfer` capability、`test-vectors/media/product-mvp-media-transfer-*`、
`product-mvp-thumbnail-*`、`product-mvp-range-download-*`、
`product-mvp-resumable-download-*`、および `design/ui-surfaces/product-mvp.json` の
`product-mvp-media-transfer-vnext` flow を確認します。

media metadata が capability を advertise していない場合、client は thumbnail / range /
resume UI を隠すか disabled にし、HTTP header や CDN 挙動から support を推測しません。
採用 evidence には advertised metadata capability、consumer repo ref、screen/action
mapping、progress / retry / recoverable error 表示、duplicate-submit prevention、
redaction 方針を残します。signed URL、local filesystem path、plaintext media bytes、
media key、user data を含む cache filename は記録しません。

この vNext flow は Matrix Media Repository full breadth、encrypted media support、
`/_matrix/client/versions` advertisement を広げません。

## Product MVP vNext の encrypted media attachment

`SPEC-072` は encrypted media attachment の Product MVP vNext contract / vector /
UI surface を定義します。ただし、現行 Product MVP release candidate の必須 happy path
ではありません。encrypted-room support、complete E2EE support、Matrix v1.18 full
compliance の claim とは分けて扱います。

実装リポジトリで採用する場合は、先に `SPEC-020` の media metadata に追加される
`encrypted_attachment` capability、`test-vectors/media/product-mvp-encrypted-media-*.json`、
および `design/ui-surfaces/product-mvp.json` の `product-mvp-encrypted-media-vnext`
flow を確認します。

media metadata が capability を advertise していない場合、client は encrypted attachment
UI を隠すか disabled にし、`m.room.encrypted`、crypto stack selection、`SPEC-071`
transfer metadata、server media upload support から support を推測しません。採用 evidence
には advertised encrypted attachment capability、consumer repo ref、screen/action mapping、
crypto-adapter handoff、missing-key / wrong-key / redacted / recoverable-error state、
duplicate-submit prevention、bounded trust copy、redaction 方針を残します。bearer token、
signed URL、local filesystem path、media key、room key、recovery key、plaintext media
bytes、decrypted thumbnail、user data を含む cache filename は記録しません。

SDK core は metadata parser、request/response descriptor、redacted diagnostic shaping までに
留めます。encrypt/decrypt、media-key handling、secure storage、plaintext lifecycle、
preview/share/export policy は crypto adapter または host-owned boundary です。

## Platform-native-first adapter policy

`SPEC-132` は、`houra-client` の first-party 実装で OS / platform が提供する capability
を優先する方針を定義します。対象は location / map、notification、secure storage /
key material、LLM / AI runtime などです。

UI-free core SDK は React Native、Expo、iOS、Android、OS permission、background task、
map rendering、notification、model runtime に依存させません。これらは Expo adapter または
host-owned adapter に閉じます。

platform-native capability がない、未成熟、または permission / privacy 上不適切な場合は、
capability を fail-closed にするか、host/app 利用者が明示的に provider adapter を差し替える
境界として扱います。provider override はそれだけで Product MVP readiness、Matrix
compatibility、`/_matrix/client/versions` advertisement を広げません。

採用 evidence には platform-native path を選んだか、provider override を使ったか、未対応
platform を fail-closed にしたかを残します。ただし precise coordinates、raw sensor readings、
raw prompts、raw model output、provider secrets、provider logs、key material、secure-storage
handles、private local paths は記録しません。
