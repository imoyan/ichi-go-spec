# SPEC-001: Discovery / Versions

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Expose the server's supported project API version and feature profiles.

## Scope

This endpoint is project-defined. It must not claim full Matrix homeserver
compatibility.

## Request

```text
GET /_ichi-go/client/versions
```

## MVP response fields

```json
{
  "project": "okomedev-ichi-go",
  "api_version": "0.1-draft",
  "compatibility_level": "level-1-csapi-subset",
  "features": ["core"]
}
```

## Client expectations

- Clients must parse the response as a JSON object.
- `project`, `api_version`, and `compatibility_level` must be non-empty strings.
- `features` must be an array of non-empty strings.
