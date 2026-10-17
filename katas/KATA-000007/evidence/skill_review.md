# OBS-008: move behavior toward protected domain state

Local verification complete; CI pending. The independently authored anemic LegacyOrder permits uncontrolled public field mutation, while the refactored Order exposes commands and read-only snapshots. The observable transition matrix and an independent Python model help prevent accidental changes to approvals, rejection, shipping, tax totals and terminal statuses.

Emerging, **not yet established**, guidance: locate invariants next to the data they protect, and test the transition graph rather than only happy-path DTO shapes. Preserving legacy behavior without an independent oracle can preserve bugs. This repeats the theme observed in Java Ugly Trivia (OBS-004), with a different domain/language; two exercises are insufficient for causal or universal claims.

Caveat: numeric overflow prevention, durable storage, authorization and real tax compliance are omitted. No claim of transfer or time gain yet.
