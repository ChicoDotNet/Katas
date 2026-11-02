package Bug_Proof_Game is
   Max_Players : constant := 6;
   Max_Categories : constant := 4;
   Max_Cells : constant := 128;

   type Player_Ids is array (Positive range 1 .. Max_Players) of Integer;
   type Cell_Categories is array (Positive range 1 .. Max_Cells) of Integer;
   type Deck_Lengths is array (Positive range 1 .. Max_Categories) of Integer;

   type Turn_Result is record
      Player : Natural;
      Category : Natural;
      Question : Natural;
      Score : Natural;
      Penalized : Boolean;
   end record;

   --  Indefinite private type: clients cannot declare an unchecked default Game.
   type Game (<>) is private;

   function Create
     (Ids : Player_Ids; Player_Count : Integer;
      Board : Cell_Categories; Cell_Count : Integer;
      Decks : Deck_Lengths; Category_Count : Integer) return Game;

   function Play
     (State : in out Game; Roll : Integer; Correct : Boolean)
      return Turn_Result;

private
   type Player_Naturals is array (Positive range 1 .. Max_Players) of Natural;
   type Player_Bools is array (Positive range 1 .. Max_Players) of Boolean;
   type Category_Naturals is array (Positive range 1 .. Max_Categories) of Natural;

   type Game (Players : Positive; Categories : Positive; Cells : Positive) is record
      Ids : Player_Ids := (others => 0);
      Board : Cell_Categories := (others => 0);
      Decks : Deck_Lengths := (others => 0);
      Positions : Player_Naturals := (others => 0);
      Scores : Player_Naturals := (others => 0);
      Penalties : Player_Bools := (others => False);
      Visits : Category_Naturals := (others => 0);
      Current : Positive := 1;
   end record;
end Bug_Proof_Game;
