# Module Dependencies

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
```

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
