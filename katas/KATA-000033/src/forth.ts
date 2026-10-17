// SPDX-License-Identifier: MIT
// Original, bounded Forth interpreter: compilation freezes referenced words.
type Primitive = '+' | '-' | '*' | '/' | 'dup' | 'drop' | 'swap' | 'over';
type Instruction = { kind: 'push'; value: number } | { kind: 'primitive'; op: Primitive };
const operations = new Set<Primitive>(['+', '-', '*', '/', 'dup', 'drop', 'swap', 'over']);

export class ForthError extends Error {}

export class Forth {
  private readonly stack: number[] = [];
  private readonly definitions = new Map<string, readonly Instruction[]>();

  private resolve(raw: string): Instruction[] {
    const token = raw.toLowerCase();
    if (/^-?[0-9]+$/.test(token)) {
      const value = Number(token);
      if (!Number.isSafeInteger(value)) throw new ForthError('integer out of range');
      return [{kind: 'push', value}];
    }
    const definition = this.definitions.get(token);
    if (definition) return [...definition];
    if (operations.has(token as Primitive)) return [{kind: 'primitive', op: token as Primitive}];
    throw new ForthError('unknown word: ' + token);
  }

  private execute(instructions: readonly Instruction[]): void {
    for (const instruction of instructions) {
      if (instruction.kind === 'push') {
        this.stack.push(instruction.value);
        continue;
      }
      const op = instruction.op;
      const needed = op === 'dup' || op === 'drop' ? 1 : 2;
      if (this.stack.length < needed) throw new ForthError('stack underflow');
      if (op === 'dup') { this.stack.push(this.stack[this.stack.length - 1]); continue; }
      if (op === 'drop') { this.stack.pop(); continue; }
      if (op === 'swap') {
        const top = this.stack.pop()!;
        const below = this.stack.pop()!;
        this.stack.push(top, below);
        continue;
      }
      if (op === 'over') { this.stack.push(this.stack[this.stack.length - 2]); continue; }
      const b = this.stack.pop()!;
      const a = this.stack.pop()!;
      if (op === '/' && b === 0) throw new ForthError('division by zero');
      const result = op === '+' ? a + b : op === '-' ? a - b : op === '*' ? a * b : Math.trunc(a / b);
      if (!Number.isSafeInteger(result)) throw new ForthError('integer overflow');
      this.stack.push(result);
    }
  }

  evaluate(source: string): number[] {
    const tokens = source.match(/\S+/g) || [];
    for (let i = 0; i < tokens.length;) {
      const token = tokens[i++];
      if (token === ':') {
        if (i >= tokens.length) throw new ForthError('missing definition name');
        const name = tokens[i++].toLowerCase();
        if (name === ':' || name === ';' || /^-?[0-9]+$/.test(name)) throw new ForthError('invalid word name');
        const body: Instruction[] = [];
        while (i < tokens.length && tokens[i] !== ';') {
          if (tokens[i] === ':') throw new ForthError('nested definition');
          body.push(...this.resolve(tokens[i++]));
        }
        if (i === tokens.length) throw new ForthError('missing semicolon');
        i++; // consume ;
        this.definitions.set(name, body);
      } else {
        if (token === ';') throw new ForthError('unexpected semicolon');
        this.execute(this.resolve(token));
      }
    }
    return [...this.stack];
  }
}

export function evaluateProgram(source: string): number[] {
  return new Forth().evaluate(source);
}
