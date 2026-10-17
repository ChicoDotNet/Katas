# SPDX-License-Identifier: MIT
"""Line-delimited JSON strings in, JSON digit mapping or null out."""
import json
import sys
from alphametics import solve
for line in sys.stdin:
    if line.strip():
        try: print(json.dumps(solve(json.loads(line)),sort_keys=True))
        except(ValueError,TypeError) as exc: print(json.dumps({"error":str(exc)}))
