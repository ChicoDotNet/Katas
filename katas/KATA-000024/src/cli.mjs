// MIT — newline-delimited JSON protocol, one response per request.
import { createInterface } from 'node:readline';
import { evaluate } from '../dist/src/network.js';
for await (const line of createInterface({ input: process.stdin, crlfDelay: Infinity })) {
  try { process.stdout.write(JSON.stringify(evaluate(JSON.parse(line))) + '\n'); }
  catch (e) { process.stdout.write(JSON.stringify({ error: e instanceof SyntaxError ? 'invalid-json' : (e instanceof Error ? e.message : 'unknown') }) + '\n'); }
}
