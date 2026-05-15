# Matrix アプリ拡張境界

このページは、Houra が Matrix アプリ連携をどこまで homeserver の中で扱い、
どこから外側に逃がすかを記録します。英語の正本は
[`../architecture/matrix-application-extension-boundary.md`](../architecture/matrix-application-extension-boundary.md)
です。これは architecture guidance であり、まだ normative な
`contracts/SPEC-*` contract ではありません。

## 結論

Houra は homeserver をアプリ実行基盤へ拡張しない。
アプリ固有の意味は、可能な限り標準 Matrix イベントと無視可能な namespaced
metadata で表現する。
その metadata は client extension、bot、bridge、外部 application server が
解釈する。
homeserver はそれを opaque な Matrix event content として保存・同期するだけに
留める。
そのため、源内、GenAI、MCP などの連携では Level 2 を既定境界とする。

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
`body` は人間が読める内容にして、metadata を理解しない client でも意味が
通じる状態を保ちます。
`content` の中に、application が解釈する namespaced metadata を任意で
追加します。

例:

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
- metadata を解釈するのは、client extension、bot、bridge、外部 application
  server。
- 認可は metadata だけを信用しない。user / room / app / 操作内容を
  改めて policy 評価する。
- Level 2 は homeserver 独自 route を追加しない。
- Level 2 は homeserver 独自 DB 挙動を要求しない。
- Level 2 は Matrix support の advertisement を広げない。
- `dev.houra.genai` のような namespaced 名前は、`SPEC-*` への昇格が
  決まるまで provisional とする。

Level 2 は client / application 層の拡張であり、homeserver の拡張では
ありません。

### Level 3: namespaced custom event type / custom state event

Level 2 では表現が苦しい場合だけ使います。

例:

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

- Matrix event model が標準のままなので、federation・sync・一般 Matrix
  client がそのまま動く。
- `body` が意味を持つので、対応していない client でも message が
  読める fallback になる。
- homeserver は application 意味論を覚えなくて済み、Houra Core が小さく
  保たれる。
- application logic、policy、integration は homeserver の外側で持つので、
  差し替え・scale が独立する。
- `houra-spec` への昇格は、`SPEC-*` 1 本に閉じた変更にできる。
  homeserver fork にはならない。

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

- 源内固有の homeserver route。
- MCP client の実行。
- RAG 検索。
- LLM gateway 的挙動。
- AI job の実行。
- 外部 policy の代わりとなる business 認可。
- audit log of record。
- application workflow 用の job queue / retry engine。
- 連携 sample に由来する source-of-truth 挙動。

## Client / bot / bridge / application server の責務

homeserver ではなくこれらの層が担うこと:

- Level 2 event の namespaced metadata を解釈する。
- Level 3 custom event type を、明示的に opt-in した場合だけ扱う。
- application workflow を実行する。prompt 制御、tool 選択、再試行、
  承認、scheduling など。
- user / room / app / 操作内容と外部 policy を使って認可を再評価する。
- audit log of record を homeserver の外側に記録する。
- 源内、GenAI、MCP、RAG、LLM Gateway、audit logger、job runtime と
  通信する。

## 源内 / GenAI / MCP の位置づけ

源内、GenAI、MCP、RAG、LLM Gateway、audit logger、job runtime の連携は
application integration です。
homeserver の責務ではありません。

既定の流れ:

```text
Matrix event
  -> client extension or bot
  -> bridge / application server
  -> 源内 AI app / MCP / RAG / LLM Gateway / audit logger
```

連携 sample はこの流れを示すための例であり、Houra の正規の動作を定義する
ものではありません。動く sample があっても、それ自体は contract ではありません。

## sample から公開 contract への昇格ルール

ある連携形を Houra の公開動作にする場合 (adoption evidence で参照する、
実装リポジトリが依存する、外部利用者に対して advertise するなど)、
先に `houra-spec` に以下を追加します:

- `contracts/` に対応する `SPEC-*` contract。
- `test-vectors/` に対応する request / response fixture。
- 必要なら UI surface と design input の更新。

昇格されるまでは、`dev.houra.genai` などの namespaced 名前、および Level 3
の type 名は provisional のままです。互換性のための deprecation 期間なしに
変更されることがあります。

## 今回やらないこと

- 新しい `SPEC-*.md` contract を追加しない。
- 新しい test vector を追加しない。
- homeserver route を追加・変更しない。
- `GET /_matrix/client/versions` を含む Matrix support advertisement を
  広げない。
- `dev.houra.genai` を公開 contract の安定名として固定しない。
- 源内 / GenAI / MCP / RAG / LLM Gateway の実装挙動を追加しない。
- `houra-server` / `houra-client` / `houra-labs` /
  `houra-integration-samples` に変更を入れない。

## Security と policy

- 認可判断は metadata だけを信用してはいけません。metadata は event を
  送れる client なら誰でも書けます。
- metadata を実行する layer で、user / room / app / 操作内容と policy を
  改めて評価します。
- namespaced metadata は application 層では untrusted な外部入力として
  扱います。
- token、password、reset code、authorization code、IdP session 識別子
  などの secret を namespaced metadata に入れません。evidence や log と
  同じ redaction 方針を適用します。
- application の log と audit record of record は homeserver の外側で
  保持します。
