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

2026-05-14 時点では、#95 が Matrix v1.18 roadmap の親 issue です。#189 は
README の close-out snapshot を通じて、domain issue、implementation adoption refs、
release evidence の対応関係を読むための整理 lane です。

#97 から #101 の spec 側 contract / vector / gate 子 issue は完了済みとして扱えます。
ただし、それだけでは release support claim にはなりません。実 release candidate の
implementation refs と evidence bundle は #200 で追跡します。
`test-vectors/core/matrix-v1-18-release-evidence-current-blocked-bundle.json`
は現在の blocked bundle で、example bundle とは分けて実 implementation refs と
refs 不一致による fail-closed 判定を記録します。
この bundle は `houra-spec` ce587f202de77dade3eebb07b63a0a6b4908743b、
`houra-server` 3fa134955c9e0804adc9e4b54e6d90fb24631f77、
`houra-client` 0f330a14ad86d69ad4f147c7a5b6d1852c9c78f2 の same-candidate refs を
記録します。closed 済みの #200 から #202 は evidence / boundary record として扱います。

`houra-server` と `houra-client` の #189 で列挙された adoption refs は閉じています。
`houra-server#145` は、#133 を active blocker ではなく parent tracker として閉じ、
current release candidate では #135 から #142 を domain ごとの
release-scope decision として残しました。これにより、full-breadth gaps は未記録の
blocker ではなく、広告対象外の explicit current-candidate exclusion として読めます。
一方で `houra-labs` の parser / shared-core 探索 issue は一部 open のままです。
これらは release candidate が shared-core artifact を evidence に含めない限り、
Matrix version advertisement の blocker ではありません。

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
広告対象外にする理由を issue-sized に保つための記録です。

`SPEC-074` は、`houra-server#136` の Server-Server full-breadth gap を
discovery / key / auth、transaction / PDU / EDU、event retrieval、join / knock /
leave / invite、directory / query、federation E2EE / media、policy / ACL /
signing、Complement breadth の lane に分ける inventory です。これは full federation
対応や Complement 全 pass の完了ではなく、代表的な federation smoke evidence と
full Matrix federation claim を分けるための記録です。

`SPEC-075` は、`houra-server#137` の Application Service full-breadth gap を
registration / token lifecycle、transaction delivery、user / room query、
third-party network directory、ping / liveness、Client-Server extension、
bridge evidence の lane に分ける inventory です。これは Application Service API や
bridge protocol behavior の実装完了ではなく、`SPEC-058` の代表 subset と full
Application Service claim を分けるための fail-closed 記録です。

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
