// SPDX-License-Identifier: MIT
package ninja.gilded
data class Item(val name: String, val sellIn: Int, val quality: Int)
fun nextDay(item: Item): Item = item.copy(sellIn = item.sellIn - 1)
