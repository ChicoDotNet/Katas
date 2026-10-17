// SPDX-License-Identifier: MIT
import java.math.BigInteger;
public final class TestDiffieHellman {
 static BigInteger n(long v){return BigInteger.valueOf(v);}
 static void same(BigInteger got,BigInteger want,String label){if(!got.equals(want))throw new AssertionError("FAIL behavioral assertion: "+label+" "+got);}
 static void reject(Runnable action){try{action.run();throw new AssertionError("invalid accepted");}catch(IllegalArgumentException expected){}}
 public static void main(String[] args){
  var dh=new DiffieHellman(n(23),n(5));
  same(dh.publicKey(n(6)),n(8),"alice public");
  same(dh.publicKey(n(15)),n(19),"bob public");
  same(dh.sharedSecret(n(6),n(19)),n(2),"alice shared");
  same(dh.sharedSecret(n(15),n(8)),n(2),"bob shared");
  reject(()->new DiffieHellman(n(21),n(5)));
  reject(()->new DiffieHellman(n(23),n(1)));
  reject(()->new DiffieHellman(n(23),n(22)));
  reject(()->dh.publicKey(n(1)));
  reject(()->dh.publicKey(n(22)));
  reject(()->dh.sharedSecret(n(6),n(0)));
  reject(()->dh.sharedSecret(n(6),n(23)));
  var other=new DiffieHellman(n(101),n(2));
  same(other.sharedSecret(n(5),other.publicKey(n(7))),other.sharedSecret(n(7),other.publicKey(n(5))),"symmetry");
  System.out.println("PASS: 12 modular-exchange and validation assertions");
 }
}
