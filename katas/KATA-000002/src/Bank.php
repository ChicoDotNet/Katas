<?php
declare(strict_types=1);
namespace NinjaKatas\Bank;

/** External date source: deterministic substitute supplied by caller. */
interface Clock { public function today(): string; }
/** Port for recording signed changes and retrieving ledger entries. */
interface Ledger { public function append(string $date, int $signedAmount): void; public function entries(): array; }
/** Pure formatting of statement transactions. */
interface StatementFormatter { public function render(array $entries): string; }

final readonly class Transaction {
    public function __construct(public string $date, public int $amount, public int $balance) {}
}

/** Public Account operations implement the kata's contract. */
final class Account {
    public function __construct(private Clock $clock, private Ledger $ledger, private StatementFormatter $formatter) {}
    public function deposit(int $amount): void {
        self::requirePositive($amount);
        $this->ledger->append($this->clock->today(), $amount);
    }
    public function withdraw(int $amount): void {
        self::requirePositive($amount);
        $this->ledger->append($this->clock->today(), -$amount);
    }
    public function printStatement(): string {
        return $this->formatter->render($this->ledger->entries());
    }
    private static function requirePositive(int $amount): void {
        if ($amount <= 0) { throw new \InvalidArgumentException('amount must be positive'); }
    }
}

final class InMemoryLedger implements Ledger {
    /** @var list<Transaction> */ private array $entries=[];
    public function append(string $date, int $signedAmount): void {
        $previous = $this->entries ? $this->entries[count($this->entries)-1]->balance : 0;
        if ($signedAmount > 0 && $previous > PHP_INT_MAX - $signedAmount) {
            throw new \OverflowException('balance overflow');
        }
        if ($signedAmount < 0 && $previous < PHP_INT_MIN - $signedAmount) {
            throw new \OverflowException('balance underflow');
        }
        $this->entries[] = new Transaction($date, $signedAmount, $previous+$signedAmount);
    }
    public function entries(): array { return $this->entries; }
}

final class TextStatementFormatter implements StatementFormatter {
    public function render(array $entries): string {
        $lines=['Date | Amount | Balance'];
        for($i=count($entries)-1;$i>=0;$i--){
            $t=$entries[$i];
            $signed=$t->amount>0 ? '+'.$t->amount : (string)$t->amount;
            $lines[]=$t->date.' | '.$signed.' | '.$t->balance;
        }
        return implode("\n",$lines);
    }
}
