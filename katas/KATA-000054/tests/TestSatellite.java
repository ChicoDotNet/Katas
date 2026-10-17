// SPDX-License-Identifier: MIT
public final class TestSatellite {
 private static void same(String expected,int[] pre,int[] in){
  String got=Satellite.shape(Satellite.rebuild(pre,in));
  if(!expected.equals(got))throw new AssertionError("FAIL behavioral tree mismatch: expected="+expected+" got="+got);
 }
 private static void invalid(int[] a,int[] b){
  try{Satellite.rebuild(a,b);throw new AssertionError("invalid traversal accepted");}
  catch(IllegalArgumentException expected){}
 }
 public static void main(String[] args){
  same(".",new int[]{},new int[]{});
  same("1(.)(.)",new int[]{1},new int[]{1});
  same("1(2(.)(.))(3(.)(.))",new int[]{1,2,3},new int[]{2,1,3});
  same("1(2(3(.)(.))(.))(.)",new int[]{1,2,3},new int[]{3,2,1});
  same("1(.)(2(.)(3(.)(.)))",new int[]{1,2,3},new int[]{1,2,3});
  same("10(5(.)(.))(20(15(.)(.))(30(.)(.)))",new int[]{10,5,20,15,30},new int[]{5,10,15,20,30});
  invalid(new int[]{1,2},new int[]{1});
  invalid(new int[]{1,1},new int[]{1,1});
  invalid(new int[]{1,2},new int[]{1,3});
  invalid(new int[]{1,2,3},new int[]{3,1,2});
  System.out.println("PASS: 6 Java reconstruction checks and 4 validation cases");
 }
}
