<?php
declare(strict_types=1);
require __DIR__.'/Bank.php';
use NinjaKatas\Bank\{Account,Clock,InMemoryLedger,TextStatementFormatter};
final class MutableClock implements Clock {
    public function __construct(public string $date='01/01/2000') {}
    public function today(): string {return $this->date;}
}
try {
    $operations=json_decode(stream_get_contents(STDIN),true,512,JSON_THROW_ON_ERROR);
    if (!is_array($operations) || !array_is_list($operations)) throw new InvalidArgumentException('operations list required');
    $clock=new MutableClock();
    $account=new Account($clock,new InMemoryLedger(),new TextStatementFormatter());
    foreach($operations as $operation){
        if (!is_array($operation) || !isset($operation['date'],$operation['type'],$operation['amount']) ||
            !is_string($operation['date']) || !is_string($operation['type']) || !is_int($operation['amount']) ||
            !preg_match('/^\d{2}\/\d{2}\/\d{4}$/D', $operation['date'])) {
            throw new InvalidArgumentException('invalid operation');
        }
        $clock->date=$operation['date'];
        match ($operation['type']) {
            'deposit' => $account->deposit($operation['amount']),
            'withdraw' => $account->withdraw($operation['amount']),
            default => throw new InvalidArgumentException('unknown operation type'),
        };
    }
    echo $account->printStatement(),"\n";
} catch(Throwable $e){fwrite(STDERR,get_class($e).': '.$e->getMessage()."\n");exit(2);}
