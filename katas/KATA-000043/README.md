# KATA-000043 — Educational Diffie–Hellman (Java 21)

Source reference: https://github.com/exercism/problem-specifications/tree/main/exercises/diffie-hellman. MIT repository license: https://github.com/exercism/problem-specifications/blob/main/LICENSE. Independently authored original Java implementation, tests and Python oracle under MIT; no canonical fixtures or starter code copied.

**Educational numerical contract:** given probable prime p>=5, generator g in [2,p-2] and two private exponents in [2,p-2], compute each public key and the shared modular secret with Java BigInteger.modPow. Verify Alice/Bob symmetry; reject composite modulus, out-of-range generator and private exponents, and public peer outside [1,p-1]. A CLI accepts p|g|alice|bob and writes publicAlice|publicBob|secret or ERROR for invalid parameters. Built-in probable-prime testing is used, not a mathematical primality certificate.

**SECURITY:** This is a pedagogical mathematical kata, **not production cryptography**. It does not validate generator subgroup order, public-key subgroup safety, secure private-key generation, constant-time side-channel resistance, transcript authentication, downgrade resistance, or modern standardized parameters. Use established, vetted cryptographic libraries and protocols for real deployments. No promise of secure key exchange is made.

Java 21 BigInteger selected to avoid custom modular exponent or machine integer overflow. Python built-in pow supplies an independent oracle of 1000 generated valid prime cases plus 5 rejected inputs. Complexity dominated by optimized modular exponent. Provisional author difficulty 5/5 and score 91/100; not calibrated.

~~~sh
cd katas/KATA-000043
mkdir -p /tmp/dh
javac --release 21 -Xlint:all -Werror -d /tmp/dh src/*.java tests/TestDiffieHellman.java
java -cp /tmp/dh TestDiffieHellman
python3 tests/differential.py /tmp/dh
if KATA_RED=1 java -cp /tmp/dh TestDiffieHellman >/tmp/dh-red.log 2>&1; then exit 1; fi
grep -q 'FAIL behavioral assertion' /tmp/dh-red.log
~~~

RED is a compiled but behaviorally incorrect public-key result. Local GREEN: 12 checks, 1005 differential scenarios, expected RED failure. Ninja OBS-029.
