<?php
declare(strict_types=1);
require_once (getenv('KATA_RED') ? __DIR__ . '/red_stub/Bank.php' : __DIR__ . '/../src/Bank.php');
use NinjaKatas\Bank\{Account, Clock, Ledger, StatementFormatter, InMemoryLedger, TextStatementFormatter};

final class TestClock implements Clock {
    public function __construct(public string $day='10/01/2012') {}
    public function today(): string { return $this->day; }
}
final class RecordingLedger implements Ledger {
    /** @var array<array{string,int}> */ public array $calls=[];
    public function append(string $date, int $signedAmount): void { $this->calls[]=[$date,$signedAmount]; }
    public function entries(): array { return []; }
}
final class RecordingFormatter implements StatementFormatter {
    public array $arguments=[];
    public function render(array $entries): string { $this->arguments[]=$entries; return 'observed'; }
}
function expect(bool $condition, string $message): void {
    if (!$condition) {fwrite(STDERR,"FAIL: $message\n"); exit(1);}
}
function expectThrows(callable $run,string $class,string $message): void {
    try {$run();} catch (Throwable $ex) {expect($ex instanceof $class,$message.' threw '.get_class($ex));return;}
    expect(false,$message.' did not throw');
}
$clock=new TestClock();$ledger=new RecordingLedger();$printer=new RecordingFormatter();
$account=new Account($clock,$ledger,$printer);
$account->deposit(1000);
$clock->day='13/01/2012';$account->deposit(2000);
$clock->day='14/01/2012';$account->withdraw(500);
expect($ledger->calls === [['10/01/2012',1000],['13/01/2012',2000],['14/01/2012',-500]], 'outside-in ledger interactions');
expect($account->printStatement()==='observed','delegates rendering');
expect($printer->arguments===[[]],'renderer consumes ledger entries');
$fixed=new TestClock();$real=new Account($fixed,new InMemoryLedger(),new TextStatementFormatter());
$real->deposit(1000);$fixed->day='13/01/2012';$real->deposit(2000);$fixed->day='14/01/2012';$real->withdraw(500);
expect($real->printStatement()==="Date | Amount | Balance\n14/01/2012 | -500 | 2500\n13/01/2012 | +2000 | 3000\n10/01/2012 | +1000 | 1000", 'acceptance statement');
expect($real->printStatement()===$real->printStatement(),'printing does not mutate ledger');
expectThrows(fn()=> $real->deposit(0), InvalidArgumentException::class, 'zero deposit');
expectThrows(fn()=> $real->withdraw(-1), InvalidArgumentException::class, 'negative withdrawal');
$max=new Account(new TestClock(),new InMemoryLedger(),new TextStatementFormatter());
$max->deposit(PHP_INT_MAX);
expectThrows(fn()=> $max->deposit(1), OverflowException::class, 'prevent integer overflow');
expect(str_starts_with((new Account(new TestClock(),new InMemoryLedger(),new TextStatementFormatter()))->printStatement(),'Date | Amount | Balance'), 'empty ledger header');
echo "PASS: 9 outside-in/acceptance assertions\n";
