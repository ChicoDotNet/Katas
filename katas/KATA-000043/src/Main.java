// SPDX-License-Identifier: MIT
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.math.BigInteger;
public final class Main {
 public static void main(String[] args)throws Exception{
  BufferedReader input=new BufferedReader(new InputStreamReader(System.in));String line;
  while((line=input.readLine())!=null){
   try{
    String[] parts=line.split("\\|",-1);
    if(parts.length!=4)throw new IllegalArgumentException("four fields");
    var prime=new BigInteger(parts[0]);var base=new BigInteger(parts[1]);
    var alice=new BigInteger(parts[2]);var bob=new BigInteger(parts[3]);
    var dh=new DiffieHellman(prime,base);
    var pubA=dh.publicKey(alice);var pubB=dh.publicKey(bob);
    var s1=dh.sharedSecret(alice,pubB);var s2=dh.sharedSecret(bob,pubA);
    if(!s1.equals(s2))throw new IllegalStateException("asymmetric key");
    System.out.println(pubA+"|"+pubB+"|"+s1);
   }catch(IllegalArgumentException err){System.out.println("ERROR");}
  }
 }
}
