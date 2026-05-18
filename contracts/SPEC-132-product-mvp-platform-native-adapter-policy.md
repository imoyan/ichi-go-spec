# Houra Product MVP / Platform-native Adapter Policy

Status: draft
Feature profile: core
Contract type: boundary
Matrix domain: none
Primary reference: Houra Product MVP / Platform-native Adapter Policy
Repository anchor: SPEC-132 Product MVP Platform-native Adapter Policy
Canonical: yes

## Purpose

Define the Product MVP client adapter policy for choosing platform or OS
capabilities before adding first-party provider-specific integrations.

This contract does not implement location, map rendering, notifications,
secure storage, local models, cloud model APIs, or provider SDKs. It defines the
minimum selection and evidence boundary that `houra-client` must follow when a
Product MVP feature can use either a platform-native capability or an external
provider adapter.

## Scope

Platform-native adapter policy applies to first-party `houra-client` Product MVP
work that touches:

- location and map workflows;
- notifications, permission prompts, rendering, deep links, and background
  scheduling;
- secure storage, key material, and local secret handles;
- LLM, AI, model runtime, and provider handoff workflows;
- future device or platform capabilities that have equivalent OS-owned APIs.

The exported TypeScript client core must remain UI-free and
framework-independent. React Native, Expo, iOS, Android, platform permission,
secure-storage, background task, map rendering, notification, or model-runtime
details belong in the Expo adapter or in a host-owned adapter.

## Selection Rules

For first-party `houra-client` implementation, choose the platform-native path
when all of the following are true:

- the platform or OS capability exists for the target app runtime;
- the capability is documented and maintained enough for the release target;
- permission, privacy, battery, and background execution behavior are explicit;
- adoption evidence can be recorded without raw device data, prompt data,
  key material, provider secrets, local paths, or provider logs.

If the platform-native path is unavailable, immature, incompatible with the
release target, or unsuitable for privacy or permission reasons, the
implementation must either:

- fail closed and keep the capability unadvertised; or
- expose an explicit host-owned adapter boundary for the application to provide
  another provider, API, SDK, or runtime.

Provider overrides must not change the public Product MVP or Matrix claim by
themselves. They require separate capability evidence, redaction checks, and
release-gate approval before becoming a first-party support claim.

## Capability Boundaries

Location and map workflows:

- OS foreground location permission is the default first-party entrypoint.
- Background location requires explicit user permission and platform background
  mode evidence before adoption.
- Map rendering should use the platform-native map surface when one exists for
  the target runtime.
- If a target runtime has no suitable OS map surface, a map provider may be used
  only through a thin adapter that keeps provider keys, raw coordinates, local
  cache paths, and provider logs out of public evidence.

Notifications:

- OS notification permission, rendering, localization, deep links, action
  handling, background scheduling, and badge reconciliation are client or
  host-owned.
- Host-owned notification adapters may wrap platform notification APIs when the
  first-party app target needs an app-specific integration boundary.
- Push gateway delivery, vendor credentials, retry/backoff, provider rate
  limits, and provider errors remain server or gateway-owned.

Secure storage and key material:

- Platform secure storage, keychain, keystore, or equivalent OS-provided secret
  storage is the first-party preference.
- Raw keys, recovery secrets, private key material, secure-storage handles, and
  local secret paths must not appear in public responses, logs, or evidence.
- A custom storage provider is a host-owned adapter and must not be inferred
  from Product MVP or Matrix protocol behavior.

LLM and AI workflows:

- OS or platform-native model runtime is the first-party preference when it is
  available, documented, and suitable for the target feature.
- Cloud LLM APIs, self-hosted model servers, RAG systems, MCP-backed tools, and
  provider SDKs are allowed as host-owned or adapter-owned overrides.
- Raw prompts, raw model output, provider secrets, provider logs, model-local
  filesystem paths, and sensitive source payloads must not appear in public
  responses, logs, or evidence artifacts.
- This policy does not claim model quality, offline availability, safety
  evaluation, or provider delivery behavior.

## Evidence Artifact

Implementation evidence for this policy must record:

- the consumed `houra-spec` ref;
- the implementation ref;
- the target runtime and app adapter;
- the capability id;
- whether a platform-native path was available;
- whether the platform-native path was selected;
- whether a provider override was used;
- why a platform-native path was rejected when not selected;
- whether capability advertisement stayed fail-closed;
- whether forbidden raw values were absent from artifacts.

Evidence artifacts must not contain precise coordinates, raw sensor readings,
raw prompts, raw model output, bearer tokens, database URLs, provider secrets,
provider logs, key material, secure-storage handles, private local paths, or
provider cache keys.

## Claim Boundary

Passing this contract does not widen:

- Product MVP release readiness;
- Matrix compatibility or `/_matrix/client/versions` advertisement;
- location or map support;
- notification support;
- secure-storage or E2EE support;
- LLM, AI, model-provider integration, or model-quality claims;
- cloud provider, RAG, MCP, or external workflow delivery claims.

## Compatibility Boundaries

- Existing Product MVP contract behavior remains unchanged.
- Existing Matrix v1.18 support claims remain unchanged.
- This policy does not require implementation repositories to remove existing
  provider adapters.
- Future adoption should keep platform-native selection logic in the app or
  host adapter, not in the UI-free client core.
- If a feature needs provider-specific request shape, credential handling,
  caching, pricing, quota, or model-selection behavior, split that into a
  separate contract or implementation issue.

## Adoption Decision Checklist

After this contract merges:

- create `houra-client` follow-up issues against the merged `houra-spec` ref for
  Expo adapter evidence, location/map adapter boundaries, LLM/AI adapter
  selection, and provider override redaction / capability evidence;
- client adoption must prove platform-native selection, provider override
  separation, unsupported-platform fail-closed behavior, and redacted artifacts;
- README adoption evidence in `houra-client` must cite this contract, vector,
  implementation ref, verification commands, and a clean-room note;
- Product MVP readiness remains fail-closed unless a separate release candidate
  gate cites this evidence and all other blocking lanes pass.
