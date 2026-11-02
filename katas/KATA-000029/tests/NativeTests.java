final class NativeTests {
    private static int assertions;
    private static void check(String board, String expected) {
        String actual = TicTacToe.evaluate(board);
        assertions++;
        if (!expected.equals(actual)) {
            throw new AssertionError("board=" + board + " expected=" + expected + " actual=" + actual);
        }
    }
    public static void main(String[] args) {
        check(".........", "NEXT:X|MOVES:0,1,2,3,4,5,6,7,8");
        check("X........", "NEXT:O|MOVES:1,2,3,4,5,6,7,8");
        check("XO.......", "NEXT:X|MOVES:2,3,4,5,6,7,8");
        check("XXXOO....", "WIN:X");
        check("OOOXX.X..", "WIN:O");
        check("XOXXOOOXX", "DRAW");
        check("XXXXOO...", "ERR:unreachable");
        check("OOO......", "ERR:unreachable");
        check("XXXOOO...", "ERR:unreachable");
        check("XXXOO.O..", "ERR:unreachable");
        check("XXXOOOXXO", "ERR:unreachable");
        check("XOXOXO..O", "ERR:unreachable");
        check("XOXOXO..X", "WIN:X");
        check("XOXO.....", "NEXT:X|MOVES:4,5,6,7,8");
        check("", "ERR:format");
        check("X", "ERR:format");
        check(".........X", "ERR:format");
        check("XOXOXOXO?", "ERR:format");
        check("x........", "ERR:format");
        check("💻........", "ERR:format");
        System.out.println("JAVA GREEN " + assertions + " assertions PASS");
    }
}
