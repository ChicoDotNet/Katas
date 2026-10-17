// SPDX-License-Identifier: MIT
// An ORIGINAL, intentionally tangled training specimen. NOT based on GPL starter source.
// Mixing game state, calculations, turn progression and presentation is deliberate.
import java.util.List;

public final class TriviaLegacy {
    private TriviaLegacy() {}

    public static String run(List<String> names, List<TriviaCli.Move> moves) {
        int[] position = new int[names.size()];
        int[] stars = new int[names.size()];
        boolean[] paused = new boolean[names.size()];
        int[] number = new int[4];
        String log = "";
        for (int n = 0; n < names.size(); n++) log = log + "WELCOME " + names.get(n) + "\n";
        int player = 0;
        boolean done = false;
        for (int turn = 0; turn < moves.size(); turn++) {
            if (done) break;
            int roll = moves.get(turn).roll();
            String name = names.get(player);
            log += "TURN " + name + " roll=" + roll + "\n";
            if (paused[player] && roll % 2 != 0) {
                log += "SKIP " + name + "\n";
                player = (player + 1) % names.size();
                continue;
            }
            if (paused[player] && roll % 2 == 0) {
                log += "RETURN " + name + "\n";
                paused[player] = false;
            }
            position[player] = (position[player] + roll) % 12;
            log += "MOVE " + name + " " + position[player] + "\n";
            int bucket = position[player] % 4;
            if (bucket == 0) log += "ASK LOGIC#" + ++number[0] + "\n";
            if (bucket == 1) log += "ASK NATURE#" + ++number[1] + "\n";
            if (bucket == 2) log += "ASK HISTORY#" + ++number[2] + "\n";
            if (bucket == 3) log += "ASK ARTS#" + ++number[3] + "\n";
            if (moves.get(turn).correct()) {
                stars[player] += 1;
                log += "RIGHT " + name + " score=" + stars[player] + "\n";
                if (stars[player] >= 5) {
                    log += "WIN " + name + "\n";
                    done = true;
                }
            } else {
                paused[player] = true;
                log += "WRONG " + name + "\n";
            }
            player = (player + 1) % names.size();
        }
        if (!done) log += "NO_WINNER\n";
        return log;
    }
}
