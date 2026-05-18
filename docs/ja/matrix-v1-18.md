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

2026-05-18T09:35:03+09:00 時点では、#95 が Matrix v1.18 roadmap の親 issue です。#189 は
README の close-out snapshot を通じて、domain issue、implementation adoption refs、
release evidence の対応関係を読むための整理 lane です。

#97 から #101 の spec 側 contract / vector / gate 子 issue は完了済みとして扱えます。
ただし、それだけでは release support claim にはなりません。実 release candidate の
implementation refs と evidence bundle は #200 で追跡します。
`test-vectors/core/matrix-v1-18-release-evidence-current-blocked-bundle.json`
は現在の blocked bundle で、example bundle とは分けて実 implementation refs と
refs 不一致による fail-closed 判定を記録します。
この bundle は `houra-spec` 39c3e98d8070dd86ef3440fe4a2f92fc9c2d0a89、
`houra-server` b3b3eb2d98b1eb924084f6f07a653a1c01b92b03、
`houra-client` b7c31882dbc17c35a25215990e8b0ab86f38f777 の same-candidate refs を
記録します。closed 済みの #200 から #202 は evidence / boundary record として扱います。

`houra-server` と `houra-client` の #189 で列挙された adoption refs は閉じています。
`houra-server#145` は、#133 を active blocker ではなく parent tracker として閉じ、
current release candidate では #135 から #142 を domain ごとの
release-scope decision として残しました。これにより、full-breadth gaps は未記録の
blocker ではなく、広告対象外の explicit current-candidate exclusion として読めます。
その後の issue sync では `houra-server` の open issue は #135 と #136 のみです。
#135 は PR #374 で Client-Server full-breadth rollup evidence を更新済み、#136 は
Server-Server / Complement full-breadth tracker として open 維持です。
`houra-client` と `houra-labs` には open issue / PR がありません。`houra-labs` の
#173 から #180 は shared-core / parser / capability / theme evidence として close 済みで、
release candidate が shared-core artifact を必須 evidence に含めない限り、Matrix
version advertisement の blocker ではありません。

#200 は current blocked bundle として、実 implementation refs と fail-closed の判断を
記録しました。#201 は `SPEC-068` の OAuth account-management adoption boundary を
記録し、full Matrix OAuth 2.0 support claim とは分けます。#202 は `SPEC-069` の
device-key query-only adoption boundary を記録し、full E2EE / Olm-Megolm support
claim とは分けます。#235 後の current blocked bundle は、#135 から #142 の
release-scope decisions をリンク済みです。ただし `GET /_matrix/client/versions` は
引き続き空の Matrix versions を返す fail-closed 状態です。#95 は、publishable な
Matrix support claim と domain evidence が揃うまで release-ready として読ませないで
ください。

`SPEC-073` は、`houra-server#135` の Client-Server full-breadth gap を
discovery / auth refresh / event history / room breadth / sync extensions /
media breadth / E2EE Client-Server breadth の lane に分ける inventory です。
これは実装完了や広告開始ではなく、current release candidate で Client-Server API を
広告対象外にする理由を issue-sized に保つための記録です。`houra-server#178` から
`houra-server#184` の closed tracker も runtime 対応完了ではなく release exclusion
evidence として扱い、sync query、sync delivery、sync section、membership listing、
room state event の順で contract / vector / server gate に昇格してから採用します。

`SPEC-074` は、`houra-server#136` の Server-Server full-breadth gap を
discovery / key / auth、transaction / PDU / EDU、event retrieval、join / knock /
leave / invite、directory / query、federation E2EE / media、policy / ACL /
signing、Complement breadth の lane に分ける inventory です。これは full federation
対応や Complement 全 pass の完了ではなく、代表的な federation smoke evidence と
full Matrix federation claim を分けるための記録です。

`SPEC-097` は、このうち discovery / key / auth lane の parser-only 子 contract です。
Federation version、key query lifecycle metadata、request-auth header shape は
`houra-labs#123` の shared-core 入力にできますが、DNS / TLS 実行、key cache persistence、
request signature verification、Server-Server API advertisement は引き続き別 evidence
待ちです。

`SPEC-075` は、`houra-server#137` の Application Service full-breadth gap を
registration / token lifecycle、transaction delivery、user / room query、
third-party network directory、ping / liveness、Client-Server extension、
bridge evidence の lane に分ける inventory です。これは Application Service API や
bridge protocol behavior の実装完了ではなく、`SPEC-058` の代表 subset と full
Application Service claim を分けるための fail-closed 記録です。

`SPEC-115` は、このうち Client-Server extension lane から切り出した server-runtime
boundary です。`as_token` identity assertion、namespace 内の `user_id` / `device_id`
masquerading、`ts` timestamp massaging を代表 runtime として扱いますが、
`m.login.application_service`、bridge admin、normal user auth bypass、Room Version auth
変更、Application Service API advertisement は扱いません。

`SPEC-116` は、同じ Client-Server extension lane の残りから virtual user `/sync`、
appservice directory visibility、virtual-user device metadata / bulk delete を代表
runtime として切り出す boundary です。legacy `/events`、cross-signing upload、full
sync fan-out、E2EE device-list trust、bridge behavior、Application Service API
advertisement は引き続き fail-closed です。

`SPEC-076` は、`houra-server#138` の Identity Service full-breadth gap を
service / account / terms、key / signature、lookup / privacy、validation /
provider delivery、bind / unbind lifecycle、invitation storage、ephemeral
signing、consent UI、release evidence の lane に分ける inventory です。これは
Identity Service API や external provider operation の実装完了ではなく、
`SPEC-059` の代表 boundary と full Identity Service claim を分けるための
fail-closed 記録です。

`SPEC-077` は、`houra-server#139` の Push Gateway full-breadth gap を
notify payload、pusher configuration、push rule evaluation、delivery retry、
privacy payload minimization、vendor provider credentials、client permission /
rendering、security / redaction、release evidence の lane に分ける inventory です。
これは Push Gateway API や production push provider / client notification support の
実装完了ではなく、`SPEC-060` の代表 boundary と full Push Gateway claim を分けるための
fail-closed 記録です。

`SPEC-078` は、`houra-server#140` の Room Versions full-algorithm gap を
stable-version metadata、event format、auth rules、state resolution、event
acceptance / rejection、room upgrade、federation、shared helpers、release evidence
の lane に分ける inventory です。これは full room-version algorithms や
domain-wide room-version advertisement の実装完了ではなく、`SPEC-040` から
`SPEC-044` の代表 subset と full Room Versions claim を分けるための fail-closed
記録です。

`SPEC-079` は、`houra-server#141` の Olm & Megolm full E2EE gap を
maintained crypto stack / local state ownership、device keys / device lists、
Olm to-device、Megolm room sessions、key backup / secret storage、verification /
cross-signing、encrypted media、cross-domain interaction、release evidence の lane
に分ける inventory です。これは full E2EE、local Olm/Megolm、verification、
cross-signing、secret-storage、key-backup、device trust support の実装完了ではなく、
`SPEC-050` から `SPEC-054`、`SPEC-069`、`SPEC-072` の代表 boundary と full
Olm & Megolm claim を分けるための fail-closed 記録です。

`SPEC-099` は、`SPEC-074` の transaction / PDU / EDU lane から切り出した
parser-only boundary です。transaction descriptor、PDU / EDU envelope、
canonical JSON input shape、per-PDU response metadata を扱いますが、event auth、
hash / signature verification、storage mutation、soft-fail policy、outbound
federation、Server-Server API advertisement は扱いません。

`SPEC-100` は、`SPEC-074` の directory / spaces / query / OpenID lane から
切り出した parser-only boundary です。public rooms、hierarchy、
directory/profile/generic query、OpenID userinfo response の shape を扱いますが、
remote network fetch、visibility decision、profile privacy policy、OpenID token
verification、rate limit、cache persistence、Server-Server API advertisement は
扱いません。

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
