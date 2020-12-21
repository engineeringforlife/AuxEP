-- Listing 13.7
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity pong_graph is
   port(
        clk, reset: in std_logic;
        key_code: in std_logic_vector(3 downto 0);
        video_on: in std_logic;
        pixel_x,pixel_y: in std_logic_vector(9 downto 0);
        graph_rgb: out std_logic_vector(2 downto 0)
   );
end pong_graph;

architecture arch of pong_graph is
   signal pix_x, pix_y: unsigned(9 downto 0);
   constant MAX_X: integer:=640;
   constant MAX_Y: integer:=480;
	signal background_rgb:std_logic_vector(2 downto 0);
	signal score_play_1,score_play_2: std_logic_vector(3 downto 0);
	--signal background_on :std_logic;

--	---------------------------------------------------
--	-- Cantos dos players(para testes)
--	---------------------------------------------------
--	--Player 1
--	constant canto_pl_X	:	integer:= 128;
--	constant canto_pl_X_S	:	integer:= 128+31;	
--	constant canto_pl_y	:	integer:= 128;
--	constant canto_pl_y_S	:	integer:= 128+63;
--	--Player 2	
--	constant canto_pl2_X	:	integer:= 255;
--	constant canto_pl2_X_S	:	integer:= 255+31;	
--	constant canto_pl2_y	:	integer:= 128;
--	constant canto_pl2_y_S	:	integer:= 128+63;
--	
--	--constantes das luvas
--	constant G_L_P1X: integer:=320;
--	constant G_L_P1X_S: integer:=320+15;
--	constant G_L_P1Y: integer:=128;
--	constant G_L_P1Y_S: integer:=128+15;
--	
--	--constantes das luvas
--	constant G_R_P1X: integer:=320;
--	constant G_R_P1X_S: integer:=320+15;
--	constant G_R_P1Y: integer:=224;
--	constant G_R_P1Y_S: integer:=224+15;
	
	------------------------------
	
--		--constantes das luvas
--	constant G_L_P2X: integer:=384;
--	constant G_L_P2X_S: integer:=384+15;
--	constant G_L_P2Y: integer:=224;
--	constant G_L_P2Y_S: integer:=224+15;


	----------------------------------------------------------------
	--PLAYERS
	-----------------------------------------------------------
	
	--cordenadas dos cantos do player 1
   signal player1_x_l, player1_x_r: unsigned(9 downto 0);
   signal player1_y_t, player1_y_b: unsigned(9 downto 0);
	--Cordenadas do canto superior esquerdo do player 1
   signal player1_x_reg, player1_x_next: unsigned(9 downto 0);
   signal player1_y_reg, player1_y_next: unsigned(9 downto 0);
	
	--cordenadas dos cantos da luva esquerda do player 1
   signal glove_p1L_x_l, glove_p1L_x_r: unsigned(9 downto 0);
   signal glove_p1L_y_t, glove_p1L_y_b: unsigned(9 downto 0);
	--registos do canto da luva esquerda do player 1
   signal glove_p1L_x_reg, glove_p1L_x_next: unsigned(9 downto 0);
   signal glove_p1L_y_reg, glove_p1L_y_next: unsigned(9 downto 0);
	
	
	--cordenadas dos cantos da luva direita do player 1
   signal glove_P1R_x_l, glove_P1R_x_r: unsigned(9 downto 0);
   signal glove_P1R_y_t, glove_P1R_y_b: unsigned(9 downto 0);
	--registos do canto da luva esquerda do player 1
   signal glove_P1R_x_reg, glove_P1R_x_next: unsigned(9 downto 0);
   signal glove_P1R_y_reg, glove_P1R_y_next: unsigned(9 downto 0);
	
	
	
	-----------------------------------------------------------------
	--cordenadas dos cantos do player 2
   signal player2_x_l, player2_x_r: unsigned(9 downto 0);
   signal player2_y_t, player2_y_b: unsigned(9 downto 0);
	--Cordenadas do canto superior esquerdo do player 2
   signal player2_x_reg, player2_x_next: unsigned(9 downto 0);
   signal player2_y_reg, player2_y_next: unsigned(9 downto 0);
	-----------------------------------------------------------
	
	--cordenadas dos cantos da luva esquerda do player 1
   signal glove_p2L_x_l, glove_p2L_x_r: unsigned(9 downto 0);
   signal glove_p2L_y_t, glove_p2L_y_b: unsigned(9 downto 0);
	--Cordenadas do canto da luva esquerda do player 1
   signal glove_p2L_x_reg, glove_p2L_x_next: unsigned(9 downto 0);
   signal glove_p2L_y_reg, glove_p2L_y_next: unsigned(9 downto 0);
	
	
	--cordenadas dos cantos da luva direita do player 1
   signal glove_P2R_x_l, glove_P2R_x_r: unsigned(9 downto 0);
   signal glove_P2R_y_t, glove_P2R_y_b: unsigned(9 downto 0);
	--Cordenadas do canto da luva esquerda do player 1
   signal glove_P2R_x_reg, glove_P2R_x_next: unsigned(9 downto 0);
   signal glove_P2R_y_reg, glove_P2R_y_next: unsigned(9 downto 0);
	
	
	
	constant PLAYER_SIZE_X: integer:=32;
	constant PLAYER_SIZE_Y: integer:=64;
	--A rom serve para os dois players uma vez que o formato das ROM é igual
	type rom_player_tipe is array (0 to 31, 0 to 15) of std_logic_vector(2 downto 0);
	
	-----------------------------------------------------------
	--LUVAS
	-----------------------------------------------------------
	
	--Poderá ser necessario criar cordenadas para cada luva
	--As posições devem ser relativas a cada jogador
	
	--cordenadas dos cantos da luva
   signal glove_x_l, glove_x_r: unsigned(9 downto 0);
   signal glove_y_t, glove_y_b: unsigned(9 downto 0);
	--Cordenadas do canto superior esquerdo da luva
   signal glove_x_reg, glove_x_next: unsigned(9 downto 0);
   signal glove_y_reg, glove_y_next: unsigned(9 downto 0);
	
	constant GLOVE_SIZE_X: integer:=16;
	constant GLOVE_SIZE_Y: integer:=16;
	type rom_glove_type is array (0 to 15, 0 to 15) of std_logic_vector(2 downto 0);
	
	--------------------------------------------------------------
	--Definição das ROM
	--------------------------------------------------------------
	
	constant PLAYER_1_ROM: rom_player_tipe :=
	
	(
		("111","111","111","111","111","111","111","111","000","000","000","111","111","111","111","111"),
		("111","111","111","111","111","111","111","111","000","100","000","111","111","111","111","111"),
		("111","111","111","111","111","111","111","000","010","100","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","010","100","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","010","100","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","010","100","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","010","100","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","010","000","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","000","100","000","000","111","111","111","111"),
		("111","111","111","111","111","111","000","010","010","100","100","100","000","111","111","111"),
		("111","111","111","111","111","000","010","010","010","100","100","100","100","000","111","111"),
		("111","111","111","111","000","010","010","010","010","100","100","100","100","100","000","111"),
		("111","111","111","111","000","010","010","010","010","100","100","100","100","100","000","111"),
		("111","111","111","000","010","010","010","010","010","100","100","100","100","100","100","000"),
		("111","111","111","000","010","010","010","010","010","100","100","100","100","000","100","000"),
		("111","111","111","000","010","010","010","010","010","100","100","100","100","100","100","000"),	
		("111","111","111","000","010","010","010","010","010","100","100","100","100","100","100","000"),
		("111","111","111","000","010","010","010","010","010","100","100","100","100","000","100","000"),
		("111","111","111","000","010","010","010","010","010","100","100","100","100","100","100","000"),
		("111","111","111","111","000","010","010","010","010","100","100","100","100","100","000","111"),
		("111","111","111","111","000","010","010","010","010","100","100","100","100","100","000","111"),
		("111","111","111","111","111","000","010","010","010","100","100","100","100","000","111","111"),
		("111","111","111","111","111","111","000","010","010","100","100","100","000","111","111","111"),
		("111","111","111","111","111","111","111","000","000","100","000","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","010","000","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","010","100","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","010","100","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","010","100","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","010","100","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","010","100","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","111","000","100","000","111","111","111","111","111"),
		("111","111","111","111","111","111","111","111","000","000","000","111","111","111","111","111")
	);
	
	--permite enderessar a linha ou a coluna do player1
	--
   signal Player1_rom_addr: unsigned(4 downto 0);
	signal Player1_rom_col:unsigned(3 downto 0);
	--quanto se lê uma linha saem 16 bits
   signal Player1_rom_data: std_logic_vector(15 downto 0);
	--referen-se a cada bit da memória
   signal Player1_rom_bit: std_logic_vector(2 downto 0);
	
	
	constant PLAYER_2_ROM: rom_player_tipe :=
	(
		("111","111","111","111","111","111","111","111","000","000","000","111","111","111","111","111"),
		("111","111","111","111","111","111","111","111","000","100","000","111","111","111","111","111"),
		("111","111","111","111","111","111","111","000","100","100","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","100","100","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","100","100","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","100","100","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","100","100","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","100","000","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","000","100","000","000","111","111","111","111"),
		("111","111","111","111","111","111","000","100","100","100","100","100","000","111","111","111"),
		("111","111","111","111","111","000","100","100","100","100","100","100","100","000","111","111"),
		("111","111","111","111","000","110","110","110","110","110","110","110","110","110","000","111"),
		("111","111","111","111","000","110","110","110","110","110","110","110","110","110","000","111"),
		("111","111","111","000","110","110","110","110","110","110","110","110","110","110","110","000"),
		("111","111","111","000","110","110","110","110","110","110","110","110","110","000","110","000"),
		("111","111","111","000","110","110","110","110","110","110","110","110","110","110","110","000"),	
		("111","111","111","000","110","110","110","110","110","110","110","110","110","110","110","000"),
		("111","111","111","000","110","110","110","110","110","110","110","110","110","000","110","000"),
		("111","111","111","000","110","110","110","110","110","110","110","110","110","110","110","000"),
		("111","111","111","111","000","110","110","110","110","110","110","110","110","110","000","111"),
		("111","111","111","111","000","110","110","110","110","110","110","110","110","110","000","111"),
		("111","111","111","111","111","000","100","100","100","100","100","100","100","000","111","111"),
		("111","111","111","111","111","111","000","100","100","100","100","100","000","111","111","111"),
		("111","111","111","111","111","111","111","000","000","100","000","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","100","000","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","100","100","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","100","100","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","100","100","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","100","100","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","000","100","100","100","000","111","111","111","111"),
		("111","111","111","111","111","111","111","111","000","100","000","111","111","111","111","111"),
		("111","111","111","111","111","111","111","111","000","000","000","111","111","111","111","111")
	);
	
	--permite enderessar a linha ou a coluna do player2
   signal Player2_rom_addr: unsigned(4 downto 0);
	signal Player2_rom_col:unsigned(3 downto 0);
	--quanto se lê uma linha saem 16 bits
   signal Player2_rom_data: std_logic_vector(15 downto 0);
	--referen-se a cada bit da memória
   signal Player2_rom_bit: std_logic_vector(2 downto 0);
	
	
	constant GLOVE_ROM: rom_glove_type :=
	(
		("111","111","111","111","111","111","111","111","000","000","000","000","000","000","111","111"),
		("111","111","111","111","111","111","111","000","100","100","000","100","100","100","000","111"),
		("111","000","000","000","000","000","000","100","100","100","000","100","100","100","100","000"),
		("000","000","101","101","000","100","100","100","100","100","000","100","100","100","100","000"),
		("000","000","101","101","000","000","100","100","100","000","100","100","100","100","100","000"),
		("000","000","101","101","000","100","000","000","000","100","100","100","100","100","100","000"),
		("000","000","000","000","000","111","100","100","100","100","100","100","100","100","100","000"),
		("000","000","101","101","000","100","100","100","100","100","100","100","100","100","000","111"),
		("111","000","000","000","000","100","100","100","100","100","100","100","100","000","111","111"),
		("111","111","111","111","111","000","000","000","000","000","000","000","000","111","111","111"),
		("111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111"),
		("111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111"),
		("111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111"),
		("111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111"),
		("111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111"),
		("111","111","111","111","111","111","111","111","111","111","111","111","111","111","111","111")
	);
		
	--permite enderessar a linha ou a coluna da luva esquerda do player 1
   signal Glove_P1L_rom_addr: unsigned(3 downto 0);
	signal Glove_P1L_rom_col:unsigned(3 downto 0);
	--quanto se lê uma linha saem 16 bits
   signal Glove_P1L_rom_data: std_logic_vector(15 downto 0);
	--referen-se a cada bit da memória
   signal Glove_P1L_rom_bit: std_logic_vector(2 downto 0);
	
	
	--permite enderessar a linha ou a coluna da luva direita do player 1
   signal Glove_P1R_rom_addr: unsigned(3 downto 0);
	signal Glove_P1R_rom_col:unsigned(3 downto 0);
	--quanto se lê uma linha saem 16 bits
   signal Glove_P1R_rom_data: std_logic_vector(15 downto 0);
	--referen-se a cada bit da memória
   signal Glove_P1R_rom_bit: std_logic_vector(2 downto 0);
	
	
	
	--permite enderessar a linha ou a coluna da luva esquerda do player 2
   signal Glove_P2L_rom_addr: unsigned(3 downto 0);
	signal Glove_P2L_rom_col:unsigned(3 downto 0);
	--quanto se lê uma linha saem 16 bits
   signal Glove_P2L_rom_data: std_logic_vector(15 downto 0);
	--referen-se a cada bit da memória
   signal Glove_P2L_rom_bit: std_logic_vector(2 downto 0);
	
	--permite enderessar a linha ou a coluna da luva esquerda do player 2
   signal Glove_P2R_rom_addr: unsigned(3 downto 0);
	signal Glove_P2R_rom_col:unsigned(3 downto 0);
	--quanto se lê uma linha saem 16 bits
   signal Glove_P2R_rom_data: std_logic_vector(15 downto 0);
	--referen-se a cada bit da memória
   signal Glove_P2R_rom_bit: std_logic_vector(2 downto 0);
   signal rom_data: std_logic_vector(7 downto 0);

   signal rom_bit: std_logic;
	signal sq_player1_on, sq_player2_on : std_logic;
	signal glove_L_P1_on, glove_R_P1_on, glove_L_P2_on, glove_R_P2_on: std_logic;
   signal refr_tick: std_logic;
	
	
	
begin

	background_unit: entity work.background
      port map (clk=>clk, reset=>reset,
--                video_on=>background_on,
                pixel_x=>pixel_x, pixel_y=>pixel_y,
                graph_rgb=>background_rgb,
					 score_play_1=>score_play_1,
					 score_play_2=>score_play_2);

   -- Players registers
	
	   process (clk,reset)
   begin
      if reset='1' then
         player1_x_reg <= to_unsigned(225,10);
			player1_y_reg <= to_unsigned(212,10);
         player2_x_reg <= to_unsigned(384,10);
			player2_y_reg <= to_unsigned(212,10);
      elsif (clk'event and clk='1') then
         player1_x_reg <= player1_x_next;
			player1_y_reg <= player1_y_next;
			player2_x_reg <= player2_x_next;
			player2_y_reg <= player2_y_next;
      end if;
   end process;

   pix_x <= unsigned(pixel_x);
   pix_y <= unsigned(pixel_y);
   refr_tick <= '1' when (pix_y=481) and (pix_x=0) else
                '0';

------------------------------------------------------------------------------
--Posição do player1
------------------------------------------------------------------------------

--coloca o player na posição 100 100
	player1_x_l <= player1_x_reg;
   player1_y_t <= player1_y_reg;
   player1_x_r <= player1_x_l + PLAYER_SIZE_X - 1;
   player1_y_b <= player1_y_t + PLAYER_SIZE_Y - 1;
	
   sq_player1_on <=
		'1' when	((player1_x_l<=pix_x) and (pix_x<=player1_x_r) and
               (player1_y_t<=pix_y) and (pix_y<=player1_y_b))

			 else
      '0';
		
	process(player1_x_reg,player1_x_r,player1_x_l,player1_y_reg,player1_y_b,player1_y_t,refr_tick,key_code)
   begin
      player1_x_next <= player1_x_reg; -- no move
		player1_y_next <= player1_y_reg;
      
	--	if refr_tick='1' then
         if key_code="0100" then
            player1_y_next <= player1_y_reg + 16; -- move down
		
         elsif key_code="0011" then
            player1_y_next <= player1_y_reg - 16; -- move up
				
			elsif key_code="0010" then
            player1_x_next <= player1_x_reg + 16; 
			
			elsif key_code="0001" then 
            player1_x_next <= player1_x_reg - 16; 	
				
         end if;
   --   end if;
   end process;
	
		
	--player round
	--Para alterar o tamanho deslocamos os bits pra a esquerda
   Player1_rom_addr <= pix_y(5 downto 1) - player1_y_t(5 downto 1);
   Player1_rom_col <= pix_x(4 downto 1) - player1_x_l(4 downto 1);
	--ao alterar o "not" lemos os dados ao contrario
	Player1_rom_bit<= PLAYER_1_ROM(to_integer(not Player1_rom_addr), to_integer( Player1_rom_col));
	
----------------------------------------------------------
--Posição do player 2
----------------------------------------------------------

--coloca o player na posição 100 100
	player2_x_l <= player2_x_reg;
   player2_y_t <= player2_y_reg;
   player2_x_r <= player2_x_l + PLAYER_SIZE_X - 1;
   player2_y_b <= player2_y_t + PLAYER_SIZE_Y - 1;
	
	
   sq_player2_on <=
		'1' when	((player2_x_l<=pix_x) and (pix_x<=player2_x_r) and
               (player2_y_t<=pix_y) and (pix_y<=player2_y_b))
					
			 else
      '0';
		
		
			process(player2_x_reg, player2_x_r, player2_x_l, player2_y_reg, player2_y_b, player2_y_t, refr_tick, key_code)
   begin
      player2_x_next <= player2_x_reg; -- no move
		player2_y_next <= player2_y_reg;
      
--		if refr_tick='1' then
         if key_code="1000" then
            -- player2_y_next <= player2_y_reg + BAR_V; -- move down
				player2_y_next <= player2_y_reg + 16; -- move down
         elsif key_code="0111" then
				--player2_y_next <= player2_y_reg - BAR_V; -- move up
				player2_y_next <= player2_y_reg - 16; -- move up
			elsif key_code="1001" then
            --player2_x_next <= player2_x_reg + BAR_V; 
				player2_x_next <= player2_x_reg + 16; 
			elsif key_code="1010" then 
            --player2_x_next <= player2_x_reg - BAR_V; 	
				player2_x_next <= player2_x_reg - 16; 	
         end if;
--      end if;
   end process;
		
	--player round
	--Para alterar o tamanho deslocamos os bits pra a esquerda
   Player2_rom_addr <= pix_y(5 downto 1) - player2_y_t(5 downto 1);
   Player2_rom_col <= pix_x(4 downto 1) - player2_x_l(4 downto 1);
	--ao alterar o "not" lemos os dados ao contrario
	Player2_rom_bit<= PLAYER_2_ROM(to_integer(not Player2_rom_addr), to_integer(not Player2_rom_col));
	
	
----------------------------------------------------------
--Posição da luva
----------------------------------------------------------

	glove_L_P1_on <=
		'1' when	((glove_p1L_x_l<=pix_x) and (pix_x<=glove_p1L_x_r) and
               (glove_p1L_y_t<=pix_y) and (pix_y<=glove_p1L_y_b))			
			 else
      '0';
	
   glove_R_P1_on <=
		'1' when	((glove_p1R_x_l<=pix_x) and (pix_x<=glove_p1R_x_r) and
               (glove_p1R_y_t<=pix_y) and (pix_y<=glove_p1R_y_b))			
			 else
      '0';
	
	process (clk,reset)
   begin
      if reset='1' then
         glove_p1L_x_reg <= to_unsigned(32,10);
			glove_p1L_y_reg <= to_unsigned(0,10);
			
			glove_p1R_x_reg <= to_unsigned(32,10);
			glove_p1R_y_reg <= to_unsigned(48,10);
      elsif (clk'event and clk='1') then
         glove_p1L_x_reg <= glove_p1L_x_next;
			glove_p1L_y_reg <= glove_p1L_y_next;
			glove_p1R_x_reg <= glove_p1R_x_next;
			glove_p1R_y_reg <= glove_p1R_y_next;
			
      end if;
   end process;
	
	--Glove_P1R_state_reg
	process ( glove_p1R_x_reg, key_code,glove_P1R_y_reg,glove_p1L_x_reg, glove_p1L_y_reg)
	begin
		glove_p1R_x_next <= glove_p1R_x_reg;
		glove_p1R_y_next <= glove_p1R_y_reg;
		glove_p1L_x_next <= glove_p1L_x_reg;
		glove_p1L_y_next <= glove_p1L_y_reg;

				if key_code="0101" and glove_p1L_x_reg = 32 then -- tecla correspondente à luva esquerda
					glove_p1L_x_next <= to_unsigned(48,10);
					glove_p1R_x_next <= to_unsigned(32,10);
					glove_p1L_y_next <= to_unsigned(0,10);
					glove_p1R_y_next <= to_unsigned(48,10);
				elsif key_code="0101" then
					glove_p1L_x_next <= to_unsigned(32,10); 
					
				elsif key_code="0110" and glove_p1R_x_reg = 32 then --tecla corresponde te à luva direita
					glove_p1R_x_next <= to_unsigned(48,10);
					glove_p1L_x_next <= to_unsigned(32,10);		
					glove_p1L_y_next <= to_unsigned(0,10);
					glove_p1R_y_next <= to_unsigned(48,10);
				elsif key_code="0110" then
					glove_p1R_x_next <= to_unsigned(32,10);
					
				elsif key_code="1101" and glove_p1L_y_reg = 0 then
					glove_p1L_y_next <= to_unsigned(16,10);
					glove_p1R_y_next <= to_unsigned(32,10);
					glove_p1R_x_next <= to_unsigned(32,10);
					glove_p1L_x_next <= to_unsigned(32,10);									
				elsif key_code="1101" then					
					glove_p1R_y_next <= to_unsigned(48,10);
					glove_p1L_y_next <= to_unsigned(0,10);

				end if;

	end process;
	
	glove_p1L_x_l <= player1_x_l + glove_p1L_x_reg;
   glove_p1L_y_t <= player1_y_t + glove_p1L_y_reg;
   glove_p1L_x_r <= glove_p1L_x_l + GLOVE_SIZE_X - 1;
   glove_p1L_y_b <= glove_p1L_y_t + GLOVE_SIZE_X - 1;
	
	glove_p1R_x_l <= player1_x_l + glove_p1R_x_reg;
   glove_p1R_y_t <= player1_y_t + glove_p1R_y_reg;
   glove_p1R_x_r <= glove_p1R_x_l + GLOVE_SIZE_X - 1;
   glove_p1R_y_b <= glove_p1R_y_t + GLOVE_SIZE_X - 1;
	
	
   Glove_P1R_rom_addr <= pix_y(3 downto 0) - player1_y_t(3 downto 0);
   Glove_P1R_rom_col <= pix_x(3 downto 0) - player1_x_l(3 downto 0);
	Glove_P1R_rom_bit<= GLOVE_ROM(to_integer( Glove_P1R_rom_addr), to_integer( Glove_P1R_rom_col));

   Glove_P1L_rom_addr <= pix_y(3 downto 0) - player1_y_t(3 downto 0);
   Glove_P1L_rom_col <= pix_x(3 downto 0) - player1_x_l(3 downto 0);
	Glove_P1L_rom_bit<= GLOVE_ROM(to_integer(not Glove_P1L_rom_addr), to_integer( Glove_P1L_rom_col));	


--*******************************   

--*******************************
   glove_L_P2_on <=
		'1' when	((glove_p2L_x_l<=pix_x) and (pix_x<=glove_p2L_x_r) and
               (glove_p2L_y_t<=pix_y) and (pix_y<=glove_p2L_y_b))			
			 else
      '0';
	
   glove_R_P2_on <=
		'1' when	((glove_p2R_x_l<=pix_x) and (pix_x<=glove_p2R_x_r) and
               (glove_p2R_y_t<=pix_y) and (pix_y<=glove_p2R_y_b))			
			 else
      '0';
	
	process (clk,reset)
   begin
      if reset='1' then
         glove_p2L_x_reg <= to_unsigned(16,10);
			glove_p2L_y_reg <= to_unsigned(48,10);
			glove_p2R_x_reg <= to_unsigned(16,10);
			glove_p2R_y_reg <= to_unsigned(0,10);
      elsif (clk'event and clk='1') then
         glove_p2L_x_reg <= glove_p2L_x_next;
			glove_p2L_y_reg <= glove_p2L_y_next;
			glove_p2R_x_reg <= glove_p2R_x_next;
			glove_p2R_y_reg <= glove_p2R_y_next;
			
      end if;
   end process;
	
	--Glove_P2R_state_reg
	process ( glove_p2R_x_reg, key_code,glove_P2R_y_reg,glove_p2L_x_reg, glove_p2L_y_reg)
	begin
	--	Glove_P2R_state_next <= Glove_P2R_state_reg;
		glove_p2R_x_next <= glove_p2R_x_reg;
		glove_p2R_y_next <= glove_p2R_y_reg;
		glove_p2L_x_next <= glove_p2L_x_reg;
		glove_p2L_y_next <= glove_p2L_y_reg;

				if key_code="1011" and glove_p2L_x_reg = 16 then -- tecla correspondente à luva esquerda
					glove_p2L_x_next <= to_unsigned(32,10);
					glove_p2R_x_next <= to_unsigned(16,10);
					glove_p2L_y_next <= to_unsigned(48,10);
					glove_p2R_y_next <= to_unsigned(0,10);
				elsif key_code="1011" then
					glove_p2L_x_next <= to_unsigned(16,10); 
					
				elsif key_code="1100" and glove_p2R_x_reg = 16 then --tecla corresponde te à luva direita
					glove_p2R_x_next <= to_unsigned(32,10);
					glove_p2L_x_next <= to_unsigned(16,10);		
					glove_p2L_y_next <= to_unsigned(48,10);
					glove_p2R_y_next <= to_unsigned(0,10);
				elsif key_code="1100" then
					glove_p2R_x_next <= to_unsigned(16,10);
					
				elsif key_code="1110" and glove_p2R_y_reg = 0 then
					glove_p2L_y_next <= to_unsigned(32,10);
					glove_p2R_y_next <= to_unsigned(16,10);
					glove_p2R_x_next <= to_unsigned(16,10);
					glove_p2L_x_next <= to_unsigned(16,10);									
				elsif key_code="1110" then					
					glove_p2R_y_next <= to_unsigned(0,10);
					glove_p2L_y_next <= to_unsigned(48,10);

				end if;

	end process;
	
	glove_p2L_x_l <= player2_x_l - glove_p2L_x_reg;
   glove_p2L_y_t <= player2_y_t + glove_p2L_y_reg;
   glove_p2L_x_r <= glove_p2L_x_l + GLOVE_SIZE_X - 1;
   glove_p2L_y_b <= glove_p2L_y_t + GLOVE_SIZE_X - 1;
	
	glove_p2R_x_l <= player2_x_l - glove_p2R_x_reg;
   glove_p2R_y_t <= player2_y_t + glove_p2R_y_reg;
   glove_p2R_x_r <= glove_p2R_x_l + GLOVE_SIZE_X - 1;
   glove_p2R_y_b <= glove_p2R_y_t + GLOVE_SIZE_X - 1;
	
	Glove_P2L_rom_addr <= pix_y(3 downto 0) - player2_y_t(3 downto 0);
   Glove_P2L_rom_col <= pix_x(3 downto 0) - player2_x_l(3 downto 0);
	Glove_P2L_rom_bit<= GLOVE_ROM(to_integer( Glove_P2L_rom_addr), to_integer( not Glove_P2L_rom_col));

   Glove_P2R_rom_addr <= pix_y(3 downto 0) - player2_y_t(3 downto 0);
   Glove_P2R_rom_col <= pix_x(3 downto 0) - player2_x_l(3 downto 0);
	Glove_P2R_rom_bit<= GLOVE_ROM(to_integer(not Glove_P2R_rom_addr), to_integer(not Glove_P2R_rom_col));	
--*******************************   

--	process
--	begin
--		
--		if player1=l or player1=r or player1= t or player1=b then
--			score_play_2<= std_logic_vector( unsigned( score_play_2) + 1;
--		elsif player2=l or player2=r or player2=t or player2=b then
--			score_play_1<= std_logic_vector( unsigned( score_play_1) + 1;
--		elsif glovel_1 = player2 or glover_r = player2 then
--				ko2<=ko2+1;
--				ko1<= '0';
--				if ko2=3 then
--					score_play_1<= std_logic_vector( unsigned( score_play_1) + 1;
--				end if;
--		elsif
--			elsif glovel_2 = player1 or glover_2 = player1 then
--				ko1<=ko1+1;
--				ko2<= '0';
--				if ko1=3 then
--					score_play_2<= std_logic_vector( unsigned( score_play_2) + 1;
--				end if;
		
	score_play_1<="0001";
	score_play_2<="0011";
	--***************************************************************************
		
   -- rgb multiplexing circuit
   process(sq_player1_on,sq_player2_on, glove_L_P1_on, glove_L_P1_on, glove_L_P2_on, glove_R_P2_on,
					Player1_rom_bit,Player2_rom_bit,Glove_P1L_rom_bit,Glove_P1R_rom_bit,Glove_P2L_rom_bit,
					Glove_P2R_rom_bit, background_rgb,video_on)
   begin
      if video_on='0' then
          graph_rgb <= "000"; --blank
      else
			if sq_player1_on='1' and Player1_rom_bit /= "111" then
				graph_rgb <= Player1_rom_bit;
			
			elsif sq_player2_on='1' and Player2_rom_bit /= "111" then
					graph_rgb <= Player2_rom_bit;
					
			elsif glove_L_P1_on='1' and Glove_P1L_rom_bit /= "111" then
					graph_rgb <= Glove_P1L_rom_bit;
					
			elsif glove_R_P1_on='1' and Glove_P1R_rom_bit /= "111" then
					graph_rgb <= Glove_P1R_rom_bit;
					
			elsif glove_L_P2_on='1' and Glove_P2L_rom_bit /= "111" then
				graph_rgb <= Glove_P2L_rom_bit;
				
			elsif glove_R_P2_on='1' and Glove_P2R_rom_bit /= "111" then
				graph_rgb <= Glove_P2R_rom_bit;

			else
				graph_rgb <= background_rgb;
			end if;
      end if;
   end process;
	
end arch;



