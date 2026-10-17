# OBS-026 — Immutable focus and breadcrumb-based reconstruction

A persistent tree zipper carries focus, parent context and siblings sufficient to rebuild the root without mutating previous versions. Check original tree preservation, navigation failures, and deep edits. A full-root direct-path editor is independent of the crumb-reassembly algorithm and therefore provides a useful differential oracle. Local observation only, no transfer-speed evidence.
