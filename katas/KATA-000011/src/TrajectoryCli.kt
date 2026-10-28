// SPDX-License-Identifier: MIT
package ninja.gilded

// A batch trajectory adapter; does not modify the published production transition.
// Input: name|sellIn|quality|days, output: name|sellIn|quality.
fun main() {
    generateSequence(::readLine).filter { it.isNotBlank() }.forEach { line ->
        val parts = line.split('|')
        require(parts.size == 4) { "expected name|sellIn|quality|days" }
        val days = parts[3].toInt()
        require(days in 0..365) { "days must be in 0..365" }
        var item = Item(parts[0], parts[1].toInt(), parts[2].toInt())
        repeat(days) { item = nextDay(item) }
        println("${item.name}|${item.sellIn}|${item.quality}")
    }
}
