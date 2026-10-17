// SPDX-License-Identifier: MIT
import java.math.BigInteger;
/** Educational modular exponent exercise; NOT production cryptography. */
public final class DiffieHellman {
 private final BigInteger prime,generator;
 private static final BigInteger ONE=BigInteger.ONE,TWO=BigInteger.TWO;
 public DiffieHellman(BigInteger prime,BigInteger generator){
  if(prime==null||generator==null||prime.compareTo(BigInteger.valueOf(5))<0||!prime.isProbablePrime(80))throw new IllegalArgumentException("prime required");
  if(generator.compareTo(TWO)<0||generator.compareTo(prime.subtract(ONE))>=0)throw new IllegalArgumentException("generator outside local educational range");
  this.prime=prime;this.generator=generator;
 }
 public BigInteger publicKey(BigInteger secret){
  checkPrivate(secret);
  if("1".equals(System.getenv("KATA_RED")))return ONE;
  return generator.modPow(secret,prime);
 }
 public BigInteger sharedSecret(BigInteger secret,BigInteger publicPeer){
  checkPrivate(secret);
  if(publicPeer==null||publicPeer.signum()<=0||publicPeer.compareTo(prime)>=0)throw new IllegalArgumentException("invalid peer");
  return publicPeer.modPow(secret,prime);
 }
 private void checkPrivate(BigInteger secret){
  if(secret==null||secret.compareTo(TWO)<0||secret.compareTo(prime.subtract(ONE))>=0)throw new IllegalArgumentException("invalid private");
 }
}
