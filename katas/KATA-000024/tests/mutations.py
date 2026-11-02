# MIT — mutation harness: only behaviorally rejected, successfully compiled mutants count.
import os, pathlib, shutil, subprocess, tempfile
ROOT = pathlib.Path(__file__).resolve().parents[1]
SOURCE = (ROOT / 'src/network.ts').read_text()
mutations = [
 ('wrong-follow-target', 'set.add(e.target);', 'set.add(e.user);'),
 ('private-inbox-leak', 'inboxes.set(e.to,', 'inboxes.set(e.from,'),
 ('reverse-feed-order', 'b.id - a.id', 'a.id - b.id'),
]
for name, original, replacement in mutations:
    if SOURCE.count(original) != 1:
        raise SystemExit(f'MUTANT {name}: target not unique')
    with tempfile.TemporaryDirectory(prefix='social-mutant-') as td:
        root=pathlib.Path(td)
        shutil.copytree(ROOT/'src', root/'src')
        shutil.copytree(ROOT/'tests', root/'tests')
        shutil.copy(ROOT/'tsconfig.json',root/'tsconfig.json')
        shutil.copy(ROOT/'package.json',root/'package.json')
        (root/'src/network.ts').write_text(SOURCE.replace(original,replacement))
        compiled=subprocess.run(['tsc','-p','tsconfig.json'],cwd=root,capture_output=True,text=True)
        if compiled.returncode:
            raise SystemExit(f'MUTANT {name} did not compile: {compiled.stderr} {compiled.stdout}')
        result=subprocess.run(['go','run','tests/oracle.go'],cwd=root,env={**os.environ,'SOCIAL_CASES':'MUTANT'},capture_output=True,text=True)
        if result.returncode == 0:
            raise SystemExit(f'MUTANT {name} SURVIVED: {result.stdout}')
        if 'mismatch case' not in result.stderr:
            raise SystemExit(f'MUTANT {name} died for wrong reason: {result.stderr}')
        print(f'MUTANT {name}: TypeScript compiled, Go oracle behaviorally rejected')
print('MUTANTS PASS: 3/3 compiled and behaviorally rejected')
