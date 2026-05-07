# SPEC-003: Login Flow Discovery

Status: draft
Feature profile: auth
Canonical: yes

## Purpose

Expose the login mechanisms a Ichi-Go-compatible server supports.

## Request

```text
GET /_ichi-go/client/login
```

## MVP response fields

```json
{
  "flows": [
    {
      "type": "ichigo.login.password"
    }
  ]
}
```

## Client expectations

- Clients must parse the response as a JSON object.
- `flows` must be a non-empty array.
- Each flow must include a non-empty string `type`.
- The initial password flow type is `ichigo.login.password`.
