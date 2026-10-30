#!/usr/bin/env python3
"""CLI encoding boundary tests, separate from the independent Go domain oracle."""
import base64
import subprocess
import sys

jar = sys.argv[1]
valid = base64.b64encode(b"project|Work").decode("ascii")
invalid_utf8 = base64.b64encode(bytes([0xff])).decode("ascii")
request = "\n".join([valid, "%%%INVALID%%%", invalid_utf8, ""])
proc = subprocess.run(["java", "-jar", jar], input=request, text=True, capture_output=True, check=True)
results = [base64.b64decode(line).decode("utf-8") for line in proc.stdout.splitlines()]
expected = ["OK", "ERR:encoding", "ERR:encoding"]
assert results == expected, f"CLI encoding contract: expected={expected}, got={results}"
print("CLI encoding contract: 3 inputs PASS (valid, malformed base64, invalid UTF-8)")
