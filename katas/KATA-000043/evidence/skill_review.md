# OBS-029 — Educational modular arithmetic versus real cryptography

For mathematics katas, prefer standard arbitrary-precision modular exponentiation to custom overflow-prone routines. Check input domains and independently verify both parties calculate the same modular result. Crucially, that mathematical agreement is **not** secure protocol validation: production Diffie–Hellman requires vetted parameters, subgroup checks, randomness, authentication and side-channel protections. This observation establishes no production security assurance or measurable Ninja transfer.
