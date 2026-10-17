# SPDX-License-Identifier: MIT
"""Mutation probes for the oracle itself, not for the production algorithm."""
from copy import deepcopy
from witness import verify_witness

scenario = {'cap1': 3, 'cap2': 5, 'target': 1, 'start': 1}
witness = {'possible': True, 'moves': 4, 'goal': 1, 'other': 5,
           'actions': ['fill1', 'pour12', 'fill1', 'pour12'],
           'states': [{'one': 3, 'two': 0}, {'one': 0, 'two': 3},
                      {'one': 3, 'two': 3}, {'one': 1, 'two': 5}]}
verify_witness(scenario, witness)
for position, wrong in [(0, 'fill2'), (1, 'fill2'), (2, 'empty2'), (3, 'pour21')]:
    mutated = deepcopy(witness)
    mutated['actions'][position] = wrong
    try:
        verify_witness(scenario, mutated)
    except AssertionError:
        continue
    raise AssertionError(f'Undetected mutated action at {position}: {wrong}')
mutated = deepcopy(witness)
mutated['states'][2] = {'one': 2, 'two': 3}
try:
    verify_witness(scenario, mutated)
except AssertionError:
    pass
else:
    raise AssertionError('Undetected mutated intermediate state')
print('PASS: valid witness and five deliberately corrupted witness mutants rejected')
