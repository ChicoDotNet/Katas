<?php
// SPDX-License-Identifier: MIT
declare(strict_types=1);
require __DIR__.'/../src/TreeBuilding.php';
function check($want,$actual,string $why):void{
 if($want!==$actual)throw new Exception('FAIL behavioral assertion: '.$why.' '.json_encode([$want,$actual]));
}
function rejected(array $input):void{
 try{\NinjaTree\build($input);throw new Exception('invalid accepted');}
 catch(InvalidArgumentException $ok){}
}
check(['id'=>0,'children'=>[]],\NinjaTree\build([['id'=>0,'parent'=>0]]),'root');
check(['id'=>0,'children'=>[['id'=>1,'children'=>[]]]],\NinjaTree\build([['id'=>1,'parent'=>0],['id'=>0,'parent'=>0]]),'unsorted');
$rows=[['id'=>3,'parent'=>1],['id'=>0,'parent'=>0],['id'=>2,'parent'=>0],['id'=>1,'parent'=>0]];
$want=['id'=>0,'children'=>[['id'=>1,'children'=>[['id'=>3,'children'=>[]]]],['id'=>2,'children'=>[]]]];
check($want,\NinjaTree\build($rows),'nested and sorted');
check($want,\NinjaTree\build(array_reverse($rows)),'input order independence');
rejected([]);
rejected([['id'=>1,'parent'=>0]]);
rejected([['id'=>0,'parent'=>1]]);
rejected([['id'=>0,'parent'=>0],['id'=>0,'parent'=>0]]);
rejected([['id'=>0,'parent'=>0],['id'=>1,'parent'=>1]]);
rejected([['id'=>0,'parent'=>0],['id'=>1,'parent'=>3]]);
rejected([['id'=>0,'parent'=>0],['id'=>1,'parent'=>0],['id'=>3,'parent'=>0]]);
echo "PASS: 4 deterministic trees and 7 invalid-record cases\n";
