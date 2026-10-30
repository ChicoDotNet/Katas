import java.util.Base64
import java.nio.ByteBuffer
import java.nio.charset.CodingErrorAction
import java.nio.charset.CharacterCodingException

fun main() {
    for (line in generateSequence(::readLine)) {
        try {
            val input = Charsets.UTF_8.newDecoder()
                .onMalformedInput(CodingErrorAction.REPORT)
                .onUnmappableCharacter(CodingErrorAction.REPORT)
                .decode(ByteBuffer.wrap(Base64.getDecoder().decode(line))).toString()
            val result = TaskProtocol.execute(input)
            println(Base64.getEncoder().encodeToString(result.toByteArray(Charsets.UTF_8)))
        } catch (_: IllegalArgumentException) {
            println(Base64.getEncoder().encodeToString("ERR:encoding".toByteArray(Charsets.UTF_8)))
        } catch (_: CharacterCodingException) {
            println(Base64.getEncoder().encodeToString("ERR:encoding".toByteArray(Charsets.UTF_8)))
        }
    }
}
