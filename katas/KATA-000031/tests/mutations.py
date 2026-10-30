# SPDX-License-Identifier: MIT
import pathlib, subprocess, sys, tempfile
base = pathlib.Path(__file__).resolve().parent.parent
original = (base / 'src/yatzy.hpp').read_text()
mutants = [
 ('highest-pair-wrong', 'for (int face = 6; face >= 1; --face) if (counts[face - 1] >= n)', 'for (int face = 1; face <= 6; ++face) if (counts[face - 1] >= n)'),
 ('full-house-accepts-quintuple', 'if (counts[face - 1] == 2) exact_pair = face;', 'if (counts[face - 1] >= 2) exact_pair = face;'),
 ('small-straight-excludes-one', 'counts[5] == 0 && std::all_of', 'counts[0] == 0 && std::all_of'),
]
for name, old, new in mutants:
 assert original.count(old)==1, (name,'mutation target changed')
 with tempfile.TemporaryDirectory() as tmp:
  tmp=pathlib.Path(tmp);(tmp/'yatzy.hpp').write_text(original.replace(old,new))
  # main.cpp resolves header in same directory, ensuring mutant is compiled.
  (tmp/'main.cpp').write_text((base/'src/main.cpp').read_text())
  exe=tmp/'mutant'
  subprocess.run(['g++','-std=c++20','-O2','-Wall','-Wextra','-pedantic',str(tmp/'main.cpp'),'-o',str(exe)],check=True)
  result=subprocess.run(['go','run',str(base/'tests/oracle.go'),str(exe)],capture_output=True,text=True)
  if result.returncode==0: raise SystemExit(f'MUTANT SURVIVED: {name}')
  if 'category' not in result.stderr: raise SystemExit(f'MUTANT DID NOT REACH ORACLE: {name}: {result.stderr}')
  print('COMPILED MUTANT KILLED:',name, result.stderr.strip()[:160])
print('3/3 compiled C++20 mutants detected')
