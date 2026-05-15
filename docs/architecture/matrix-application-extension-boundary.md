# Matrix Application Extension Boundary for Houra Integration Samples

- Status: Accepted
- Scope: Architecture guidance
- Normative status: Non-contract guidance until promoted into `contracts/SPEC-*`

## Decision

Houra application samples and integration samples use **Level 2** as the
default extension strategy.

Level 2 keeps Matrix event types standard and adds optional, namespaced
metadata inside event `content`. Homeservers do not interpret this metadata.
Clients, bots, bridges, or external application servers may interpret it.

This preserves the Matrix server boundary while still allowing
application-specific client surfaces such as task cards, approval buttons,
evidence links, workflow status, external-system handoff status,
map/location annotations, AI result cards, and integration status displays.

This boundary applies to Houra integration samples in general. Gennai,
GenAI, and MCP are examples; they are not the only scope. Business
application adapters, approval flows, notification flows, map/location
samples, order/commerce workflows, evidence-link and review-history
samples, and external-system handoff samples are all in scope.

Level 1 is preferred when standard Matrix events already cover the use
case. Level 3 (namespaced custom event types or custom state events) is
allowed only when Level 2 is not enough.

Level 2 is a client / bot / bridge / application-server extension, not a
homeserver extension. The homeserver does not interpret the metadata.

## Extension Levels

### Level 1: standard Matrix events only

Use only events already defined by Matrix. No application-specific fields
inside event `content`.

Standard Matrix shapes Houra builds on:

- `m.room.message` with standard `msgtype` values, including `m.text`,
  `m.notice`, and media msgtypes such as `m.image`, `m.file`, `m.audio`,
  and `m.video`.
- `m.reaction` events for annotations.
- Reply and relation content fields such as `m.in_reply_to` and
  `m.relates_to` inside the events above.

When ordinary chat, notifications, reactions, or file attachments are
sufficient, prefer Level 1.

### Level 2: standard event type with namespaced metadata

Use a standard Matrix event type (usually `m.room.message`). Keep `body`
human-readable so unsupported clients still display a usable message. Inside
`content`, add an optional, namespaced metadata object that application-aware
clients, bots, bridges, or application servers may interpret.

General example:

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

GenAI-style sample example:

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
- Namespaced metadata names such as `dev.houra.app` and `dev.houra.genai`
  are provisional unless later promoted to a public Houra contract.
- Samples may use provisional namespaces for demonstration, but those
  namespaces do not define canonical Houra behavior.

### Level 3: namespaced custom event types or custom state events

Use a namespaced custom event type or a custom state event. This is only
appropriate when Level 2 cannot express the integration cleanly.

General example:

```json
{
  "type": "dev.houra.app.task.request",
  "content": {
    "sample": "document-review",
    "input": "..."
  }
}
```

GenAI-style example:

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

Level 1 is the safest choice and should be used when standard Matrix events
are sufficient, but it often lacks structured application intent.

Level 3 is more machine-readable, but it raises compatibility risk and can
make ordinary Matrix clients less useful.

Level 2 is the preferred middle ground:

- a human-readable fallback remains available;
- standard Matrix event types remain in use;
- unsupported clients still work at a basic level;
- supported clients can render richer application UI;
- bots and bridges can read structured intent;
- homeserver behavior remains unchanged;
- application-specific processing stays outside the homeserver.

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

- Sample-specific homeserver routes.
- Gennai-specific homeserver routes.
- MCP client execution.
- RAG search.
- LLM gateway behavior.
- AI job execution.
- Business workflow execution.
- Business authorization as a replacement for external policy.
- Audit log of record.
- Job queue or retry engine for application workflows.
- Official external-system handoff execution.
- Source-of-truth behavior derived from integration samples.

## Client / bot / bridge / application server responsibilities

These layers, not the homeserver, own application semantics:

- Interpret optional namespaced metadata inside Level 2 events.
- Recognize Level 3 custom event types when explicitly opted in.
- Provide enhanced rendering when supported.
- Call external application runtimes.
- Call existing business systems through adapters.
- Call MCP servers when appropriate.
- Call RAG or LLM Gateway systems when appropriate.
- Send progress or result messages back to Matrix using standard Matrix
  events when possible.
- Re-check authorization and policy outside the homeserver using full
  context: user, room, app, operation, and external policy.
- Avoid treating Matrix metadata as trusted authority.
- Avoid placing secrets, provider tokens, raw prompts, or other sensitive
  runtime data into event metadata unless explicitly covered by a later
  contract and security review.

## Application sample / integration sample position

Application samples and integration samples are not homeserver
responsibilities.

This includes, but is not limited to:

- Gennai / GenAI / AI app runner samples
- MCP integrations
- RAG integrations
- LLM Gateway integrations
- audit logger integrations
- job runtime integrations
- existing business application adapters
- Java MVC strangler samples
- SPA screen replacement samples
- approval workflows
- notification workflows
- map / location samples
- order / commerce workflow samples
- evidence link / review history samples
- external system handoff samples

These samples may use Matrix events to expose human-facing conversation,
state, notification, approval, and evidence surfaces. However, the
application-specific meaning must be interpreted by client extensions,
bots, bridges, application servers, or external systems — not by the
homeserver core.

Default integration shape:

```text
Matrix event
  -> client extension or bot
  -> bridge / application server
  -> external application runtime / existing system / MCP / RAG / LLM Gateway / audit logger
```

Example for Gennai / GenAI:

```text
Matrix event
  -> client extension or bot
  -> bridge / application server
  -> Gennai AI app / MCP / RAG / LLM Gateway / audit logger
```

Example for an existing business application:

```text
Matrix event
  -> client extension or bot
  -> bridge / application server
  -> existing business application adapter / BFF / legacy system
```

Example for a map / location workflow:

```text
Matrix event
  -> client extension or bot
  -> bridge / application server
  -> map provider / location service / field workflow system
```

## Promotion rule from sample to public contract

Samples may demonstrate integration shapes, but samples do not define
canonical Houra behavior. A working sample is not a contract.

If an integration shape becomes public Houra behavior — referenced by
adoption evidence, depended on by implementation repositories, or
advertised to external users — it must first be promoted into `houra-spec`
with:

- a matching `SPEC-*` contract in `contracts/`;
- the corresponding request and response fixtures in `test-vectors/`;
- any required UI surface and design input updates.

Until that promotion happens, sample metadata namespaces such as
`dev.houra.app` and `dev.houra.genai`, and any Level 3 type names, remain
provisional and may change without a deprecation window.

## Non-goals

This document does not:

- define a new public `dev.houra.*` compatibility contract;
- add a new `SPEC-*` contract;
- add new test vectors;
- implement Gennai integration;
- implement MCP integration;
- implement RAG;
- implement an LLM Gateway;
- implement a job runtime;
- add custom homeserver routes;
- widen Matrix support advertisement, including
  `GET /_matrix/client/versions`;
- add server-side AI execution;
- add server-side business workflow execution;
- add server-side business authorization;
- add server-side audit logging;
- modify `houra-server`, `houra-client`, `houra-labs`, or
  `houra-integration-samples`;
- draft or publish external articles.

## Security and policy notes

- Namespaced metadata is not authority. A user may craft metadata manually.
- Bridges and application servers must re-check policy using trusted user,
  room, app, and operation context.
- Treat namespaced metadata as untrusted external input at the application
  layer.
- Do not place provider credentials, access tokens, secrets, private keys,
  raw regulated data, raw prompts, or other sensitive runtime payloads
  into sample metadata.
- Audit logs of record should live in an external audit system, not in
  Matrix event history alone.
- Matrix room membership may be an input to policy, but it must not be the
  final policy source for sensitive business operations unless a later
  contract explicitly defines that boundary.
