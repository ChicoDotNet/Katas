# KATA-000012 independent input-framing audit — 2026-10-29

- Original PR #69 head: `0c390ce2d1d92b6e683ba43ad912776ec8a8bea5`.
- Reproduced on the original Fortran CLI using GNU Fortran 14.2.0:
  - `printf '3 0\\n1 0 0 2 2\\n' | ./lights` returned `0 0`, exit 0.
  - `printf '3 1\\n1 0 0 2 2\\n2 0 0 2 2\\n' | ./lights` returned `9 9`, exit 0.
- Root cause: list-directed read discarded surplus fields and records after declared `m`.
- Correction: line-framed reads, explicit extra-field detection, trailing-record rejection; original core matrix algorithm unchanged.
- Required new gate: `bash tests/cli_contract.sh ./cli`: 1 valid case and 8 invalid cases.
- Full local `bash tests/run_all.sh` after correction: behavioral RED PASS; GREEN 22; CLI 1 accepted/8 rejected; Go oracle 2,074 PASS; mutants 3/3 detected; Go Vet PASS.
- Fortran record buffer 1,024 chars; pathological overlong input not proven safe. No third-party code or fixtures used. Ninja v0.1.29 unchanged; review observation remains bounded.
- Remote CI must rerun on the new exact HEAD; previous 33/33 success applies only to `0c390ce2d1d92b6e683ba43ad912776ec8a8bea5`.
