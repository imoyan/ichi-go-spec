# Houra Product MVP / WebRTC Low-Latency Connection Boundary

Status: draft
Feature profile: core
Contract type: boundary
Matrix domain: none
Primary reference: Houra Product MVP / WebRTC Low-Latency Connection Boundary
Repository anchor: SPEC-140 Product MVP WebRTC Low-Latency Connection Boundary
Canonical: yes

## Purpose

Define the optional Product MVP vNext boundary for advertising WebRTC
low-latency connection optimization, including participant-count topology
planning, center-node selection, fair averaging, and same-LAN fast-path
selection.

This contract does not implement WebRTC media, data channels, TURN, STUN, SFU,
or peer relay runtime. It defines when Houra clients and servers may claim that
they can calculate and select a low-latency connection plan.

## Scope

This contract applies to first-party Product MVP real-time collaboration,
calling, or data-channel features that choose a WebRTC connection plan before
or during a session.

The current Product MVP baseline remains unchanged. Implementations must keep
WebRTC low-latency optimization hidden or disabled unless a selected server or
host adapter advertises the matching capability and same-candidate evidence
passes.

Matrix compatibility, Matrix media, Matrix E2EE, Matrix call events, VoIP
signaling, and Matrix version advertisement are out of scope.

## WebRTC reference snapshot

- WebRTC source: <https://www.w3.org/TR/webrtc/>
- WebRTC sections: `RTCConfiguration`, `RTCIceTransportPolicy`,
  `RTCBundlePolicy`, `RTCRtcpMuxPolicy`, and `RTCOfferOptions.iceRestart`
- WebRTC Stats source: <https://www.w3.org/TR/webrtc-stats/>
- WebRTC Stats sections: `RTCIceCandidatePairStats.currentRoundTripTime`,
  `availableOutgoingBitrate`, and `availableIncomingBitrate`
- Checked at: 2026-05-18T00:00:00+09:00
- Timezone: Asia/Tokyo

The reference snapshot is supporting context only. Browser support, platform
privacy behavior, and candidate exposure can differ by runtime, so an
implementation must prove behavior on the target runtime before advertising
support.

## Capability Advertisement

Servers or host adapters may advertise:

```json
{
  "webrtc_low_latency": {
    "supported": true,
    "modes": ["auto", "same-lan-fastest", "relay-safe"],
    "topologies": ["direct-pair", "small-mesh", "hub-spoke", "sfu-relay"],
    "max_participants": 12,
    "same_lan_fast_path": {
      "supported": true,
      "requires_user_opt_in": true,
      "private_address_redacted": true
    },
    "evidence_ref": "houra-client#example-webrtc-low-latency"
  }
}
```

If this object is missing, has `supported: false`, lacks a usable mode, or
lacks current evidence for the selected runtime, clients must fail closed and
must not render Product MVP low-latency optimization as supported.

Capability metadata must not contain private IP addresses, mDNS hostnames,
ICE ufrag/password values, TURN credentials, SDP bodies, raw candidate lines,
local interface names, MAC addresses, precise device identifiers, or network
provider logs.

## Optimization Modes

`auto` lets the implementation choose the best advertised topology from
participant count, candidate-pair measurements, uplink/downlink budget, CPU
budget, relay availability, and privacy constraints.

`same-lan-fastest` prefers direct host or local-network candidate-pair evidence
when the target runtime exposes enough information and the user or tenant
policy allows local-network discovery. It must fall back to `auto` or
`relay-safe` when local-network evidence is unavailable, private-address
exposure is blocked, or any participant is outside the trusted local network.

`relay-safe` prefers TURN or SFU relay paths when IP privacy, policy, NAT
failure, or unstable direct connectivity makes direct or mesh paths unsuitable.
It may have higher latency, so it must not be marketed as the fastest path
unless measured evidence for the session candidate proves that claim.

## Topology Planning

Topology planning must be deterministic from redacted inputs:

- participant count;
- per participant role and device class;
- candidate-pair class such as `host`, `srflx`, or `relay`, when available;
- measured current round-trip time;
- available incoming and outgoing bitrate, when available;
- estimated encode/decode or forwarding CPU budget;
- relay/SFU availability and policy;
- user or tenant privacy mode.

Suggested default planning:

- `2` participants: prefer `direct-pair` when policy allows direct candidates
  and candidate-pair evidence is healthy; otherwise use `relay-safe`.
- `3` to `4` participants: prefer `small-mesh` only when every participant has
  enough uplink, downlink, CPU, and stable candidate pairs; otherwise choose a
  relay topology.
- `5` or more participants: prefer `sfu-relay` or another host-owned relay
  topology. A full peer mesh must remain fail-closed unless same-candidate
  evidence proves that every participant can sustain it.

These thresholds are defaults, not universal limits. An implementation may use
stricter thresholds, but it must record why the selected plan is safe.

## Center-Node Selection and Fair Averaging

`hub-spoke` or client-assisted relay planning may select a center participant
only when the app explicitly supports that runtime role. A normal browser peer
must not be silently treated as a relay for other peers.

The center score must use redacted evidence:

- median RTT from the candidate center to other participants;
- maximum RTT from the candidate center to any participant;
- estimated uplink and downlink headroom;
- CPU and battery headroom;
- relay permission, metered-network policy, and host consent;
- session stability and reconnect history.

The selected center should minimize worst-case participant latency before
optimizing average latency. Tie-breaking may use lower average RTT, higher
uplink headroom, lower CPU pressure, or a stable host-owned relay. This avoids
making one participant consistently worse just because the global average is
slightly lower.

When no candidate center satisfies the safety thresholds, implementations must
choose `sfu-relay`, `relay-safe`, or fail closed rather than forcing a peer to
become the center.

## Same-LAN Fast Path

Same-LAN fastest mode is an explicit user-visible selection. It must not be the
only way to start a session.

An implementation may claim same-LAN fastest only when:

- all selected participants are in the same trusted local network or an
  equivalent trusted proximity policy;
- runtime permission and browser privacy behavior allow the needed local
  candidate evidence;
- measured candidate-pair RTT beats the relay fallback for the same candidate
  session;
- private addresses and raw candidate lines are redacted from logs, evidence,
  UI diagnostics, and issue comments; and
- fallback to relay-safe behavior is available if local connectivity fails.

If browser privacy behavior exposes only mDNS or redacted host candidates, the
implementation may still use actual connectivity results and WebRTC stats, but
must not infer or record private IP topology.

## Runtime Configuration Boundaries

Product MVP evidence may include selected `RTCConfiguration` policy values such
as `iceTransportPolicy`, `bundlePolicy`, `rtcpMuxPolicy`, `iceServers` count,
and `iceCandidatePoolSize`, but it must not include credentials or raw server
URLs that reveal private infrastructure.

Default low-latency browser configuration should prefer:

- `bundlePolicy: "max-bundle"` when compatible with the target runtime;
- `rtcpMuxPolicy: "require"`;
- `iceTransportPolicy: "all"` for direct or same-LAN modes when privacy policy
  allows it;
- `iceTransportPolicy: "relay"` for relay-safe privacy mode;
- bounded ICE restart when measured stats show stalled connectivity.

An implementation must not claim it can force the browser to choose an exact
candidate pair. It may request policy, provide ICE servers, observe selected
candidate-pair stats, and renegotiate or restart ICE within bounded retry
policy.

## Evidence Requirements

Low-latency optimization evidence must record:

- consumed `houra-spec` ref;
- implementation repo/app ref;
- target runtime and browser or native WebRTC engine;
- advertised mode and selected topology;
- participant count;
- redacted selected candidate-pair class;
- RTT summary: min, median, p95, and max;
- available bitrate summary when reported;
- center score inputs and selected center, if any;
- fairness result: worst-case participant latency and average latency;
- fallback plan and reason;
- verification command or manual acceptance reference;
- redaction confirmation for forbidden raw values.

Evidence must not record private IP addresses, mDNS hostnames, SDP bodies, raw
ICE candidates, ICE credentials, TURN credentials, bearer tokens, precise
device identifiers, MAC addresses, local interface names, or provider logs.

## Claim Boundary

Passing this contract does not widen:

- current Product MVP release readiness;
- Matrix compatibility;
- Matrix VoIP or call signaling support;
- Matrix media or E2EE support;
- `/versions` advertisement;
- guaranteed global lowest latency;
- TURN, STUN, SFU, or relay service availability;
- browser-specific local network permission behavior.

Any marketing copy that says "low latency", "same-LAN fastest", "automatic
topology optimization", or "best center selection" must cite current
implementation evidence for the same runtime and candidate release.

## Adoption Checklist

After this contract merges:

- use `houra-client#235` for optional UI controls and runtime evidence;
- create `houra-server` or host adapter work only if signaling, TURN, SFU, or
  capability metadata is needed;
- keep current Product MVP and Matrix claims fail-closed until implementation
  evidence names this contract and vector;
- update release-candidate evidence before using this capability in a public
  Product MVP support claim.
