// SPDX-License-Identifier: MIT
package ninja.gilded
fun same(name: String, input: Item, expected: Item) {
    val actual = nextDay(input)
    check(actual == expected) { "$name expected=$expected actual=$actual" }
}
fun main() {
    same("ordinary before expiry", Item("Apple", 1, 10), Item("Apple", 0, 9))
    same("ordinary expired today", Item("Apple", 0, 10), Item("Apple", -1, 8))
    same("floor 0", Item("Apple", -1, 0), Item("Apple", -2, 0))
    same("aged cheese expiry", Item("Aged Brie", 0, 49), Item("Aged Brie", -1, 50))
    same("backstage 11", Item("Backstage passes", 11, 20), Item("Backstage passes", 10, 21))
    same("backstage 10", Item("Backstage passes", 10, 20), Item("Backstage passes", 9, 22))
    same("backstage 5", Item("Backstage passes", 5, 20), Item("Backstage passes", 4, 23))
    same("backstage concert", Item("Backstage passes", 0, 20), Item("Backstage passes", -1, 0))
    same("conjured normal", Item("Conjured Cake", 2, 9), Item("Conjured Cake", 1, 7))
    same("conjured expired", Item("Conjured Cake", 0, 3), Item("Conjured Cake", -1, 0))
    same("legendary", Item("Sulfuras", -10, 80), Item("Sulfuras", -10, 80))
    println("PASS: 11 Gilded Rose behavioral assertions")
}
