# Matrix v1.18 / Appendices/common rules / identifiers, timestamps, namespacing, errors, and content URIs

Status: draft
Feature profile: core
Contract type: boundary
Matrix domain: Appendices/common rules
Primary reference: Matrix v1.18 / Appendices/common rules / identifiers, timestamps, namespacing, errors, and content URIs
Repository anchor: SPEC-031 Matrix Foundation Common Rules
Canonical: yes

## Purpose

Define the common Matrix v1.18 rules that other Matrix contracts depend on:
identifier grammar, timestamps, namespacing, Matrix error envelopes, content
URI grammar, and version-advertisement boundaries.

## Scope

This contract is Matrix-defined, not Houra-defined. It is the foundation for
later `/_matrix/**` endpoint contracts and must not change existing
`/_houra/client/**` behavior by itself.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/appendices/>
- Source: <https://spec.matrix.org/v1.18/client-server-api/>
- Checked at: 2026-05-09T23:53:16+09:00
- Timezone: Asia/Tokyo

## Identifier expectations

Implementations must validate Matrix identifiers before advertising endpoint
support that accepts or emits them.

Supported foundation identifiers:

- User IDs use a leading `@`, a localpart, `:`, and a server name.
- Room IDs use a leading `!`, an opaque id, `:`, and a server name.
- Room aliases use a leading `#`, an alias localpart, `:`, and a server name.
- Event IDs use a leading `$` and an opaque id. Event IDs that include a server
  name must keep the `:<server_name>` suffix intact.
- Server names may be DNS names, IPv4 addresses, IPv6 literals in brackets,
  and may include a port.
- Common namespaced identifiers, such as event types, must be non-empty,
  lowercase-oriented identifiers and must preserve the `m.` namespace for
  Matrix-defined behavior.
- `mxc://` content URIs must include a server name and an opaque media id.

Identifiers are protocol data, not display names. Clients may render friendly
labels, but parsers and servers must keep the original identifier string for
protocol decisions.

## Timestamp expectations

Matrix timestamps are integer milliseconds since the Unix epoch, excluding leap
seconds. Implementations must not emit fractional timestamp values in Matrix
protocol objects.

## Matrix error envelope

Matrix error responses use a JSON object with:

```json
{
  "errcode": "M_BAD_JSON",
  "error": "Malformed JSON payload."
}
```

Server expectations:

- `errcode` must be present and must be a non-empty string.
- `error`, when present, must be a human-readable string.
- `M_LIMIT_EXCEEDED` responses may include `retry_after_ms` as an integer.
- Endpoint-specific error contracts may require additional fields.

Client expectations:

- Clients must preserve the HTTP status code.
- Clients must preserve `errcode` when it is a non-empty string.
- Clients may expose `error` when it is a string.
- Clients must not require every Matrix error response to contain only these
  two fields.
- Clients must not treat Houra `code` as a Matrix `errcode`.

## Namespacing and deprecation gate

The `m.` namespace is reserved for Matrix-defined identifiers. Custom behavior
must use a non-`m.` namespace and should use reverse-DNS style names when it is
not defined by the Matrix specification.

Matrix version advertisement is gated by endpoint evidence:

- A server must not advertise a stable Matrix version until supported endpoint
  contracts, deprecated behavior required by that version, and representative
  vectors have passing implementation evidence.
- `SPEC-030` remains the versions endpoint contract; this contract defines the
  shared rules that determine whether advertising a version is safe.
- Unstable MSC behavior must not be advertised as stable Matrix v1.18 support.
