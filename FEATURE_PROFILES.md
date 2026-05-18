# Feature Profiles

Profiles are additive MVP feature slices. They are not the Matrix domain
taxonomy.

Each `contracts/SPEC-*.md` file also declares a machine-readable
`Matrix domain`. Use that second axis for Matrix Client-Server, Server-Server,
Room Versions, Olm & Megolm, Application Service, Identity Service, Push
Gateway, and release-evidence coverage. A Product MVP or Houra-only contract
uses `Matrix domain: none` unless it directly defines a Matrix compatibility
surface.

```text
core
  discovery, error model, identifiers, JSON conventions, optional Product MVP
  vNext WebRTC low-latency / fastest-tier connection planning and
  advertisement gates

auth
  login flow discovery, login, sessions, access tokens, optional Product MVP
  vNext account recovery and IdP login capability lanes

rooms
  room creation, join, and membership subset

events
  event model and persistence rules

messaging
  send message mutation endpoint

sync
  room list, timeline, incremental sync subset

media
  media metadata, upload, download subset, optional Product MVP vNext media
  transfer and encrypted attachment capability lanes

full-client
  all MVP client features
```

A feature must not silently depend on a higher-level feature unless declared in
`MODULE_DEPENDENCIES.md`.
