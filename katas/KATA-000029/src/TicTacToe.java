import java.util.ArrayList;
import java.util.List;

/** Pure, stateless board adjudication. Coordinates are row-major 0..8. */
final class TicTacToe {
    private static final int[][] LINES = {
        {0, 1, 2}, {3, 4, 5}, {6, 7, 8},
        {0, 3, 6}, {1, 4, 7}, {2, 5, 8},
        {0, 4, 8}, {2, 4, 6}
    };

    private TicTacToe() { }

    static String evaluate(String board) {
        if (board == null || board.length() != 9) return "ERR:format";
        int x = 0, o = 0;
        for (int i = 0; i < 9; i++) {
            char cell = board.charAt(i);
            if (cell == 'X') x++;
            else if (cell == 'O') o++;
            else if (cell != '.') return "ERR:format";
        }
        // MUTANT-PARITY: remove the turn-count constraint.
        if (!(x == o || x == o + 1)) return "ERR:unreachable";

        boolean xWon = hasLine(board, 'X');
        boolean oWon = hasLine(board, 'O');
        // MUTANT-WINNER: remove last-move/winner consistency.
        if ((xWon && oWon) || (xWon && x != o + 1) || (oWon && x != o)) {
            return "ERR:unreachable";
        }
        // MUTANT-TERMINAL: incorrectly allow moves after a win.
        if (xWon) return "WIN:X";
        if (oWon) return "WIN:O";
        if (x + o == 9) return "DRAW";

        List<String> legal = new ArrayList<>();
        for (int i = 0; i < 9; i++) {
            if (board.charAt(i) == '.') legal.add(Integer.toString(i));
        }
        return "NEXT:" + (x == o ? 'X' : 'O') + "|MOVES:" + String.join(",", legal);
    }

    private static boolean hasLine(String board, char mark) {
        for (int[] line : LINES) {
            if (board.charAt(line[0]) == mark && board.charAt(line[1]) == mark
                    && board.charAt(line[2]) == mark) return true;
        }
        return false;
    }
}
