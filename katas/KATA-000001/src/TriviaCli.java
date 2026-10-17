// SPDX-License-Identifier: MIT
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

public final class TriviaCli {
    public record Move(int roll, boolean correct) {
        public Move {
            if (roll < 1 || roll > 6) throw new IllegalArgumentException("roll must be 1..6");
        }
    }
    private TriviaCli() {}

    public static void main(String[] args) {
        if (args.length != 1 || (!args[0].equals("legacy") && !args[0].equals("refactored"))) {
            System.err.println("usage: TriviaCli legacy|refactored"); System.exit(2);
        }
        try {
            var reader = new BufferedReader(new InputStreamReader(System.in));
            String first = reader.readLine();
            if (first == null || !first.startsWith("PLAYERS ")) throw new IllegalArgumentException("missing PLAYERS header");
            List<String> names = List.of(first.substring(8).split(",", -1));
            if (names.size() < 2 || names.size() > 6 || new HashSet<>(names).size() != names.size()) {
                throw new IllegalArgumentException("players must be unique, 2..6");
            }
            for (String name : names) {
                if (!name.matches("[A-Za-z][A-Za-z0-9_-]{0,15}")) {
                    throw new IllegalArgumentException("invalid player name");
                }
            }
            var moves = new ArrayList<Move>();
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.isBlank()) continue;
                String[] tokens = line.trim().split("\\s+");
                if (tokens.length != 2 || (!tokens[1].equals("C") && !tokens[1].equals("W"))) {
                    throw new IllegalArgumentException("move must be: dice-roll C|W");
                }
                if (moves.size() == 256) throw new IllegalArgumentException("too many turns");
                moves.add(new Move(Integer.parseInt(tokens[0]), tokens[1].equals("C")));
            }
            System.out.print(args[0].equals("legacy")
                    ? TriviaLegacy.run(names, moves)
                    : TriviaRefactored.run(names, moves));
        } catch (Exception problem) {
            System.err.println(problem.getClass().getSimpleName() + ": " + problem.getMessage());
            System.exit(2);
        }
    }
}
