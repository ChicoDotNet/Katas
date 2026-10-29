// SPDX-License-Identifier: MIT
// Native boundary contract: accepted commands must leave every snapshot representable.
#include "../src/orders.hpp"
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <limits>
#include <stdexcept>
using namespace ninja_orders;
static int assertions = 0;
static void check(bool ok, const char* message) {
 ++assertions;
 if (!ok) { std::cerr << "FAIL behavioral invariant: " << message << '\n'; std::exit(1); }
}
int main() {
 constexpr auto max = std::numeric_limits<std::int64_t>::max();
 {
  Order o{0};
  check(!o.apply('A', {max, 2}), "reject quantity times cents overflow");
  auto s = o.snapshot();
  check(s.subtotal == 0 && s.tax == 0 && s.total == 0 && s.refused == 1,
        "overflow must not mutate the draft");
  check(o.apply('A', {1, max}), "rate zero permits maximal subtotal");
  s = o.snapshot();
  check(s.subtotal == max && s.tax == 0 && s.total == max, "maximal representable total");
  check(!o.apply('A', {1, 1}), "reject subtotal overflow without mutation");
  s = o.snapshot();
  check(s.subtotal == max && s.total == max && s.accepted == 1 && s.refused == 2,
        "subtotal overflow leaves previous line unchanged");
  check(o.apply('P') && o.apply('S'), "safe boundary order can still ship");
 }
 {
  Order o{2000};
  check(o.apply('A', {1, 7686143364045646506LL}), "20 percent largest safe subtotal");
  auto before = o.snapshot();
  check(before.total == max, "20 percent exact maximal total");
  check(!o.apply('A', {1, 1}), "reject total overflow before adding line");
  auto after = o.snapshot();
  check(after.refused == before.refused + 1, "failed addition counted");
  check(after.subtotal == before.subtotal && after.tax == before.tax &&
        after.total == before.total && after.state == before.state,
        "tax overflow rejection is atomic");
 }
 {
  Order o{2000};
  check(!o.apply('A', {1, max}), "reject tax-inclusive overflow");
  check(o.snapshot().subtotal == 0 && o.snapshot().refused == 1,
        "tax overflow does not leave invalid draft");
 }
 {
  Order o{1};
  check(o.apply('A', {1, 9222449791875588248LL}), "one basis point boundary accepted");
  check(o.snapshot().total == max, "one basis point boundary exact");
  check(!o.apply('A', {1, 1}), "one basis point next cent rejected");
 }
 {
  Order o{125};
  check(o.apply('A', {1, 9109503246276321785LL}), "125 basis points boundary accepted");
  check(o.snapshot().total == max, "125 basis points boundary exact");
  check(!o.apply('A', {1, 1}), "125 basis points next cent rejected");
 }
 {
  Order o{0};
  check(!o.apply('A', {0, max}) && !o.apply('A', {-1, 10}) &&
        !o.apply('A', {1, -1}), "invalid lines rejected before multiplication");
  auto before = o.snapshot();
  check(!o.apply('P'), "empty order still cannot approve");
  auto after = o.snapshot();
  check(after.state == before.state && after.subtotal == before.subtotal,
        "rejected commands preserve business state");
 }
 {
  Order o{2000};
  check(o.apply('A', {2, 5}), "small lines accepted");
  auto before = o.snapshot();
  check(!o.apply('S'), "shipping before approval rejected");
  auto after = o.snapshot();
  check(after.total == before.total && after.state == before.state,
        "rejected transition preserves monetary totals");
 }
 for (int bad : {-1, 2001}) {
  bool threw = false;
  try { Order o{bad}; (void)o; } catch (const std::invalid_argument&) { threw = true; }
  check(threw, "tax rate validation unchanged");
 }
 std::cout << "PASS: " << assertions << " native money-boundary assertions\n";
}
