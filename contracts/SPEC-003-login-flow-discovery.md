# SPEC-003: Login Flow Discovery

Status: draft
Feature profile: auth
Canonical: yes

## Purpose

Expose the login mechanisms a Houra-compatible server supports.

## Request

```text
GET /_houra/client/login
```

## MVP response fields

```json
{
  "flows": [
    {
      "type": "houra.login.password"
    }
  ]
}
```

## Client expectations

- Clients must parse the response as a JSON object.
- `flows` must be a non-empty array.
- Each flow must include a non-empty string `type`.
- The initial password flow type is `houra.login.password`.
