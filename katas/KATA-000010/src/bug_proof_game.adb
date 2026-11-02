package body Bug_Proof_Game is
   function Create
     (Ids : Player_Ids; Player_Count : Integer;
      Board : Cell_Categories; Cell_Count : Integer;
      Decks : Deck_Lengths; Category_Count : Integer) return Game
   is
   begin
      if Player_Count < 2 or else Player_Count > Max_Players
        or else Cell_Count < 1 or else Cell_Count > Max_Cells
        or else Category_Count < 1 or else Category_Count > Max_Categories
      then
         raise Constraint_Error with "invalid dimensions";
      end if;

      for I in 1 .. Player_Count loop
         if Ids (I) < 1 or else Ids (I) > 99 then
            raise Constraint_Error with "invalid player identifier";
         end if;
         for J in 1 .. I - 1 loop
            if Ids (I) = Ids (J) then
               raise Constraint_Error with "duplicate player";
            end if;
         end loop;
      end loop;

      for I in 1 .. Cell_Count loop
         if Board (I) < 1 or else Board (I) > Category_Count then
            raise Constraint_Error with "unknown board category";
         end if;
      end loop;
      for I in 1 .. Category_Count loop
         if Decks (I) < 1 or else Decks (I) > 5 then
            raise Constraint_Error with "invalid deck length";
         end if;
      end loop;

      return Result : Game
        (Players => Player_Count, Categories => Category_Count,
         Cells => Cell_Count)
      do
         Result.Ids := Ids;
         Result.Board := Board;
         Result.Decks := Decks;
      end return;
   end Create;

   function Play
     (State : in out Game; Roll : Integer; Correct : Boolean)
      return Turn_Result
   is
      P : constant Positive := State.Current;
      C : Positive;
      Q : Positive;
   begin
      if Roll < 1 or else Roll > 6 then
         raise Constraint_Error with "invalid roll";
      end if;
      State.Positions (P) := (State.Positions (P) + Roll) mod State.Cells;
      C := Positive (State.Board (State.Positions (P) + 1));
      Q := Positive ((State.Visits (C) mod Natural (State.Decks (C))) + 1);
      State.Visits (C) := State.Visits (C) + 1;

      if Correct then
         if State.Penalties (P) then
            State.Penalties (P) := False;
         else
            State.Scores (P) := State.Scores (P) + 1;
         end if;
      else
         State.Penalties (P) := True;
      end if;

      State.Current := (P mod State.Players) + 1;
      return (Player => P, Category => C, Question => Q,
              Score => State.Scores (P), Penalized => State.Penalties (P));
   end Play;
end Bug_Proof_Game;
