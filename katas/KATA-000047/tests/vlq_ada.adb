-- SPDX-License-Identifier: MIT
-- A separate Ada implementation of canonical u32 variable-length quantity.
with Ada.Text_IO;              use Ada.Text_IO;
with Ada.Strings;               use Ada.Strings;
with Ada.Strings.Fixed;         use Ada.Strings.Fixed;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;

procedure Vlq_Ada is
   Max_U32 : constant Long_Long_Integer := 4_294_967_295;
   type Number_Buffer is array (Positive range 1 .. 1_024) of Long_Long_Integer;
   type Digit_Buffer is array (Positive range 1 .. 5) of Long_Long_Integer;
   function Num (X : Long_Long_Integer) return String is
     (Trim (Long_Long_Integer'Image (X), Both));

   procedure Handle (Line : String) is
      Values : Number_Buffer := (others => 0);
      Used : Natural := 0;
      Cursor : Positive := Line'First + 2;
      Mode : Character;
      Result : Unbounded_String := To_Unbounded_String ("OK|");
      First_Val : Boolean := True;

      procedure Emit (Number : Long_Long_Integer) is
      begin
         if not First_Val then
            Append (Result, ",");
         end if;
         First_Val := False;
         Append (Result, Num (Number));
      end Emit;
   begin
      if Line'Length < 2 or else Line (Line'First + 1) /= '|' then
         raise Constraint_Error;
      end if;
      Mode := Line (Line'First);
      if Mode /= 'E' and then Mode /= 'D' then
         raise Constraint_Error;
      end if;
      if Line'Length > 2 then
         for I in Line'First + 2 .. Line'Last + 1 loop
            if I > Line'Last or else Line (I) = ',' then
               if I <= Cursor or else Used >= Values'Length then
                  raise Constraint_Error;
               end if;
               Used := Used + 1;
               Values (Used) := Long_Long_Integer'Value (Line (Cursor .. I-1));
               Cursor := I + 1;
            end if;
         end loop;
      end if;
      if Mode = 'E' then
         for I in 1 .. Used loop
            declare
               N : Long_Long_Integer := Values (I);
               Groups_Data : Digit_Buffer := (others => 0);
               Count : Natural := 0;
            begin
               if N < 0 or else N > Max_U32 then
                  raise Constraint_Error;
               end if;
               loop
                  Count := Count + 1;
                  Groups_Data (Count) := N mod 128;
                  N := N / 128;
                  exit when N = 0;
               end loop;
               for J in reverse 1 .. Count loop
                  if J > 1 then
                     Emit (Groups_Data (J) + 128);
                  else
                     Emit (Groups_Data (J));
                  end if;
               end loop;
            end;
         end loop;
      else
         declare
            Groups : Natural := 0;
            Value : Long_Long_Integer := 0;
         begin
            for I in 1 .. Used loop
               declare
                  B : constant Long_Long_Integer := Values (I);
               begin
                  if B < 0 or else B > 255 then
                     raise Constraint_Error;
                  end if;
                  Groups := Groups + 1;
                  if Groups > 5 or else
                    (Groups = 1 and then B >= 128 and then B mod 128 = 0)
                  then
                     raise Constraint_Error;
                  end if;
                  Value := Value * 128 + (B mod 128);
                  if Value > Max_U32 then
                     raise Constraint_Error;
                  end if;
                  if B < 128 then
                     Emit (Value);
                     Value := 0;
                     Groups := 0;
                  end if;
               end;
            end loop;
            if Groups /= 0 then
               raise Constraint_Error;
            end if;
         end;
      end if;
      Put_Line (To_String (Result));
   exception
      when others =>
         Put_Line ("ERROR");
   end Handle;
begin
   while not End_Of_File loop
      declare
         Line : constant String := Get_Line;
      begin
         Handle (Line);
      end;
   end loop;
end Vlq_Ada;
