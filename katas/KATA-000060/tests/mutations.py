#!/usr/bin/env python3
"""Mutation orchestration only: independent reference models are written in Go."""
from pathlib import Path
import os
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
source = (root / 'src/grep.pl').read_text()
mutants = {
    'ignore_inversion': ("$matched = !$matched if $flags{'-v'};", "# $matched = !$matched if $flags{'-v'};"),
    'exact_as_substring': ("($haystack eq $folded_pattern)", "(index($haystack, $folded_pattern) >= 0)"),
    'omit_filename_prefix': ('($multi ? "$file:" : \'\')', "('')"),
    'ignore_file_names_only': ("if ($flags{'-l'}) {", "if ($flags{'-l'} && 0) {"),
    'ignore_case_broken': ("$flags{'-i'} ? ascii_fold($pattern) : $pattern", "$pattern"),
    'unicode_argv_undecoded': ('@ARGV = @decoded;', '# @ARGV = @decoded;'),
    'reject_dash_literal': ("!$literal_pattern && $pattern =~ /^-/", "$pattern =~ /^-/"),
}
with tempfile.TemporaryDirectory(prefix='ninja-grep-mutants-') as d:
    for name, (old, new) in mutants.items():
        if source.count(old) != 1:
            raise RuntimeError(f'{name}: mutation anchor count {source.count(old)}')
        path = Path(d) / f'{name}.pl'
        path.write_text(source.replace(old, new))
        syntax = subprocess.run(['perl', '-c', str(path)], cwd=root, capture_output=True, text=True)
        if syntax.returncode != 0:
            raise RuntimeError(f'{name}: invalid Perl syntax: {syntax.stderr}')
        env = os.environ.copy()
        env['KATA_GREP_IMPL'] = str(path)
        env['KATA_ORACLE_CASES'] = '240'
        native = subprocess.run(['perl', 'tests/native.t'], cwd=root, env=env, capture_output=True, text=True)
        # The bounded mutation sample MUST reach the child process.
        # Without env=env the oracle silently re-runs all 900 cases per mutant.
        oracle = subprocess.run([str(root / 'build/grep-oracle'), str(path)], cwd=root, env=env, capture_output=True, text=True, timeout=45)
        if native.returncode == 0 or oracle.returncode == 0:
            raise RuntimeError(f'{name} survived native={native.returncode} oracle={oracle.returncode}')
        print(f'PASS mutant {name}: Perl syntax valid, native rejected, independent Go rejected')
print(f'PASS {len(mutants)}/{len(mutants)} compiled/syntax-valid mutants rejected by both verifiers')
