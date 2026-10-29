<?php
declare(strict_types=1);
/** Native fault-injection and atomicity tests; original Bank.php is never modified. */
$implementation = getenv('BANK_IMPL') ?: __DIR__ . '/../src/Bank.php';
require_once $implementation;
use NinjaKatas\Bank\{Account, Clock, Ledger, StatementFormatter, InMemoryLedger, TextStatementFormatter};

final class FaultClock implements Clock {
    public int $calls = 0;
    public bool $fail = false;
    public string $date = '01/01/2026';
    public function today(): string {
        $this->calls++;
        if ($this->fail) { throw new RuntimeException('clock unavailable'); }
        return $this->date;
    }
}
final class FaultLedger implements Ledger {
    public array $appends = [];
    public int $reads = 0;
    public bool $failAppend = false;
    public bool $failRead = false;
    public function append(string $date, int $signedAmount): void {
        if ($this->failAppend) { throw new RuntimeException('ledger unavailable'); }
        $this->appends[] = [$date, $signedAmount];
    }
    public function entries(): array {
        $this->reads++;
        if ($this->failRead) { throw new RuntimeException('ledger read unavailable'); }
        return $this->appends;
    }
}
final class FaultFormatter implements StatementFormatter {
    public int $calls = 0;
    public bool $fail = false;
    public array $seen = [];
    public function render(array $entries): string {
        $this->calls++;
        if ($this->fail) { throw new RuntimeException('formatter unavailable'); }
        $this->seen[] = $entries;
        return 'statement';
    }
}
$assertions = 0;
function check(bool $condition, string $label): void {
    global $assertions;
    $assertions++;
    if (!$condition) { fwrite(STDERR, "FAIL: $label\n"); exit(1); }
}
function throwsExactly(callable $action, string $class, string $label): void {
    try { $action(); } catch (Throwable $exception) {
        check($exception instanceof $class, "$label exception type: ".get_class($exception));
        return;
    }
    check(false, "$label did not throw");
}
$clock = new FaultClock();
$ledger = new FaultLedger();
$formatter = new FaultFormatter();
$account = new Account($clock, $ledger, $formatter);
foreach ([0, -1, PHP_INT_MIN] as $bad) {
    throwsExactly(fn() => $account->deposit($bad), InvalidArgumentException::class, 'invalid deposit');
    throwsExactly(fn() => $account->withdraw($bad), InvalidArgumentException::class, 'invalid withdrawal');
    check($clock->calls === 0, 'validation precedes clock access');
    check($ledger->appends === [], 'validation precedes ledger append');
}
$clock->fail = true;
throwsExactly(fn() => $account->deposit(1), RuntimeException::class, 'clock injection');
check($clock->calls === 1 && $ledger->appends === [], 'clock failure cannot append');
$clock->fail = false;
$ledger->failAppend = true;
throwsExactly(fn() => $account->withdraw(1), RuntimeException::class, 'append injection');
check($clock->calls === 2 && $ledger->appends === [], 'append failure does not record');
$ledger->failAppend = false;
$clock->date = '29/10/2026';
$account->deposit(7);
check($clock->calls === 3, 'one clock read per accepted operation');
check($ledger->appends === [['29/10/2026', 7]], 'date and amount are captured once');
$ledger->failRead = true;
throwsExactly(fn() => $account->printStatement(), RuntimeException::class, 'read injection');
check($formatter->calls === 0, 'formatter not called after read failure');
$ledger->failRead = false;
$formatter->fail = true;
throwsExactly(fn() => $account->printStatement(), RuntimeException::class, 'render injection');
check($ledger->appends === [['29/10/2026', 7]], 'render failure cannot mutate ledger');
$formatter->fail = false;
check($account->printStatement() === 'statement', 'successful print after recovery');
check($formatter->seen === [[['29/10/2026', 7]]], 'formatter receives exact ledger snapshot');
check($clock->calls === 3, 'printing does not read clock');

// Verify boundaries without floating-point arithmetic or a second ledger implementation.
$positive = new InMemoryLedger();
$positive->append('a', PHP_INT_MAX);
$before = $positive->entries();
throwsExactly(fn() => $positive->append('b', 1), OverflowException::class, 'positive overflow');
check($positive->entries() === $before, 'overflow leaves ledger unchanged');
check(count($before) === 1 && $before[0]->balance === PHP_INT_MAX, 'max balance remains exact');
$negative = new InMemoryLedger();
$negative->append('a', -PHP_INT_MAX);
$negative->append('b', -1);
$before = $negative->entries();
check($before[1]->balance === PHP_INT_MIN, 'min balance reached exactly');
throwsExactly(fn() => $negative->append('c', -1), OverflowException::class, 'negative underflow');
check($negative->entries() === $before, 'underflow leaves ledger unchanged');
$external = $negative->entries();
$external[] = 'injected';
check(count($negative->entries()) === 2, 'entries array is a defensive value copy');
throwsExactly(function() use ($before): void { $before[0]->balance = 1; }, Error::class, 'transaction immutability');

// Repeated deterministic boundary walks: overflow must never append a partial record.
for ($i = 1; $i <= 500; $i++) {
    $delta = ($i % 2 === 0) ? 1 : -1;
    $candidate = new InMemoryLedger();
    $candidate->append('start', $delta > 0 ? PHP_INT_MAX : -PHP_INT_MAX);
    $candidate->append('near', $delta > 0 ? 0 : -1);
    $snapshot = $candidate->entries();
    throwsExactly(fn() => $candidate->append('reject', $delta), OverflowException::class, 'boundary walk rejection');
    check($candidate->entries() === $snapshot, 'boundary walk atomicity');
}
check((new TextStatementFormatter())->render([]) === 'Date | Amount | Balance', 'empty statement is deterministic');
echo "PASS: $assertions native fault-injection/atomicity assertions\n";
