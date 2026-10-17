// SPDX-License-Identifier: MIT
import {Zipper,Tree} from '../src/zipper';
function eq(actual:unknown,want:unknown,label:string){
 if(JSON.stringify(actual)!==JSON.stringify(want))throw Error('FAIL behavioral assertion: '+label+' got='+JSON.stringify(actual));
}
const root:Tree={value:1,left:{value:2,left:{value:4,left:null,right:null},right:null},right:{value:3,left:null,right:null}};
let zipper=Zipper.from(root);
eq(zipper.value(),1,'initial value');
eq(zipper.up(),null,'up at root');
const child=zipper.left();if(!child)throw Error('no left');
eq(child.value(),2,'left focus');
const grandchild=child.left();if(!grandchild)throw Error('no grandchild');
eq(grandchild.value(),4,'nested focus');
eq(grandchild.left(),null,'missing left');
const changed=grandchild.setValue(9);
eq(changed.value(),9,'new focused value');
eq(grandchild.value(),4,'old zipper immutable');
eq(changed.toRoot(),{value:1,left:{value:2,left:{value:9,left:null,right:null},right:null},right:{value:3,left:null,right:null}},'rebuilt root');
eq(root.left?.left?.value,4,'original unchanged');
const edited=child.setRight({value:8,left:null,right:null});eq(edited.toRoot().left?.right?.value,8,'insert right');
const right=zipper.right();if(!right)throw Error('missing right');
eq(right.up()?.value(),1,'ascend right');
eq(right.setLeft({value:7,left:null,right:null}).toRoot().right?.left?.value,7,'insert left');
console.log('PASS: 12 immutable zipper path, navigation and edit assertions');
