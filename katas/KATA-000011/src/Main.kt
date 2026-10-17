// SPDX-License-Identifier: MIT
package ninja.gilded
fun main() {
    generateSequence(::readLine).filter { it.isNotBlank() }.forEach { raw ->
        val parts = raw.split('|')
        require(parts.size == 3)
        val updated = nextDay(Item(parts[0], parts[1].toInt(), parts[2].toInt()))
        println(updated.name + "|" + updated.sellIn + "|" + updated.quality)
    }
}
