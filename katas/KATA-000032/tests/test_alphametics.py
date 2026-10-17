# SPDX-License-Identifier: MIT
import unittest
import os
import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/"src"))
from alphametics import solve as correct_solve,check_solution
from red_stub import solve as wrong_solve
solve=wrong_solve if os.environ.get("KATA_RED")=="1" else correct_solve

class AlphameticsTests(unittest.TestCase):
    def test_send_more_money(self):
        result=solve("SEND + MORE = MONEY")
        self.assertEqual({"S":9,"E":5,"N":6,"D":7,"M":1,"O":0,"R":8,"Y":2},result)
        self.assertTrue(check_solution("SEND + MORE = MONEY",result))
    def test_i_bb_ill(self):
        self.assertEqual({"I":1,"B":9,"L":0},solve("I + BB = ILL"))
    def test_simple_satisfiable(self):
        for puzzle in ["A + A = B","A + B = A","A + B + C = D"]:
            with self.subTest(puzzle=puzzle):
                self.assertTrue(check_solution(puzzle,solve(puzzle)))
    def test_unsatisfiable(self):
        for puzzle in ["AB + AB = AB","A + B = BA","ABCDEFGHIJ + K = ABCDEFGHIJ"]:
            with self.subTest(puzzle=puzzle):
                self.assertIsNone(solve(puzzle))
    def test_one_letter_zero_allowed(self):
        self.assertEqual(0,solve("A + B = A")["B"])
    def test_invalid_syntax(self):
        for puzzle in ["hi + bye = hello","ABC","A = B","A + B == C","A + 2 = C"]:
            with self.subTest(puzzle=puzzle):
                with self.assertRaises(ValueError):solve(puzzle)

if __name__=="__main__":unittest.main()
