# SPDX-License-Identifier: MIT
"""Independent action-semantic validator for a water-jug state witness."""

def verify_witness(s, result):
    assert result['possible'], 'expected a solved witness'
    states, actions = result['states'], result['actions']
    assert len(states) == len(actions) == result['moves'] >= 1, 'inconsistent witness length'
    c1, c2 = s['cap1'], s['cap2']
    first = {'one': c1, 'two': 0} if s['start'] == 1 else {'one': 0, 'two': c2}
    assert states[0] == first, 'wrong mandatory first fill state'
    assert actions[0] == ('fill1' if s['start'] == 1 else 'fill2'), 'wrong mandatory first action'
    forbidden = (0, c2) if s['start'] == 1 else (c1, 0)
    for step, state in enumerate(states):
        x, y = state['one'], state['two']
        assert 0 <= x <= c1 and 0 <= y <= c2, ('out of range', step, state)
        assert (x, y) != forbidden, ('forbidden state', step, state)
        if step == 0:
            continue
        before = states[step - 1]
        a, b = before['one'], before['two']
        to2 = min(a, c2 - b)
        to1 = min(b, c1 - a)
        expected = {
            'fill1': (c1, b),
            'fill2': (a, c2),
            'empty1': (0, b),
            'empty2': (a, 0),
            'pour12': (a - to2, b + to2),
            'pour21': (a + to1, b - to1),
        }
        action = actions[step]
        assert action in expected, ('unknown action', step, action)
        assert (x, y) == expected[action], ('action/state mismatch', step, action, before, state)
        assert (x, y) != (a, b), ('no-op', step, action)
    goal = result['goal']
    assert goal in (1, 2), ('invalid goal bucket', goal)
    last = states[-1]
    assert last['one' if goal == 1 else 'two'] == s['target'], 'target not reached'
    assert result['other'] == last['two' if goal == 1 else 'one'], 'other amount inaccurate'
