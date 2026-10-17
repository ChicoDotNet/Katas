// SPDX-License-Identifier: MIT
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

public final class TestTrivia {
    private static void same(String actual, String expected, String description) {
        if (!expected.equals(actual)) {
            throw new AssertionError(description + " mismatch\nEXPECTED:\n" + expected + "\nACTUAL:\n" + actual);
        }
    }

    public static void main(String[] args) throws Exception {
        var names = List.of("Ada", "Bea");
        var events = List.of(
                new TriviaCli.Move(2, true),
                new TriviaCli.Move(1, false),
                new TriviaCli.Move(5, true),
                new TriviaCli.Move(3, true),
                new TriviaCli.Move(4, false),
                new TriviaCli.Move(2, true),
                new TriviaCli.Move(2, true),
                new TriviaCli.Move(2, true),
                new TriviaCli.Move(4, true),
                new TriviaCli.Move(1, true),
                new TriviaCli.Move(1, true),
                new TriviaCli.Move(1, false) // must never occur: previous turn wins
        );
        String golden = Files.readString(Path.of("tests", "expected-transcript.txt"));
        same(TriviaLegacy.run(names, events), golden, "original legacy fixture");
        same(TriviaRefactored.run(names, events), golden, "refactored behavioral golden master");
        same(TriviaRefactored.run(names, List.of()),
                "WELCOME Ada\nWELCOME Bea\nNO_WINNER\n", "zero turns");
        System.out.println("PASS: 3 fixed Golden Master/acceptance assertions");
    }
}
