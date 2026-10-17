// SPDX-License-Identifier: MIT
import { Forth, evaluateProgram } from '../src/forth';
function eq(code: string, expected: number[]): void {
  const got = evaluateProgram(code);
  if (JSON.stringify(got) !== JSON.stringify(expected)) throw new Error(`ASSERT behavior ${code}: ${JSON.stringify(got)} !== ${JSON.stringify(expected)}`);
}
function error(code: string, message: string): void {
  try { evaluateProgram(code); }
  catch (e) { if (e instanceof Error && e.message.includes(message)) return; throw e; }
  throw new Error(`ASSERT expected error ${message}: ${code}`);
}
eq('1 2 + 8 3 - 5 4 *', [3, 5, 20]);
eq('1 2 SWAP OVER DROP', [2, 1]);
eq('6 DUP *', [36]);
eq('7 -3 / -7 3 /', [-2, -2]);
eq(': square dup * ; 5 square', [25]);
eq(': foo 5 ; : bar foo ; : foo 8 ; bar foo', [5, 8]);
eq(': dup 9 ; 2 dup', [2, 9]);
eq(': addone 1 + ; : addone addone 1 + ; 2 addone', [4]);
eq(': swap dup ; 3 swap', [3, 3]);
eq('3 4 : TWO 2 ; TWO +', [3, 6]);
eq('  1
 2	 + ', [3]);
eq('-12 3 /', [-4]);
error('+', 'underflow');
error('1 swap', 'underflow');
error('4 0 /', 'division by zero');
error('unknown', 'unknown word');
error(': 10 2 ;', 'invalid word name');
error(': temp 2', 'missing semicolon');
error('5 ;', 'unexpected semicolon');
error(': bad missing ;', 'unknown word');
error('9007199254740992', 'out of range');
error('9007199254740991 2 *', 'overflow');
const interpreter = new Forth();
const first = interpreter.evaluate('3 4');
if (JSON.stringify(first) !== '[3,4]' || JSON.stringify(interpreter.evaluate('+')) !== '[7]') throw new Error('ASSERT persistent stack');
console.log('PASS: 23 original Forth fixed cases and boundaries');
