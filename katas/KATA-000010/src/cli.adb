with Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Command_Line;
with Bug_Proof_Game;
procedure Cli is
   use Bug_Proof_Game;
   P, C, B, T : Integer;
   Ids : Player_Ids := (others => 0);
   Board : Cell_Categories := (others => 0);
   Decks : Deck_Lengths := (others => 0);
   Roll, Answer : Integer;
   --  Validate the complete bounded request before emitting any response.
   type Turn_Values is array (Positive range 1 .. 128) of Integer;
   Rolls : Turn_Values := (others => 0);
   Answers : Turn_Values := (others => 0);
   procedure Read_Int (Value : out Integer) is
   begin
      Ada.Integer_Text_IO.Get (Value);
   end Read_Int;
begin
   Read_Int (P); Read_Int (C); Read_Int (B); Read_Int (T);
   if P < 2 or else P > Max_Players or else C < 1
     or else C > Max_Categories or else B < 1
     or else B > Max_Cells or else T < 0 or else T > 128
   then
      raise Constraint_Error;
   end if;
   for I in 1 .. P loop
      Read_Int (Ids (I));
   end loop;
   for I in 1 .. B loop
      Read_Int (Board (I));
   end loop;
   for I in 1 .. C loop
      Read_Int (Decks (I));
   end loop;
   declare
      State : Game := Create (Ids, P, Board, B, Decks, C);
   begin
      for I in 1 .. T loop
         Read_Int (Roll); Read_Int (Answer);
         if Roll < 1 or else Roll > 6
           or else (Answer /= 0 and then Answer /= 1)
         then
            raise Constraint_Error;
         end if;
         Rolls (I) := Roll;
         Answers (I) := Answer;
      end loop;
      for I in 1 .. T loop
         declare
            R : constant Turn_Result :=
              Play (State, Rolls (I), Answers (I) = 1);
         begin
            Ada.Text_IO.Put_Line
              (Natural'Image (R.Player) & Natural'Image (R.Category)
               & Natural'Image (R.Question) & Natural'Image (R.Score)
               & Integer'Image (Boolean'Pos (R.Penalized)));
         end;
      end loop;
   end;
exception
   when others =>
      Ada.Text_IO.Put_Line (Ada.Text_IO.Standard_Error, "ERR");
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end Cli;
