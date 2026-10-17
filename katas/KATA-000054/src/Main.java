// SPDX-License-Identifier: MIT
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.Arrays;
public final class Main {
 private static int[] decode(String text){
  if(text.isEmpty())return new int[0];
  return Arrays.stream(text.split(",",-1)).mapToInt(Integer::parseInt).toArray();
 }
 public static void main(String[] args)throws Exception{
  BufferedReader reader=new BufferedReader(new InputStreamReader(System.in));String line;
  while((line=reader.readLine())!=null){
   try{
    int at=line.indexOf('|');
    if(at<0||line.indexOf('|',at+1)>=0)throw new IllegalArgumentException("separator");
    var node=Satellite.rebuild(decode(line.substring(0,at)),decode(line.substring(at+1)));
    System.out.println(Satellite.shape(node));
   }catch(IllegalArgumentException ex){System.out.println("ERROR");}
  }
 }
}
