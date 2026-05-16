# Feature Profiles

Profiles are additive.

```text
core
  discovery, error model, identifiers, JSON conventions

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
  transfer capability lanes

full-client
  all MVP client features
```

A feature must not silently depend on a higher-level feature unless declared in
`MODULE_DEPENDENCIES.md`.
