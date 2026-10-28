// SPDX-License-Identifier: MIT
package ninja.gilded

import kotlin.random.Random

fun main() {
    val random = Random(20261028)
    val names = listOf("Apple", "Conjured Cake", "Aged Brie", "Backstage passes", "Sulfuras")
    var assertions = 0
    for (name in names) {
        for (index in 0 until 450) {
            val sellIn = if (index < 15) index - 7 else random.nextInt(-35, 65)
            val quality = if (name == "Sulfuras") 80 else random.nextInt(0, 51)
            val original = Item(name, sellIn, quality)
            val days = if (index < 15) 365 else random.nextInt(30, 366)
            var item = original
            repeat(days) {
                val prior = item
                item = nextDay(item)
                check(item.name == prior.name) { "name changed" }
                assertions++
                if (name == "Sulfuras") {
                    check(item == prior) { "legendary changed" }
                } else {
                    check(item.sellIn == prior.sellIn - 1) { "sellIn transition" }
                    check(item.quality in 0..50) { "quality bound" }
                    if (name == "Aged Brie") check(item.quality >= prior.quality) { "Brie decreased" }
                    if (name == "Apple" || name.startsWith("Conjured ")) {
                        check(item.quality <= prior.quality) { "ordinary increased" }
                    }
                    if (name == "Backstage passes") {
                        if (prior.sellIn <= 0) check(item.quality == 0) { "concert expired" }
                        else check(item.quality >= prior.quality) { "pass decreased before concert" }
                    }
                }
                assertions++
            }
            check(original == Item(name, sellIn, quality)) { "input mutated" }
            assertions++
            val split = days / 2
            var left = original
            repeat(split) { left = nextDay(left) }
            repeat(days - split) { left = nextDay(left) }
            check(left == item) { "split trajectory mismatch" }
            assertions++
        }
    }
    println("PASS: $assertions Kotlin multi-day trajectory invariant assertions")
}
