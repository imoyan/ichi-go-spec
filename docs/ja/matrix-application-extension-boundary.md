# Houra integration samples の Matrix アプリ拡張境界

このページは、Houra 上にアプリ固有の意味を載せる sample 全体に
適用する境界方針を記録します。英語の正本は
[`../architecture/matrix-application-extension-boundary.md`](../architecture/matrix-application-extension-boundary.md)
です。これは architecture guidance であり、まだ normative な
`contracts/SPEC-*` contract ではありません。

## 結論

この境界は、源内や GenAI のためだけのものではありません。
Houra 上にアプリ固有の意味を載せるサンプル全体に適用します。

Houra は homeserver をアプリ実行基盤へ拡張しない。
アプリ固有の意味は、可能な限り標準 Matrix イベントと無視可能な
namespaced metadata で表現する。
その metadata は client extension、bot、bridge、外部 application server が
解釈する。
homeserver はそれを opaque な Matrix event content として保存・同期するだけに
留める。
そのため、integration samples 全体では Level 2 を既定境界とします。
源内、GenAI、MCP はその代表例であり、例外的な専用方針ではありません。

業務 application adapter、承認フロー、通知フロー、地図 / 位置情報 sample、
注文 / commerce workflow sample、evidence link / review history sample、
外部 system handoff sample なども同じ境界の対象です。

Level 1 は標準 Matrix イベントだけで足りる場合に優先します。
Level 3 は Level 2 で表現できない場合だけ使います。

## 3 つの Level

### Level 1: 標準 Matrix event だけを使う

普通の chat、通知、reaction、添付ファイルで足りる場合に選びます。
追加の application 固有 field は `content` に入れません。

Houra が前提にする標準的な Matrix の形:

- `m.room.message` と、その中で使う標準的な `msgtype` (`m.text`、
  `m.notice`、および `m.image` / `m.file` / `m.audio` / `m.video` などの
  media msgtype)。
- annotation を表す `m.reaction` event。
- 上記 event の `content` に含める `m.in_reply_to` や `m.relates_to`
  などの reply / relation 表現。

### Level 2: 標準 event type + namespaced metadata

`m.room.message` などの標準 event type をそのまま使います。
`body` は人間が読める内容にして、metadata を理解しない client でも
意味が通じる状態を保ちます。
`content` の中に、application が解釈する namespaced metadata を任意で
追加します。

汎用例:

```json
{
  "type": "m.room.message",
  "content": {
    "msgtype": "m.text",
    "body": "この依頼をレビューして",
    "dev.houra.app": {
      "kind": "task.request",
      "sample": "document-review",
      "mode": "async"
    }
  }
}
```

GenAI 系 sample 例:

```json
{
  "type": "m.room.message",
  "content": {
    "msgtype": "m.text",
    "body": "この文書を要約して",
    "dev.houra.genai": {
      "kind": "task.request",
      "app_id": "document-summary",
      "mode": "async"
    }
  }
}
```

Level 2 の決まり:

- event type は標準 Matrix event のまま。
- `body` は metadata なしでも意味が通る。
- metadata は optional で、安全に無視できる。
- 対応していない client でも、message として普通に表示される。
- homeserver は metadata を解釈しない。
- homeserver はその event を opaque な Matrix event content として
  保存・同期するだけ。
- metadata を解釈するのは、client extension、bot、bridge、外部
  application server。
- 認可は metadata だけを信用しない。user / room / app / 操作内容を
  改めて policy 評価する。
- Level 2 は homeserver 独自 route を追加しない。
- Level 2 は homeserver 独自 DB 挙動を要求しない。
- Level 2 は Matrix support の advertisement を広げない。
- `dev.houra.app` や `dev.houra.genai` のような namespaced 名前は、
  `SPEC-*` への昇格が決まるまで provisional とする。
- sample は demo のために provisional namespace を使ってよいが、
  その namespace は Houra の canonical 動作を定義しない。

Level 2 は client / application 層の拡張であり、homeserver の拡張では
ありません。

### Level 3: namespaced custom event type / custom state event

Level 2 では表現が苦しい場合だけ使います。

汎用例:

```json
{
  "type": "dev.houra.app.task.request",
  "content": {
    "sample": "document-review",
    "input": "..."
  }
}
```

GenAI 系例:

```json
{
  "type": "dev.houra.genai.task.request",
  "content": {
    "app_id": "document-summary",
    "input": "..."
  }
}
```

Level 3 の決まり:

- それでも valid な Matrix event data であること。
- homeserver は引き続き opaque に扱う。
- homeserver 独自挙動を要求しない。
- 人間が一般的な Matrix client で内容を見る必要があるなら、補助の
  `m.room.message` も並べて送る。
- 一般的な Matrix client は custom event type を render しないため、
  Level 2 よりも互換性 risk が高い。
- Level 3 を Houra の公開動作にする場合は、先に対応する `SPEC-*` contract
  と test vector を追加する。

## なぜ Level 2 を既定にするか

Level 1 はもっとも安全で、標準 Matrix event で足りるなら優先します。
ただし、Level 1 だけでは structured な application intent を載せにくい
場面があります。

Level 3 は機械可読性が高い反面、互換性 risk が増え、一般的な Matrix
client では役に立たなくなります。

Level 2 はその中間で、次の利点を同時に得られます:

- 人間向けの fallback が残る (`body` が読める)。
- 標準 Matrix event type のまま使える。
- 未対応 client でも基本的に動く。
- 対応 client は richer な application UI を出せる。
- bot や bridge は structured な意図を読み取れる。
- homeserver の挙動は変えなくて済む。
- application 固有処理を homeserver の外に出せる。

## Server の境界

homeserver / Houra Core が担当してよい範囲:

- 標準 Matrix event の保存と同期。
- 有効な namespaced metadata を opaque な event content として保存・同期。
- 標準 Matrix-compatible な Client-Server 挙動の提供。
- 既存 contract が covered している場合に限る Matrix Application Service
  挙動の提供。
- Matrix-compatible event model が許す範囲で未知の content field を
  保持する。

homeserver core に持ち込まない範囲:

- sample 固有の homeserver route。
- 源内固有の homeserver route。
- MCP client の実行。
- RAG 検索。
- LLM gateway 的挙動。
- AI job の実行。
- 業務 workflow の実行。
- 外部 policy の代わりとなる business 認可。
- audit log of record。
- application workflow 用の job queue / retry engine。
- 外部 system への公式 handoff 実行。
- 連携 sample に由来する source-of-truth 挙動。

## Client / bot / bridge / application server の責務

homeserver ではなくこれらの層が担うこと:

- Level 2 event の namespaced metadata を解釈する。
- Level 3 custom event type を、明示的に opt-in した場合だけ扱う。
- 対応 client では rich な rendering を提供する。
- 外部 application runtime を呼ぶ。
- 既存業務 system を adapter 越しに呼ぶ。
- 必要なら MCP server を呼ぶ。
- 必要なら RAG や LLM Gateway を呼ぶ。
- 進捗や結果を Matrix に書き戻すときは、可能な限り標準 Matrix event を
  使う。
- 認可・policy は homeserver の外で、user / room / app / 操作内容と
  外部 policy を使って再評価する。
- Matrix metadata を信頼できる authority として扱わない。
- 後続の contract と security review で明示されない限り、credentials、
  provider token、raw prompt、機微 runtime payload を event metadata に
  載せない。

## Application sample / integration sample の位置づけ

application sample と integration sample は homeserver の責務ではあり
ません。

対象は次のものを含みますが、これに限りません:

- 源内 / GenAI / AI app runner sample
- MCP 連携
- RAG 連携
- LLM Gateway 連携
- audit logger 連携
- job runtime 連携
- 既存業務 application adapter
- Java MVC strangler sample
- SPA 画面置き換え sample
- 承認 workflow
- 通知 workflow
- 地図 / 位置情報 sample
- 注文 / commerce workflow sample
- evidence link / review history sample
- 外部 system handoff sample

これらの sample は、人間向けの会話・state・通知・承認・evidence の表面を
Matrix event で表すことがあります。
ただしその application 固有の意味を解釈するのは、client extension、bot、
bridge、application server、または外部 system であり、homeserver core
ではありません。

既定の流れ:

```text
Matrix event
  -> client extension or bot
  -> bridge / application server
  -> 外部 application runtime / 既存 system / MCP / RAG / LLM Gateway / audit logger
```

源内 / GenAI 系の例:

```text
Matrix event
  -> client extension or bot
  -> bridge / application server
  -> 源内 AI app / MCP / RAG / LLM Gateway / audit logger
```

既存業務 application の例:

```text
Matrix event
  -> client extension or bot
  -> bridge / application server
  -> 既存業務 application adapter / BFF / legacy system
```

地図 / 位置情報 workflow の例:

```text
Matrix event
  -> client extension or bot
  -> bridge / application server
  -> 地図 provider / location service / 現場 workflow system
```

## sample から公開 contract への昇格ルール

sample は連携の形を示すための例であり、Houra の正規の動作を定義する
ものではありません。動く sample があっても、それ自体は contract では
ありません。

ある連携形を Houra の公開動作にする場合 (adoption evidence で参照する、
実装リポジトリが依存する、外部利用者に対して advertise するなど)、
先に `houra-spec` に以下を追加します:

- `contracts/` に対応する `SPEC-*` contract。
- `test-vectors/` に対応する request / response fixture。
- 必要なら UI surface と design input の更新。

昇格されるまでは、`dev.houra.app` や `dev.houra.genai` などの sample
metadata namespace、および Level 3 の type 名は provisional のままです。
互換性のための deprecation 期間なしに変更されることがあります。

## 今回やらないこと

- 新しい公開 `dev.houra.*` 互換 contract を定義しない。
- 新しい `SPEC-*.md` contract を追加しない。
- 新しい test vector を追加しない。
- 源内 / MCP / RAG / LLM Gateway 連携を実装しない。
- job runtime を実装しない。
- 既存業務 application adapter を実装しない。
- 地図 / 位置情報 workflow を実装しない。
- homeserver route を追加・変更しない。
- `GET /_matrix/client/versions` を含む Matrix support advertisement を
  広げない。
- server 側の AI 実行を追加しない。
- server 側の業務 workflow 実行を追加しない。
- server 側の業務認可を追加しない。
- server 側の audit log を追加しない。
- `houra-server` / `houra-client` / `houra-labs` /
  `houra-integration-samples` に変更を入れない。
- Qiita 等の外部記事 draft を作らない。

## Security と policy

- namespaced metadata は authority ではありません。user が手で metadata
  を書くことも可能です。
- bridge と application server は、信頼できる user / room / app /
  操作内容と外部 policy を使って認可を再評価します。
- namespaced metadata は application 層では untrusted な外部入力として
  扱います。
- provider credential、access token、secret、private key、未加工の
  規制対象データ、raw prompt、機微な runtime payload を sample metadata
  に載せないでください。
- audit log of record は Matrix の event history だけに依存せず、外部の
  audit system に保持します。
- Matrix room の membership を policy 入力にすることは可能ですが、
  機微な業務操作の最終的な policy 根拠としては使いません。これを許す
  場合は、別途 contract で明示的に境界を定義する必要があります。
