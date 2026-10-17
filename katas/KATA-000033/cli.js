// SPDX-License-Identifier: MIT
'use strict';
const fs = require('node:fs');
const { evaluateProgram } = require('./build/src/forth.js');
const inputs = JSON.parse(fs.readFileSync(0, 'utf8'));
process.stdout.write(JSON.stringify(inputs.map(program => {
  try { return { stack: evaluateProgram(program) }; }
  catch (error) {
    const reason = String(error.message);
    return { error: reason.includes('underflow') ? 'underflow' :
              reason.includes('division by zero') ? 'zero' :
              reason.includes('overflow') ? 'overflow' :
              reason.includes('unknown word') ? 'unknown' : 'invalid' };
  }
})));
