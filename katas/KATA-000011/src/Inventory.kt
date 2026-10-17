// SPDX-License-Identifier: MIT
package ninja.gilded
data class Item(val name: String, val sellIn: Int, val quality: Int)
fun nextDay(item: Item): Item {
    require(item.quality in 0..50 || (item.name == "Sulfuras" && item.quality == 80))
    if (item.name == "Sulfuras") return item
    val days = item.sellIn
    val delta = when {
        item.name == "Aged Brie" -> if (days <= 0) 2 else 1
        item.name == "Backstage passes" -> when {
            days <= 0 -> -item.quality
            days <= 5 -> 3
            days <= 10 -> 2
            else -> 1
        }
        item.name.startsWith("Conjured ") -> if (days <= 0) -4 else -2
        else -> if (days <= 0) -2 else -1
    }
    val quality = (item.quality + delta).coerceIn(0, 50)
    return item.copy(sellIn = days - 1, quality = quality)
}
