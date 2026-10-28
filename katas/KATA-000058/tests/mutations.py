# SPDX-License-Identifier: MIT
# Compiled behavioral mutations; no mutation is considered killed by compiler failure.
from pathlib import Path
import subprocess, tempfile
src=Path(__file__).resolve().parents[1]/'src'/'ledger.hpp'
native=Path(__file__).resolve().parent/'native.cpp'
original=src.read_text()
mutants={
    'wrong-sort': ('return a.cents<b.cents;', 'return a.cents>b.cents;'),
    'wrong-decimal-separator': ("char sep=loc==Locale::US?',':'.';", "char sep=loc==Locale::US?'.':',';"),
}
with tempfile.TemporaryDirectory() as temp:
    root=Path(temp)
    for name,(before,after) in mutants.items():
        assert original.count(before)==1, (name,'ambiguous mutation')
        # Relative include from native.cpp resolves to sibling src under copied tree.
        (root/'src').mkdir(exist_ok=True)
        (root/'tests').mkdir(exist_ok=True)
        (root/'src'/'ledger.hpp').write_text(original.replace(before,after))
        (root/'tests'/'native.cpp').write_text(native.read_text())
        exe=root/name
        compile=subprocess.run(['g++','-std=c++20','-O1','-Wall','-Wextra','-Werror',str(root/'tests'/'native.cpp'),'-o',str(exe)],capture_output=True,text=True)
        if compile.returncode: raise RuntimeError(f'{name}: compilation failed, not a kill: {compile.stderr}')
        run=subprocess.run([str(exe)],capture_output=True,text=True)
        if run.returncode==0: raise RuntimeError(f'{name}: escaped native suite')
        if 'FAIL native' not in run.stderr: raise RuntimeError(f'{name}: unexpected failure: {run.stderr}')
        print(f'PASS mutant {name}: compiled, behaviorally rejected')
print(f'PASS compiled mutations: {len(mutants)}/{len(mutants)} killed')
