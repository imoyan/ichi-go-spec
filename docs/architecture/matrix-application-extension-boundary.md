# Matrix Application Extension Boundary

- Status: Accepted
- Scope: Architecture guidance
- Normative status: Non-contract guidance until promoted into `contracts/SPEC-*`

## Decision

Houra keeps its Matrix integration inside Matrix. Houra Core and the Houra
homeserver remain a Matrix-compatible event substrate; they are not extended
into a generic application execution platform.

For application integrations such as Gennai, GenAI, MCP, RAG, LLM Gateway,
audit logger, and job runtime, the default integration boundary is **Level 2:
standard Matrix event types plus optional namespaced metadata inside event
`content`**. Level 1 is preferred when standard Matrix events already cover
the use case. Level 3 (namespaced custom event types or custom state events)
is allowed only when Level 2 is not enough.

Level 2 is a client / bot / bridge / application-server extension, not a
homeserver extension. The homeserver does not interpret the metadata.

## Extension Levels

### Level 1: standard Matrix events only

Use only events already defined by Matrix. No application-specific fields
inside event `content`.

Typical events:

- `m.room.message`
- `m.notice`
- `m.reaction`
- media attachment events
- replies and relations

When ordinary chat, notifications, reactions, or file attachments are
sufficient, prefer Level 1.

### Level 2: standard event type with namespaced metadata

Use a standard Matrix event type (usually `m.room.message`). Keep `body`
human-readable so unsupported clients still display a usable message. Inside
`content`, add an optional, namespaced metadata object that application-aware
clients, bots, bridges, or application servers may interpret.

Example:

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

Level 2 rules:

- The event type remains a standard Matrix event type.
- `body` remains meaningful on its own without the metadata.
- The namespaced metadata is optional and safely ignorable.
- Unsupported clients still render a usable message.
- The homeserver does not interpret the metadata.
- The homeserver only stores, returns, and syncs the event as opaque content.
- Client extensions, bots, bridges, or external application servers may
  interpret the metadata.
- Authorization must not trust metadata alone. Policy must be re-checked
  using user, room, app, and operation context.
- Level 2 must not introduce custom homeserver routes.
- Level 2 must not require custom homeserver database behavior.
- Level 2 must not widen Matrix support advertisement.
- Namespaced metadata names such as `dev.houra.genai` are provisional unless
  later promoted to a public Houra contract.

### Level 3: namespaced custom event types or custom state events

Use a namespaced custom event type or a custom state event. This is only
appropriate when Level 2 cannot express the integration cleanly.

Example:

```json
{
  "type": "dev.houra.genai.task.request",
  "content": {
    "app_id": "document-summary",
    "input": "..."
  }
}
```

Level 3 rules:

- The event must still be valid Matrix event data.
- The homeserver still treats the event as opaque content.
- Level 3 must not require custom homeserver behavior.
- If humans need to see the event in a generic Matrix client, emit a
  companion `m.room.message` with a human-readable `body`.
- Compatibility risk is higher than Level 2: generic Matrix clients will not
  render custom event types.
- Promotion of Level 3 behavior into public Houra behavior requires a
  matching `SPEC-*` contract and test vectors first.

## Why Level 2 is the default

Level 2 keeps the Matrix surface clean while leaving room for application
behavior to grow at the client / bot / bridge / application-server layer:

- The Matrix event model stays standard, so federation, sync, and generic
  Matrix clients continue to work.
- Unsupported clients still render a usable message because `body` is
  meaningful.
- The homeserver stays small: it never has to learn application semantics.
- Application logic, policy, and integrations are owned by code outside the
  homeserver, where they can be replaced or scaled independently.
- Promotion to a public Houra contract is a focused change in `houra-spec`,
  not a homeserver fork.

## Server boundary

### Allowed in homeserver / Houra Core

- Storing and syncing standard Matrix events.
- Storing and syncing valid namespaced metadata as opaque event content.
- Exposing standard Matrix-compatible Client-Server behavior.
- Exposing Matrix Application Service behavior only when covered by the
  relevant contract.
- Preserving unknown content fields when the Matrix-compatible event model
  allows it.

### Not allowed in homeserver core

- Gennai-specific homeserver routes.
- MCP client execution.
- RAG search.
- LLM gateway behavior.
- AI job execution.
- Business authorization as a replacement for external policy.
- Audit log of record.
- Job queue or retry engine for application workflows.
- Source-of-truth behavior derived from integration samples.

## Client, bot, bridge, and application server responsibilities

These layers, not the homeserver, own application semantics:

- Interpret namespaced metadata inside Level 2 events.
- Recognize Level 3 custom event types when explicitly opted in.
- Run application workflows: prompt orchestration, tool selection, retries,
  approvals, scheduling.
- Re-check authorization using full context: user, room, app, operation,
  and external policy.
- Record audit log of record outside the homeserver.
- Talk to Gennai, GenAI, MCP, RAG, LLM Gateway, audit logger, and job
  runtime backends.

## Gennai, GenAI, and MCP position

Gennai, GenAI, MCP, RAG, LLM Gateway, audit logger, and job runtime
integrations are **application integrations**. They are not homeserver
responsibilities.

The default integration shape is:

```text
Matrix event
  -> client extension or bot
  -> bridge / application server
  -> Gennai AI app / MCP / RAG / LLM Gateway / audit logger
```

Integration samples may demonstrate this shape, but samples do not define
canonical Houra behavior. A working sample is not a contract.

## Promotion rule from sample to public contract

If an integration shape becomes public Houra behavior — referenced by
adoption evidence, depended on by implementation repositories, or advertised
to external users — it must first be promoted into `houra-spec` with:

- a matching `SPEC-*` contract in `contracts/`;
- the corresponding request and response fixtures in `test-vectors/`;
- any required UI surface and design input updates.

Until that promotion happens, namespaced metadata names such as
`dev.houra.genai` and any Level 3 type names remain provisional and may
change without a deprecation window.

## Non-goals

This document does not:

- add a new `SPEC-*.md` contract;
- add new test vectors;
- add or change homeserver routes;
- widen Matrix support advertisement, including
  `GET /_matrix/client/versions`;
- elevate `dev.houra.genai` to a stable public contract name;
- add Gennai, GenAI, MCP, RAG, or LLM Gateway implementation behavior;
- modify `houra-server`, `houra-client`, `houra-labs`, or
  `houra-integration-samples`.

## Security and policy notes

- Authorization decisions must not trust metadata alone. The metadata can
  be set by any client able to send the event.
- Policy must be re-checked from user, room, app, and operation context at
  the layer that acts on the metadata.
- Treat namespaced metadata as untrusted external input at the application
  layer.
- Do not place secret values (tokens, passwords, reset codes,
  authorization codes, IdP session identifiers) inside namespaced metadata.
  The same redaction rules that apply to evidence and logs apply here.
- Application logs and audit records of record must live outside the
  homeserver.
