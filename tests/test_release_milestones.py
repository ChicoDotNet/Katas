import unittest
from tools.release_milestones import assess

class ReleaseGateTests(unittest.TestCase):
    def test_before_threshold(self):
        self.assertEqual(assess(12,0)["next_milestone"],18)
        self.assertFalse(assess(17,0)["promotion_required"])
    def test_first_and_second(self):
        self.assertEqual(assess(18,0)["due_milestones"],[18])
        self.assertEqual(assess(36,18)["due_milestones"],[36])
        self.assertFalse(assess(19,18)["promotion_required"])
    def test_overdue(self):
        self.assertEqual(assess(54,18)["due_milestones"],[36,54])
    def test_pilot_independent(self):
        self.assertTrue(assess(90,90)["pilot_gate_due"])
        self.assertFalse(assess(90,90)["promotion_required"])
    def test_invalid(self):
        with self.assertRaises(ValueError): assess(12,18)

if __name__ == "__main__": unittest.main()
