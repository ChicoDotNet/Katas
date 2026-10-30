import java.util.Base64

fun main() {
    for (line in generateSequence(::readLine)) {
        try {
            val input = String(Base64.getDecoder().decode(line), Charsets.UTF_8)
            val result = TaskProtocol.execute(input)
            println(Base64.getEncoder().encodeToString(result.toByteArray(Charsets.UTF_8)))
        } catch (_: IllegalArgumentException) {
            println(Base64.getEncoder().encodeToString("ERR:encoding".toByteArray(Charsets.UTF_8)))
        }
    }
}
