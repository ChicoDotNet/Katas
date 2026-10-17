#!/usr/bin/env python3
"""Deterministic stdlib-only catalog, lifecycle and exploratory pilot gate.

No network access, external coding agent, or automatic source copying.
"""
from __future__ import annotations

import argparse
import json
import math
import statistics
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PERMISSIVE = {"Unlicense", "CC0-1.0", "MIT", "BSD-2-Clause", "BSD-3-Clause", "Apache-2.0"}
STAGES = ("discovered", "eligible", "selected", "red", "green", "verified", "published")
NEXT_STAGE = dict(zip(STAGES, STAGES[1:]))
NEXT_STAGE["blocked"] = "eligible"
ACTIVE = {"selected", "red", "green", "verified"}


class CatalogError(ValueError):
    """An invalid or unauditable catalog state."""


def load(name: str):
    return json.loads((ROOT / "catalog" / name).read_text(encoding="utf-8"))


def validate_records(cfg: dict, sources: list, candidates: list, holdouts: list) -> None:
    if cfg["planning_denominator"] <= 0 or sum(cfg["rubric_weights"].values()) != 100:
        raise CatalogError("invalid denominator or rubric")
    source_ids = [s["id"] for s in sources]
    if len(source_ids) != len(set(source_ids)):
        raise CatalogError("duplicate source")
    ids, fingerprints = set(), set()
    for c in candidates:
        required = ("id", "title", "source_id", "source_url", "fingerprint",
                    "domain", "difficulty_evidence", "score_evidence", "status", "license")
        if any(key not in c or c[key] in ("", None) for key in required):
            raise CatalogError(f"{c.get('id', '?')}: incomplete record")
        if c["id"] in ids or c["fingerprint"] in fingerprints:
            raise CatalogError(f"{c['id']}: duplicate ID or canonical fingerprint")
        ids.add(c["id"])
        fingerprints.add(c["fingerprint"])
        if c["source_id"] not in source_ids or not c["source_url"].startswith("https://"):
            raise CatalogError(f"{c['id']}: invalid source")
        if c["status"] not in (*STAGES, "blocked"):
            raise CatalogError(f"{c['id']}: unknown status")
        if type(c.get("difficulty")) is not int or not 0 <= c["difficulty"] <= 5:
            raise CatalogError(f"{c['id']}: invalid difficulty")
        if type(c.get("score")) not in (int, float) or not 0 <= c["score"] <= 100:
            raise CatalogError(f"{c['id']}: invalid score")
        rights = c["license"]
        if c["status"] not in ("discovered", "blocked"):
            if (rights.get("id") not in PERMISSIVE or rights.get("verified") is not True
                    or not rights.get("evidence_url", "").startswith("https://")):
                raise CatalogError(f"{c['id']}: unverified or incompatible rights")
            if c["score_evidence"] == "not_evaluated":
                raise CatalogError(f"{c['id']}: missing ranking evidence")
        if c["status"] in ("selected", "red", "green", "verified", "published"):
            if not c.get("language") or not c.get("language_rationale"):
                raise CatalogError(f"{c['id']}: missing language justification")
        evidence = c.get("evidence", {})
        if c["status"] in ("verified", "published"):
            for kind in ("red", "green", "ci", "oracle"):
                if not evidence.get(kind):
                    raise CatalogError(f"{c['id']}: missing {kind} evidence")
        if c["status"] == "published":
            if (evidence.get("skill_conclusion") not in
                    ("incorporated", "confirmed", "no_change", "rejected")
                    or not evidence.get("skill_review")):
                raise CatalogError(f"{c['id']}: missing skill review")

    holdout_ids = [h.get("id") for h in holdouts]
    if len(set(holdout_ids)) != len(holdout_ids):
        raise CatalogError("duplicate holdout ID")
    for h in holdouts:
        required = ("id", "baseline_passed", "ninja_passed", "baseline_seconds",
                    "ninja_seconds", "independent_oracle")
        if any(key not in h for key in required):
            raise CatalogError(f"invalid holdout {h.get('id')}")
        if (type(h["baseline_passed"]) is not bool or type(h["ninja_passed"]) is not bool
                or h["independent_oracle"] is not True
                or min(h["baseline_seconds"], h["ninja_seconds"]) <= 0):
            raise CatalogError(f"invalid holdout evidence: {h['id']}")


def workspace():
    cfg, sources, candidates, holdouts = (
        load(filename) for filename in ("experiment.json", "sources.json", "candidates.json", "holdouts.json")
    )
    validate_records(cfg, sources, candidates, holdouts)
    for c in candidates:
        if c["status"] in ("verified", "published"):
            keys = ["red", "green", "ci", "oracle"]
            if c["status"] == "published":
                keys.append("skill_review")
            for kind in keys:
                relative = c["evidence"][kind]
                if not isinstance(relative, str):
                    raise CatalogError(f"{c['id']}: invalid evidence path")
                path = (ROOT / relative).resolve()
                if not path.is_relative_to(ROOT) or not path.is_file():
                    raise CatalogError(f"{c['id']}: missing/unsafe evidence file {kind}")
    return cfg, candidates, holdouts


def target(cfg: dict, fraction: float) -> int:
    return math.ceil(cfg["planning_denominator"] * fraction)


def gate(cfg: dict, candidates: list, holdouts: list) -> dict:
    published = sum(c["status"] == "published" for c in candidates)
    required = target(cfg, cfg["pilot_fraction"])
    result = {"published": published, "pilot_target": required, "holdouts": len(holdouts)}
    if published < required:
        return {**result, "decision": "collecting"}
    ratios = [
        h["ninja_seconds"] / h["baseline_seconds"] for h in holdouts
        if h["baseline_passed"] and h["ninja_passed"]
    ]
    if (len(holdouts) < cfg["minimum_holdouts"]
            or len(ratios) < cfg["minimum_joint_passes"]):
        return {**result, "decision": "review_required", "joint_passes": len(ratios),
                "reason": "insufficient independent paired holdouts"}
    advantage = (sum(h["ninja_passed"] for h in holdouts)
                 - sum(h["baseline_passed"] for h in holdouts)) / len(holdouts)
    median_ratio = statistics.median(ratios)
    decision = ("continue_hardest_first" if advantage >= cfg["min_success_gain"]
                and median_ratio <= cfg["max_median_time_ratio"]
                else "rebalance_for_coverage")
    return {**result, "decision": decision, "success_gain": round(advantage, 5),
            "median_time_ratio": round(median_ratio, 5), "joint_passes": len(ratios),
            "note": "exploratory recommendation; human audit of bias/quality required"}


def next_task(cfg: dict, candidates: list, holdouts: list) -> dict:
    decision = gate(cfg, candidates, holdouts)
    if decision["decision"] == "review_required":
        return {"action": "gate_review", "gate": decision}
    active = [c for c in candidates if c["status"] in ACTIVE]
    if active:
        # Finish closest-to-verification work first; stable tie-break.
        c = sorted(active, key=lambda x: (-STAGES.index(x["status"]), x["id"]))[0]
        return {"action": "resume", "id": c["id"], "status": c["status"], "source_url": c["source_url"]}
    eligible = [c for c in candidates if c["status"] == "eligible"]
    if eligible:
        if decision["decision"] == "rebalance_for_coverage":
            coverage = Counter(c["domain"] for c in candidates if c["status"] == "published")
            eligible.sort(key=lambda c: (-(c["score"] + 20 / (1 + coverage[c["domain"]])),
                                         -c["difficulty"], c["id"]))
        else:
            eligible.sort(key=lambda c: (-c["difficulty"], -c["score"], c["id"]))
        c = eligible[0]
        return {"action": "start", "id": c["id"], "difficulty": c["difficulty"],
                "score": c["score"], "source_url": c["source_url"],
                "strategy": decision["decision"]}
    discovered = sorted((c for c in candidates if c["status"] == "discovered"),
                        key=lambda c: (-c["difficulty"], c["id"]))
    if discovered:
        c = discovered[0]
        return {"action": "audit_candidate", "id": c["id"], "source_url": c["source_url"],
                "warning": "provisional difficulty; verify rights and ranking before copying"}
    return {"action": "discover_candidates", "message": "catalog needs eligible candidates"}


def advance(candidate_id: str, status: str, args) -> dict:
    cfg, candidates, holdouts = workspace()
    item = next((c for c in candidates if c["id"] == candidate_id), None)
    if item is None:
        raise CatalogError("unknown candidate")
    if NEXT_STAGE.get(item["status"]) != status:
        raise CatalogError(f"invalid transition {item['status']} -> {status}")
    if status == "eligible":
        if (not args.license_id or not args.license_evidence
                or args.score is None or not args.score_evidence):
            raise CatalogError("eligibility requires rights and scoring evidence")
        item["license"] = {"id": args.license_id, "verified": True,
                           "evidence_url": args.license_evidence}
        item["score"] = args.score
        item["score_evidence"] = args.score_evidence
        if args.difficulty is not None:
            item["difficulty"] = args.difficulty
        if args.difficulty_evidence:
            item["difficulty_evidence"] = args.difficulty_evidence
    if status == "selected":
        if not args.language or not args.why:
            raise CatalogError("selection requires language and rationale")
        item["language"] = args.language
        item["language_rationale"] = args.why
    for kind in ("red", "green", "ci", "oracle", "skill_review"):
        value = getattr(args, kind)
        if value:
            item.setdefault("evidence", {})[kind] = value
    if args.skill_conclusion:
        item.setdefault("evidence", {})["skill_conclusion"] = args.skill_conclusion
    item["status"] = status
    validate_records(cfg, load("sources.json"), candidates, holdouts)
    (ROOT / "catalog/candidates.json").write_text(
        json.dumps(candidates, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    return {"id": candidate_id, "status": status,
            "note": "local state changed; publish evidence through reviewed PR"}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("validate", "report", "next", "gate", "advance"))
    parser.add_argument("candidate_id", nargs="?")
    parser.add_argument("--to", dest="status")
    parser.add_argument("--output")
    parser.add_argument("--language")
    parser.add_argument("--why")
    parser.add_argument("--license-id")
    parser.add_argument("--license-evidence")
    parser.add_argument("--score", type=float)
    parser.add_argument("--score-evidence")
    parser.add_argument("--difficulty", type=int)
    parser.add_argument("--difficulty-evidence")
    for name in ("red", "green", "ci", "oracle", "skill-review", "skill-conclusion"):
        parser.add_argument("--" + name)
    args = parser.parse_args()
    if args.command == "advance":
        if not args.candidate_id or not args.status:
            parser.error("advance needs candidate_id and --to")
        result = advance(args.candidate_id, args.status, args)
    else:
        cfg, candidates, holdouts = workspace()
        if args.command == "validate":
            result = {"valid": True, "candidates": len(candidates)}
        elif args.command == "gate":
            result = gate(cfg, candidates, holdouts)
        elif args.command == "next":
            result = next_task(cfg, candidates, holdouts)
        else:
            result = {"denominator_status": cfg["denominator_status"],
                      "targets": {phase["name"]: target(cfg, phase["fraction"])
                                  for phase in cfg["stages"]},
                      "counts": dict(Counter(c["status"] for c in candidates)),
                      "gate": gate(cfg, candidates, holdouts)}
    printed = json.dumps(result, indent=2, ensure_ascii=False)
    if args.output:
        dest = Path(args.output)
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text(printed + "\n", encoding="utf-8")
    print(printed)


if __name__ == "__main__":
    try:
        main()
    except (ValueError, KeyError, OSError) as exc:
        raise SystemExit(f"CATALOG ERROR: {exc}")
