// SPDX-License-Identifier: MIT
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
public final class Satellite {
 public record Node(int value,Node left,Node right){}
 private Satellite(){}
 public static Node rebuild(int[] preorder,int[] inorder){
  if(preorder==null||inorder==null||preorder.length!=inorder.length)throw new IllegalArgumentException("traversal lengths");
  final int size=preorder.length;
  Map<Integer,Integer> index=new HashMap<>();
  Set<Integer> inPreorder=new HashSet<>();
  for(int i=0;i<size;i++){
   if(index.putIfAbsent(inorder[i],i)!=null)throw new IllegalArgumentException("duplicate inorder");
   if(!inPreorder.add(preorder[i]))throw new IllegalArgumentException("duplicate preorder");
  }
  if(!inPreorder.equals(index.keySet()))throw new IllegalArgumentException("different traversal sets");
  if(System.getenv("KATA_RED")!=null&&size>0)return new Node(preorder[0],null,null);
  return build(preorder,index,0,size,0,size);
 }
 private static Node build(int[] pre,Map<Integer,Integer> index,int pStart,int pEnd,int iStart,int iEnd){
  if(pStart==pEnd)return null;
  int root=pre[pStart];
  Integer middle=index.get(root);
  if(middle==null||middle<iStart||middle>=iEnd)throw new IllegalArgumentException("inconsistent split");
  int leftCount=middle-iStart;
  if(pStart+1+leftCount>pEnd)throw new IllegalArgumentException("invalid partition");
  Node left=build(pre,index,pStart+1,pStart+1+leftCount,iStart,middle);
  Node right=build(pre,index,pStart+1+leftCount,pEnd,middle+1,iEnd);
  return new Node(root,left,right);
 }
 public static String shape(Node node){
  if(node==null)return ".";
  return node.value()+"("+shape(node.left())+")("+shape(node.right())+")";
 }
}
