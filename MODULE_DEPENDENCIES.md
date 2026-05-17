# Module Dependencies

This file describes dependency direction between MVP feature profiles only.
Matrix domain coverage is a separate contract metadata axis recorded as
`Matrix domain` in `contracts/SPEC-*.md` and `CONTRACT_MODULE_MAP.md`.
Federation, Application Service, Identity Service, Push Gateway, Room Versions,
Olm & Megolm, and release-evidence work should use that domain axis for
coverage and adoption tracking instead of treating `core` as an implementation
dependency bucket.

Allowed direction:

```text
core <- auth
core <- rooms
core <- events
rooms <- messaging
events <- messaging
events <- sync
rooms <- sync
core <- media
auth <- rooms
auth <- messaging
auth <- sync
auth <- media
```

`auth <- rooms`, `auth <- messaging`, `auth <- sync`, and `auth <- media` reflect
the bearer-token requirement on every authenticated endpoint defined by
`SPEC-006`, `SPEC-008`, `SPEC-009`, `SPEC-010`, `SPEC-011`, and `SPEC-020`. The
public token grammar is owned by `auth` (`SPEC-004`); higher-level features must
declare this dependency rather than rely on a hidden bearer-token convention.

Forbidden:

```text
auth -> sync
media -> sync
core -> any feature module
```

Rules:

- `core` must stay small.
- Feature modules must declare dependencies explicitly.
- No hidden dependency through database tables or generated client assumptions.
