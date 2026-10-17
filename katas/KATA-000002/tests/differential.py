"""Independent Python reference oracle and seeded scenario suite."""
import json
import random
import subprocess
from pathlib import Path

PHP_SCRIPT=Path(__file__).resolve().parents[1]/'src'/'cli.php'

def expected(operations):
    balance=0
    ledger=[]
    for op in operations:
        amount=op['amount'] if op['type']=='deposit' else -op['amount']
        balance+=amount
        ledger.insert(0,f"{op['date']} | {'+' if amount>0 else ''}{amount} | {balance}")
    return 'Date | Amount | Balance\n'+'\n'.join(ledger) if ledger else 'Date | Amount | Balance'

def check(operations):
    process=subprocess.run(['php',str(PHP_SCRIPT)],input=json.dumps(operations),text=True,capture_output=True,check=True)
    assert process.stdout.rstrip('\n')==expected(operations), (operations,process.stdout,expected(operations))

rng=random.Random(20261017)
check([])
for _ in range(250):
    ops=[]
    for j in range(rng.randint(1,60)):
        ops.append({'date':f'{(j%28)+1:02d}/{(j%12)+1:02d}/2026','type':rng.choice(['deposit','withdraw']),'amount':rng.randint(1,100000)})
    check(ops)
invalid=subprocess.run(['php',str(PHP_SCRIPT)],input=json.dumps([{'date':'10/01/2026','type':'deposit','amount':0}]),text=True,capture_output=True)
assert invalid.returncode!=0
print('PASS: 251 independent differential scenarios + invalid input guard')
