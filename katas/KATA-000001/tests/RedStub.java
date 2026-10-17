// SPDX-License-Identifier: MIT
// Intentionally wrong substitute compiled alone into the RED test directory.
import java.util.List;
final class TriviaRefactored {
    public static String run(List<String> names, List<TriviaCli.Move> moves) {
        return "WELCOME " + names.get(0) + "\nNO_WINNER\n";
    }
}
