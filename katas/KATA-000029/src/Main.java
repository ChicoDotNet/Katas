import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;

/** One nine-character board per line, one adjudication per line. */
public final class Main {
    private Main() { }
    public static void main(String[] args) throws Exception {
        if (args.length != 0) {
            System.err.println("Usage: Main < boards.txt");
            System.exit(2);
        }
        try (BufferedReader input = new BufferedReader(
                new InputStreamReader(System.in, StandardCharsets.UTF_8))) {
            String board;
            while ((board = input.readLine()) != null) {
                System.out.println(TicTacToe.evaluate(board));
            }
        }
    }
}
