# SPDX-License-Identifier: MIT
"""Original alphametics solver: column-by-column carry and digit-injection pruning."""
from __future__ import annotations
import re

def solve(puzzle: str) -> dict[str, int] | None:
    """Solve a cryptarithm, or return None. Single-letter words may equal zero."""
    if not isinstance(puzzle,str): raise ValueError("puzzle must be a string")
    pieces=puzzle.split("=")
    if len(pieces)!=2: raise ValueError("exactly one equality is required")
    operands=[term.strip() for term in pieces[0].split("+")]
    output=pieces[1].strip()
    if len(operands)<2 or any(not re.fullmatch(r"[A-Z]+",w) for w in [*operands,output]):
        raise ValueError("expected WORD + WORD [ + WORD ... ] = WORD, uppercase")
    unique=set("".join(operands)+output)
    if len(unique)>10 or len(output)<max(map(len,operands)): return None
    nonzero={word[0] for word in (*operands,output) if len(word)>1}
    columns=max([len(output),*(len(w) for w in operands)])
    assigned:dict[str,int]={}
    used:set[int]=set()
    def search(col:int,carry:int,term:int,partial:int)->dict[str,int]|None:
        if col==columns:
            return dict(assigned) if carry==0 else None
        if term<len(operands):
            word=operands[term]
            if col>=len(word): return search(col,carry,term+1,partial)
            letter=word[-1-col]
            if letter in assigned: return search(col,carry,term+1,partial+assigned[letter])
            for digit in range(10):
                if digit in used or (digit==0 and letter in nonzero): continue
                assigned[letter]=digit;used.add(digit)
                answer=search(col,carry,term+1,partial+digit)
                used.remove(digit);del assigned[letter]
                if answer is not None:return answer
            return None
        total=partial+carry
        needed=total%10
        newcarry=total//10
        if col>=len(output):
            return search(col+1,newcarry,0,0) if needed==0 else None
        letter=output[-1-col]
        if letter in assigned:
            return search(col+1,newcarry,0,0) if assigned[letter]==needed else None
        if needed in used or (needed==0 and letter in nonzero):return None
        assigned[letter]=needed;used.add(needed)
        answer=search(col+1,newcarry,0,0)
        used.remove(needed);del assigned[letter]
        return answer
    return search(0,0,0,0)

def check_solution(puzzle:str,solution:dict[str,int])->bool:
    if solution is None:return False
    lhs,rhs=puzzle.split("=")
    words=[w.strip() for w in lhs.split("+")]
    target=rhs.strip()
    if any(solution.get(w[0])==0 for w in (*words,target) if len(w)>1):return False
    if len(set(solution.values()))!=len(solution) or any(d not in range(10) for d in solution.values()):return False
    def value(word:str)->int:
        return int("".join(str(solution[c]) for c in word))
    try:return sum(map(value,words))==value(target)
    except(KeyError,ValueError):return False
