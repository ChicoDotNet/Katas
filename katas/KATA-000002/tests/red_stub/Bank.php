<?php
declare(strict_types=1);
namespace NinjaKatas\Bank;
// Deliberately false implementation for reproducible behavioral RED.
interface Clock { public function today(): string; }
interface Ledger { public function append(string $date,int $signedAmount): void; public function entries(): array; }
interface StatementFormatter { public function render(array $entries): string; }
final class Account {
    public function __construct(private Clock $clock,private Ledger $ledger,private StatementFormatter $printer) {}
    public function deposit(int $amount): void {}
    public function withdraw(int $amount): void {}
    public function printStatement(): string {return '';}
}
