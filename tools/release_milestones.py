#!/usr/bin/env python3
"""Report missing main promotions; never merge or certify GitHub CI."""
from __future__ import annotations
import argparse
import json
from pathlib import Path
INTERVAL = 18

def published_count(path: Path) -> int:
    if not path.is_file(): return 0
    data = json.loads(path.read_text(encoding="utf-8"))
    ids = [row["id"] for row in data if row["status"] == "published"]
    if len(ids) != len(set(ids)): raise ValueError("duplicate published IDs")
    return len(ids)

def assess(dev: int, main: int) -> dict:
    if min(dev, main) < 0 or main > dev: raise ValueError("invalid branch snapshot counts")
    due = [n for n in range(INTERVAL, dev+1, INTERVAL) if main < n]
    next_at = INTERVAL * (dev // INTERVAL + 1)
    return {"dev_published":dev,"main_published":main,"due_milestones":due,
            "promotion_required":bool(due),"next_milestone":next_at,
            "remaining_until_next":next_at-dev,"pilot_gate_due":dev >= 90}

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dev", type=Path, required=True)
    parser.add_argument("--main", type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(assess(published_count(args.dev),published_count(args.main)), indent=2))

if __name__ == "__main__": main()
