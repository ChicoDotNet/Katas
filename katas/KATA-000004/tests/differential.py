# SPDX-License-Identifier: MIT
"""Independent set-based oracle for an original Erlang bitmask simulation."""
import itertools
import random
import subprocess
import sys

build = sys.argv[1] if len(sys.argv) > 1 else "/tmp/ninja-gossip-green"


def oracle(routes, limit=480):
    # Each driver's knowledge is a distinct Python set; do not mirror bitmasks.
    knowledge = [{i} for i in range(len(routes))]
    for minute in range(limit):
        at_stops = [route[minute % len(route)] for route in routes]
        pools = {}
        for station, known in zip(at_stops, knowledge):
            pools.setdefault(station, set()).update(known)
        knowledge = [pools[station] for station in at_stops]
        if all(len(known) == len(routes) for known in knowledge):
            return str(minute + 1)
    return "never"


cases = []
# Exhaustive 2-driver routes, each of length 1, 2, or 3, from 3 stop IDs.
routes = [
    list(route) for size in range(1, 4)
    for route in itertools.product(range(3), repeat=size)
]
cases.extend(([left, right] for left in routes for right in routes))
# Exhaustive 3-driver routes of length 2 from 3 stop IDs.
small_routes = [list(pair) for pair in itertools.product(range(3), repeat=2)]
cases.extend(([a, b, c] for a in small_routes for b in small_routes for c in small_routes))
# Seeded cases with 1-6 drivers, route lengths from 1 to 6.
rng = random.Random(20261017)
for _ in range(128):
    count = rng.randint(1, 6)
    cases.append([
        [rng.randrange(8) for _ in range(rng.randint(1, 6))]
        for _ in range(count)
    ])

assert len(cases) == 2378
stdin = "".join("|".join(",".join(map(str, route)) for route in case) + "\n" for case in cases)
run = subprocess.run(
    ["erl", "-noshell", "-pa", build, "-s", "gossip_cli", "main", "-s", "init", "stop"],
    input=stdin, capture_output=True, text=True, check=True, timeout=180,
)
observed = run.stdout.splitlines()
assert len(observed) == len(cases), (len(observed), len(cases), run.stderr)
for index, (scenario, actual) in enumerate(zip(cases, observed)):
    expected = oracle(scenario)
    assert actual == expected, (index, scenario, expected, actual)
print("PASS: 2378 independent differential simulations (1521+729+128)")
