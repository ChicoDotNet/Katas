#!/usr/bin/env python3
"""Guarded idempotent local catalog update; never modifies remote dev directly."""
import json
import pathlib
import sys

if len(sys.argv) != 2:
    raise SystemExit('usage: python3 apply_catalog_proposal.py PATH_TO_catalog/candidates.json')
path = pathlib.Path(sys.argv[1])
proposal = json.loads(pathlib.Path(__file__).with_name('catalog-proposal.json').read_text())
items = json.loads(path.read_text())
assert isinstance(items, list)
matched = [item for item in items if item.get('id') == proposal['id']]
if len(matched) != 1:
    raise SystemExit('catalog candidate missing or duplicate')
item = matched[0]
if item.get('fingerprint') != proposal['expected_fingerprint']:
    raise SystemExit('candidate fingerprint changed: reconcile before applying')
if item.get('status') == proposal['status'] and item.get('development_complete') is True:
    print('already green; no changes')
    raise SystemExit(0)
if item.get('status') != proposal['expected_status']:
    raise SystemExit(f"candidate state changed to {item.get('status')}: reconcile first")
for key, value in proposal.items():
    if key not in ('id', 'expected_fingerprint', 'expected_status'):
        item[key] = value
path.write_text(json.dumps(items, indent=2, ensure_ascii=False) + '\n')
print('updated KATA-000027 to local green/development_complete; publication still pending')
