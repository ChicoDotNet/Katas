#!/usr/bin/env python3
"""Guarded, idempotent single-record transition for KATA-000029."""
import json
import pathlib
import sys

if len(sys.argv) != 2:
    raise SystemExit('usage: apply_catalog_transition.py <catalog/candidates.json>')
path = pathlib.Path(sys.argv[1])
proposal = json.loads((pathlib.Path(__file__).resolve().parents[1] /
    'katas/KATA-000029/evidence/catalog-transition.json').read_text())
records = json.loads(path.read_text())
if not isinstance(records, list):
    raise SystemExit('unexpected catalog schema')
matched = [x for x in records if x.get('id') == proposal['expected']['id']]
if len(matched) != 1:
    raise SystemExit('missing or duplicated candidate ID')
record = matched[0]
for key in ('fingerprint', 'source_url'):
    if record.get(key) != proposal['expected'][key]:
        raise SystemExit(f'candidate {key} conflict')
changes = proposal['changes']
if record['status'] == 'green':
    if any(record.get(k) != v for k, v in changes.items()):
        raise SystemExit('existing GREEN metadata differs; manual reconciliation required')
    print('already applied, idempotent')
    sys.exit(0)
if record['status'] != 'discovered':
    raise SystemExit('unexpected candidate state')
record.update(changes)
path.write_text(json.dumps(records, ensure_ascii=False, indent=2) + '\n')
print('KATA-000029 discovered -> green (local proposal only)')
