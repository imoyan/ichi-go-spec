# Contract Module Map

| Contract | Feature profile | Notes |
|---|---|---|
| SPEC-001 Discovery / Versions | core | Required by all clients |
| SPEC-002 Error model | core | Required by all server responses |
| SPEC-003 Login flow discovery | auth | Login UX and capability detection |
| SPEC-004 Login/session | auth | MVP session model |
| SPEC-006 Room model | rooms | First-party subset |
| SPEC-007 Event model | events | Message/state-like event model |
| SPEC-008 Send message | messaging | Depends on rooms/events |
| SPEC-009 Room list | sync | Query model |
| SPEC-010 Timeline | sync | Query model |
| SPEC-011 Basic sync | sync | Incremental update model |
| SPEC-020 Media | media | Upload/download metadata subset |
