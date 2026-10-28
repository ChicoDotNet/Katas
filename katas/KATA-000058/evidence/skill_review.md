# Ninja review — KATA-000058, 2026-10-28

Ninja v0.1.29 (`32cb01f2e088453762f5c79239d1f11e6991bf83`), conclusion: **confirmed**.

The separate independent-oracle decision surfaced a genuine locale-width issue: UTF-8 euro is three bytes but one visible Unicode character. Native C++ assertions and the Ruby Unicode-aware reference caught it before completion. A separate issue was that Ruby subprocess output was tagged ASCII-8BIT, requiring explicit UTF-8 interpretation for comparison. These are single-kata observations, not universal principles and not proof of Ninja causal improvement.

No Ninja modification. No independent review, no remote CI, no publication.
