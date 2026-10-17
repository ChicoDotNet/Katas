// SPDX-License-Identifier: MIT
// Independently authored refactor of this repository's own TriviaLegacy.
import java.util.ArrayList;
import java.util.List;

public final class TriviaRefactored {
    private TriviaRefactored() {}

    private record Participant(String name, int station, int stars, boolean paused) {
        Participant moved(int newStation) { return new Participant(name, newStation, stars, false); }
        Participant earned() { return new Participant(name, station, stars + 1, false); }
        Participant suspended() { return new Participant(name, station, stars, true); }
    }

    private static final class Game {
        private static final List<String> TOPICS = List.of("LOGIC", "NATURE", "HISTORY", "ARTS");
        private final List<Participant> players = new ArrayList<>();
        private final int[] questions = new int[TOPICS.size()];
        private final StringBuilder transcript = new StringBuilder();
        private int current;
        private boolean winner;

        Game(List<String> names) {
            for (String name : names) {
                players.add(new Participant(name, 0, 0, false));
                emit("WELCOME " + name);
            }
        }
        private void emit(String event) { transcript.append(event).append('\n'); }
        void take(TriviaCli.Move action) {
            if (winner) return;
            Participant p = players.get(current);
            emit("TURN " + p.name() + " roll=" + action.roll());
            if (p.paused() && (action.roll() & 1) == 1) {
                emit("SKIP " + p.name());
                advance();
                return;
            }
            if (p.paused()) emit("RETURN " + p.name());
            int station = (p.station() + action.roll()) % 12;
            p = p.moved(station);
            emit("MOVE " + p.name() + " " + station);
            int category = station % TOPICS.size();
            emit("ASK " + TOPICS.get(category) + "#" + ++questions[category]);
            if (action.correct()) {
                p = p.earned();
                emit("RIGHT " + p.name() + " score=" + p.stars());
                if (p.stars() == 5) {
                    winner = true;
                    emit("WIN " + p.name());
                }
            } else {
                p = p.suspended();
                emit("WRONG " + p.name());
            }
            players.set(current, p);
            advance();
        }
        private void advance() { current = (current + 1) % players.size(); }
        String finish() {
            if (!winner) emit("NO_WINNER");
            return transcript.toString();
        }
    }

    public static String run(List<String> names, List<TriviaCli.Move> moves) {
        Game game = new Game(names);
        for (TriviaCli.Move move : moves) game.take(move);
        return game.finish();
    }
}
