with Ada.Text_IO;
with Bug_Proof_Game;
procedure Test_Game is
   use Bug_Proof_Game;
   Ids : Player_Ids := (1 => 11, 2 => 22, others => 0);
   Board : Cell_Categories := (1 => 1, 2 => 2, 3 => 1, others => 0);
   Decks : Deck_Lengths := (1 => 2, 2 => 1, others => 0);
   Assertions : Natural := 0;
   procedure Check (Condition : Boolean; Label : String) is
   begin
      Assertions := Assertions + 1;
      if not Condition then
         Ada.Text_IO.Put_Line ("FAIL behavioral " & Label);
         raise Program_Error;
      end if;
   end Check;
   procedure Expect_Bad (Bad_Ids : Player_Ids; Bad_Board : Cell_Categories;
                         Bad_Decks : Deck_Lengths; P, B, C : Integer) is
      Failed : Boolean := False;
   begin
      begin
         declare
            G : Game := Create (Bad_Ids, P, Bad_Board, B, Bad_Decks, C);
         begin
            --  A successful construction is a contract violation.
            Failed := True;
         end;
      exception
         when Constraint_Error => null;
      end;
      Check (not Failed, "constructor rejected invalid configuration");
   end Expect_Bad;
begin
   Expect_Bad (Ids, Board, Decks, 1, 3, 2);
   Expect_Bad (Ids, Board, Decks, 7, 3, 2);
   declare
      Bad : Player_Ids := Ids;
   begin
      Bad (2) := 11;
      Expect_Bad (Bad, Board, Decks, 2, 3, 2);
   end;
   declare
      Bad : Cell_Categories := Board;
   begin
      Bad (2) := 3;
      Expect_Bad (Ids, Bad, Decks, 2, 3, 2);
   end;
   declare
      Bad : Deck_Lengths := Decks;
   begin
      Bad (1) := 0;
      Expect_Bad (Ids, Board, Bad, 2, 3, 2);
   end;
   Expect_Bad (Ids, Board, Decks, 2, 0, 2);

   declare
      G : Game := Create (Ids, 2, Board, 3, Decks, 2);
      R : Turn_Result;
   begin
      R := Play (G, 1, True);
      Check (R.Player = 1 and R.Category = 2 and R.Question = 1
             and R.Score = 1 and not R.Penalized, "first turn");
      R := Play (G, 1, False);
      Check (R.Player = 2 and R.Category = 2 and R.Question = 1
             and R.Score = 0 and R.Penalized, "penalty");
      R := Play (G, 2, True);
      Check (R.Player = 1 and R.Category = 1 and R.Question = 1
             and R.Score = 2, "circular board");
      R := Play (G, 2, True);
      Check (R.Player = 2 and R.Category = 1 and R.Question = 2
             and R.Score = 0 and not R.Penalized, "release without point");
      R := Play (G, 3, True);
      Check (R.Player = 1 and R.Category = 1 and R.Question = 1
             and R.Score = 3, "circular deck");
      begin
         R := Play (G, 0, True);
         Check (False, "invalid roll rejected");
      exception
         when Constraint_Error => Check (True, "invalid roll rejected");
      end;
   end;
   Ada.Text_IO.Put_Line ("GREEN PASS:" & Natural'Image (Assertions) & " assertions");
end Test_Game;
