import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
import kata_lab as lab

CFG = {
    "planning_denominator": 1000, "pilot_fraction": 0.0016,
    "minimum_holdouts": 30, "minimum_joint_passes": 10,
    "min_success_gain": 0.10, "max_median_time_ratio": 0.90,
    "rubric_weights": {"a": 100}
}
SOURCES = [{"id": "test"}]


def item(id="a", status="discovered", difficulty=5, fingerprint="fp"):
    return {
        "id": id, "title": "Kata", "source_id": "test",
        "source_url": "https://example.org/kata", "fingerprint": fingerprint,
        "domain": "test", "difficulty": difficulty,
        "difficulty_evidence": "evaluated", "score": 80,
        "score_evidence": "rubric result", "status": status,
        "license": {"id": "MIT", "verified": True,
                    "evidence_url": "https://example.org/LICENSE"},
        "language": "Julia", "language_rationale": "matrix computing",
        "evidence": {"red": "red.txt", "green": "green.txt", "ci": "ci.txt",
                     "oracle": "oracle.txt", "skill_review": "review.txt",
                     "skill_conclusion": "no_change"}
    }


class CatalogTests(unittest.TestCase):
    def test_empty_valid(self):
        lab.validate_records(CFG, SOURCES, [], [])

    def test_duplicate_concept_rejected(self):
        with self.assertRaisesRegex(lab.CatalogError, "duplicate"):
            lab.validate_records(CFG, SOURCES,
                                 [item("a"), item("b", fingerprint="fp")], [])

    def test_unknown_rights_ineligible(self):
        c = item(status="eligible")
        c["license"]["verified"] = False
        with self.assertRaisesRegex(lab.CatalogError, "rights"):
            lab.validate_records(CFG, SOURCES, [c], [])

    def test_missing_skill_review_blocks_publication(self):
        c = item(status="published")
        del c["evidence"]["skill_review"]
        with self.assertRaisesRegex(lab.CatalogError, "skill review"):
            lab.validate_records(CFG, SOURCES, [c], [])

    def test_hardest_first(self):
        cs = [item("easy", "eligible", 2, "a"),
              item("hard", "eligible", 5, "b")]
        self.assertEqual(lab.next_task(CFG, cs, [])["id"], "hard")

    def test_resume_before_new(self):
        cs = [item("hard", "eligible", 5, "a"),
              item("active", "red", 3, "b")]
        self.assertEqual(lab.next_task(CFG, cs, [])["id"], "active")

    def test_gate_holds_without_benchmarks(self):
        self.assertEqual(lab.gate(CFG, [item("a", "published"),
                                        item("b", "published", fingerprint="b")], [])["decision"],
                         "review_required")

    def test_hardest_first_continues_on_transfer_and_speed_gains(self):
        cs = [item("a", "published"), item("b", "published", fingerprint="b")]
        tests = [{"id": str(i), "baseline_passed": i < 21, "ninja_passed": i < 27,
                  "baseline_seconds": 100, "ninja_seconds": 80,
                  "independent_oracle": True} for i in range(30)]
        lab.validate_records(CFG, SOURCES, cs, tests)
        self.assertEqual(lab.gate(CFG, cs, tests)["decision"],
                         "continue_hardest_first")

    def test_rebalance_if_no_transfer_gain(self):
        cs = [item("a", "published"), item("b", "published", fingerprint="b")]
        tests = [{"id": str(i), "baseline_passed": True, "ninja_passed": True,
                  "baseline_seconds": 100, "ninja_seconds": 80,
                  "independent_oracle": True} for i in range(30)]
        self.assertEqual(lab.gate(CFG, cs, tests)["decision"],
                         "rebalance_for_coverage")


if __name__ == "__main__":
    unittest.main()
