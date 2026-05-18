# Matrix v1.18 / Identity Service API / validation provider delivery flows

Status: draft
Feature profile: core
Contract type: boundary
Matrix domain: Identity Service API
Primary reference: Matrix v1.18 / Identity Service API / validation provider delivery flows
Repository anchor: SPEC-094 Matrix Identity Validation Provider Delivery Boundary
Canonical: yes

## Purpose

Define a bounded Identity Service validation session and provider delivery
boundary for the `validation-session-provider-delivery-breadth` lane in
`SPEC-076`.

This contract lets implementation repositories record representative evidence
for email and MSISDN requestToken / submitToken behavior without claiming
production email or SMS provider operation, consent UI, invitation storage, or
Matrix version advertisement.

## Scope

This contract covers representative Matrix v1.18 Identity Service behavior:

- `POST /_matrix/identity/v2/validate/email/requestToken`;
- `POST /_matrix/identity/v2/validate/email/submitToken`;
- `POST /_matrix/identity/v2/validate/msisdn/requestToken`;
- `POST /_matrix/identity/v2/validate/msisdn/submitToken`;
- `client_secret` and `send_attempt` validation;
- provider delivery handoff artifact creation;
- token expiry rejection;
- incorrect-token rejection with `M_TOKEN_INCORRECT`;
- repeated submit idempotency boundary;
- provider bounce and timeout fail-closed evidence;
- bounded, redacted lifecycle artifacts.

It does not define real email or SMS provider credentials, provider retry
queues, browser fallback UI, consent UI, identity-service account registration,
terms acceptance, invitation storage, ephemeral invitation signing, homeserver
account-data persistence, or full Identity Service API advertisement.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/identity-service-api/#post_matrixidentityv2validateemailrequesttoken>
- Source: <https://spec.matrix.org/v1.18/identity-service-api/#post_matrixidentityv2validateemailsubmittoken>
- Source: <https://spec.matrix.org/v1.18/identity-service-api/#post_matrixidentityv2validatemsisdnrequesttoken>
- Source: <https://spec.matrix.org/v1.18/identity-service-api/#post_matrixidentityv2validatemsisdnsubmittoken>
- Parent contract: `SPEC-059`
- Gap inventory: `SPEC-076`
- Checked at: 2026-05-16T06:10:00+09:00
- Timezone: Asia/Tokyo

## Validation behavior

`requestToken` creates a validation session for either email or MSISDN after
checking `client_secret`, `send_attempt`, and the normalized destination shape.
The representative artifact may record that a provider handoff was queued, but
it MUST NOT include raw provider payloads, raw destination addresses, raw
tokens, local template paths, provider credentials, or delivery log bodies.

`submitToken` validates a session only when the tuple of `sid`,
`client_secret`, and token is accepted for the same medium. Incorrect tokens
MUST fail with `400` and `M_TOKEN_INCORRECT`. Expired sessions MUST fail with
`400` and `M_SESSION_EXPIRED`. Malformed submit-token payloads MUST fail with
`400` and `M_INVALID_PARAM`. Wrong client secrets, provider bounce, or provider
timeout states MUST fail closed and MUST NOT mark the session as validated.

Repeated submit for an already validated session MAY be treated as idempotent
success if the artifact records that no additional provider request was
generated.

Provider bounce and timeout cases are operational evidence only. They MUST NOT
claim production delivery support, provider retries, consent UI, locale
template completeness, or any external provider SLA.

## Resource and privacy bounds

Representative artifacts MUST be bounded:

- maximum canonical case bytes: 20480;
- maximum case count: 8;
- maximum session count: 4;
- maximum provider handoff count: 4;
- token TTL seconds: 900;
- send attempt max: 3;
- replay cache scope: `process`;
- replay cache max entries: 128;
- provider delivery operation: `handoff-only`;
- provider retry queue enabled: false;
- provider network delivery: false;
- raw identity token evidence: false;
- raw validation token evidence: false;
- raw client secret evidence: false;
- raw provider payload evidence: false;
- raw provider log evidence: false;
- raw 3PID evidence: false;
- local template path evidence: false;
- versions advertisement widened: false.

Implementations MUST fail closed when these bounds are missing or weakened.

## Evidence artifact

Each representative case records:

- `id`;
- `kind`: `email_request_token`, `email_submit_token`,
  `msisdn_request_token`, `msisdn_submit_token`, `expired_token`,
  `incorrect_token`, `malformed_token`, `repeated_submit`, `provider_bounce`,
  or `provider_timeout`;
- `request`: method and path;
- `status`;
- `errcode` when the result is a Matrix error;
- `medium`: `email` or `msisdn`;
- `session_state`: `issued`, `validated`, `expired`, `unchanged`, or
  `failed`;
- `provider_handoff`: `queued`, `not_generated`, `bounced`, or `timed_out`;
- `auth_proof`: `identity_token` or `none`;
- `redacted_fields`;
- `result`: `accepted`.

Artifacts MUST NOT store raw Identity Service tokens, validation tokens,
client secrets, full 3PID addresses, provider payloads, provider logs, local
template paths, provider credentials, database keys, or raw SMS/email content.
Redacted fields MAY identify which categories were removed so downstream
evidence can be audited without exposing secrets or user identifiers.

## Compatibility boundaries

- This contract does not widen `GET /_matrix/client/versions`.
- Identity Service API remains out of the current Matrix v1.18 advertisement
  until the release-evidence gate explicitly allows it.
- `SPEC-059` remains the representative Identity Service boundary. This
  contract narrows one `SPEC-076` lane for implementation adoption evidence; it
  does not complete Identity Service full breadth.
- Provider production operations, consent UI, invitation storage, ephemeral
  signing, account lifecycle, key rotation, and release advertisement lanes
  stay separate.
