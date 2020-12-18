-- Listing 13.7
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity pong_graph is
   port(
      clk, reset: std_logic;
      btn: std_logic_vector(1 downto 0);
      pixel_x,pixel_y: in std_logic_vector(9 downto 0);
      gra_still: in std_logic;
      graph_on, hit, miss: out std_logic;
      rgb: out std_logic_vector(2 downto 0);
		key_code: in std_logic_vector(3 downto 0)
   );
end pong_graph;

architecture arch of pong_graph is
   signal pix_x, pix_y: unsigned(9 downto 0);
   constant MAX_X: integer:=640;
   constant MAX_Y: integer:=480;
	
	---------------------------------------------------
	-- Limites do ring(Constantes)
	---------------------------------------------------
	
	--wall left 
   constant WALL_X_L: integer:=34;
   constant WALL_X_R: integer:=36;
	--wall right
	constant WALL_R_X_L: integer:=640-29;
   constant WALL_R_X_R: integer:=640-27;
	--wall top
	constant WALL_Y_T_T: integer:=34;
	constant WALL_Y_T_B: integer:=36;
	--wall bottom
   constant WALL_Y_B_T: integer:=480-37;
	constant WALL_Y_B_B: integer:=480-35;
	
	
   constant BAR_X_L: integer:=600;
   constant BAR_X_R: integer:=603;
   signal bar_y_t, bar_y_b: unsigned(9 downto 0);
   constant BAR_Y_SIZE: integer:=72;
   signal bar_y_reg, bar_y_next: unsigned(9 downto 0);
   constant BAR_V: integer:=1;
   constant BALL_SIZE: integer:=8; -- 8
	
	---------------------------------------------------
	-- Cantos dos players(para testes)
	---------------------------------------------------
	--Player 1
	constant canto_pl_X	:	integer:= 128;
	constant canto_pl_X_S	:	integer:= 128+31;	
	constant canto_pl_y	:	integer:= 128;
	constant canto_pl_y_S	:	integer:= 128+63;
	--Player 2	
	constant canto_pl2_X	:	integer:= 255;
	constant canto_pl2_X_S	:	integer:= 255+31;	
	constant canto_pl2_y	:	integer:= 128;
	constant canto_pl2_y_S	:	integer:= 128+63;
	
	-----------------------------------------------------------
	--cantos do ring(Constantes associadas
	-----------------------------------------------------------

	--Posição no eixo horizontal dos cantos esquerdos
	constant canto_L_X	:	integer:= 32;
	constant canto_L_X_S	:	integer:= 32+7;
	--Posição no eixo horizontal dos cantos direitos
	constant canto_R_X	:		integer:= 608;
	constant canto_R_X_S	:	integer:= 608+7;
	-- posição no eixo vertical dos cantos inferiores	
	constant canto_B_Y		:	integer:= 440;
	constant canto_B_Y_S	:	integer:= 440+7;
	-- posição no eixo vertical dos cantos superiores
	constant canto_T_Y		:	integer:= 32;
	constant canto_T_Y_S		:	integer:= 32+7;
	
	--constantes das luvas
	constant G_L_P1X: integer:=320;
	constant G_L_P1X_S: integer:=320+15;
	constant G_L_P1Y: integer:=128;
	constant G_L_P1Y_S: integer:=128+15;
	
	--constantes das luvas
	constant G_R_P1X: integer:=320;
	constant G_R_P1X_S: integer:=320+15;
	constant G_R_P1Y: integer:=224;
	constant G_R_P1Y_S: integer:=224+15;
	
	------------------------------
	
		--constantes das luvas
	constant G_L_P2X: integer:=384;
	constant G_L_P2X_S: integer:=384+15;
	constant G_L_P2Y: integer:=224;
	constant G_L_P2Y_S: integer:=224+15;
	
	-----------------------------------------------------------------------------
	--Para remover
	-----------------------------------------------------------------------------
	
	--cordenadas dos cantos da bola
   signal ball_x_l, ball_x_r: unsigned(9 downto 0);
   signal ball_y_t, ball_y_b: unsigned(9 downto 0);
	--Cordenadas do canto superior esquerdo da bola
   signal ball_x_reg, ball_x_next: unsigned(9 downto 0);
   signal ball_y_reg, ball_y_next: unsigned(9 downto 0);
	--Registos para registal a velocidade da bola
   signal ball_vx_reg, ball_vx_next: unsigned(9 downto 0);
   signal ball_vy_reg, ball_vy_next: unsigned(9 downto 0);
	
	--constantes de velocidade
   constant BALL_V_P: unsigned(9 downto 0):=to_unsigned(2,10);
	--velocidade negativa
   constant BALL_V_N: unsigned(9 downto 0):=unsigned(to_signed(-2,10));
	
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------



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
	--Cordenadas do canto da luva esquerda do player 1
   signal glove_p1L_x_reg, glove_p1L_x_next: unsigned(9 downto 0);
   signal glove_p1L_y_reg, glove_p1L_y_next: unsigned(9 downto 0);
	
	
	--cordenadas dos cantos da luva direita do player 1
   signal glove_PlR_x_l, glove_PlR_x_r: unsigned(9 downto 0);
   signal glove_PlR_y_t, glove_PlR_y_b: unsigned(9 downto 0);
	--Cordenadas do canto da luva esquerda do player 1
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
		("111","111","111","000","010","010","010","010","010","100","100","100","100","000","100","000"),	
		("111","111","111","000","010","010","010","010","010","100","100","100","100","000","100","000"),
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
		("111","111","111","000","110","110","110","110","110","110","110","110","110","000","110","000"),	
		("111","111","111","000","110","110","110","110","110","110","110","110","110","000","110","000"),
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
   signal Glove_PlR_rom_addr: unsigned(3 downto 0);
	signal Glove_PlR_rom_col:unsigned(3 downto 0);
	--quanto se lê uma linha saem 16 bits
   signal Glove_P1R_rom_data: std_logic_vector(15 downto 0);
	--referen-se a cada bit da memória
   signal Glove_PlR_rom_bit: std_logic_vector(2 downto 0);
	
	
	
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
	

	--memória ROM(É boa pratica aplicar tamanhos de potencias de 2)
   type rom_type is array (0 to 7) of std_logic_vector (7 downto 0);
   constant BALL_ROM: rom_type :=
   (
      "00111100", --   ****
      "01111110", --  ******
      "11111111", -- ********
      "11111111", -- ********
      "11111111", -- ********
      "11111111", -- ********
      "01111110", --  ******
      "00111100"  --   ****
   );
	--permite enderessar a linha ou a coluna da bola
   signal rom_addr, rom_col: unsigned(2 downto 0);
	--quanto se lê uma linha saem 8 bits
   signal rom_data: std_logic_vector(7 downto 0);
	--referen-se a cada bit da memória
   signal rom_bit: std_logic;
   --signal wall_on, bar_on, sq_ball_on, rd_ball_on: std_logic;
	signal wall_on, bar_on, sq_ball_on, rd_ball_on, sq_player1_on, rd_player1_on, sq_player2_on, glove_L_P1L_on, glove_L_PlR_on, glove_L_P2_on, glove_R_P2_on: std_logic;
   signal wall_rgb, bar_rgb, ball_rgb:
          std_logic_vector(2 downto 0);
   signal refr_tick: std_logic;
	
	
	
begin
   -- registers
	-- se usarmos mais bolas temos que ter um registo para cada uma
	--processo de controlo da bola
   process (clk,reset)
   begin
      if reset='1' then
         bar_y_reg <= (OTHERS=>'0');
         ball_x_reg <= (OTHERS=>'0');
         ball_y_reg <= (OTHERS=>'0');
         ball_vx_reg <= ("0000000100");
         ball_vy_reg <= ("0000000100");
      elsif (clk'event and clk='1') then
         bar_y_reg <= bar_y_next;
         ball_x_reg <= ball_x_next;
         ball_y_reg <= ball_y_next;
         ball_vx_reg <= ball_vx_next;
         ball_vy_reg <= ball_vy_next;
      end if;
   end process;
	
	
	
	   process (clk,reset)
   begin
      if reset='1' then
         player1_x_reg <= (others=>'0');
			player1_y_reg <= (others=>'0');
         player2_x_reg <= (OTHERS=>'0');
			player2_y_reg <= (OTHERS=>'0');
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
					 
---------------------------------------------
---------------------------------------------
   -- wall
	-- codigo a alterado para configurar as balizas
--   wall_on <=
--      '1' when (WALL_X_L<=pix_x) and (pix_x<=WALL_X_R) else
--      '0';
--   wall_rgb <= "001"; -- blue
-----------------------------------------------------------------------
--Definição das balizas. Concluído..
----------------------------------------------------------------
	
	   wall_on <=
      '1' when ((WALL_X_L<=pix_x) 	and (pix_x<=WALL_X_R) 	and (WALL_Y_T_T<=pix_y) and (pix_y<=WALL_Y_B_B))  	or
					((WALL_R_X_L<=pix_x) and (pix_x<=WALL_R_X_R) and (WALL_Y_T_T<=pix_y) and (pix_y<=WALL_Y_B_B)) 	or
					((WALL_Y_T_T<=pix_y) and (pix_y<=WALL_Y_T_B) and (WALL_X_L<=pix_x)   and (pix_x<=WALL_R_X_R)) 	or
					((WALL_Y_B_T<=pix_y) and (pix_y<=WALL_Y_B_B)	and (WALL_X_L<=pix_x)   and (pix_x<=WALL_R_X_R))
		else
      '0';
   wall_rgb <= "001"; -- blue
	
	
--------------------------------------------
-- paddle bar(Para eliminar)
--------------------------------------------
	
   bar_y_t <= bar_y_reg;
   bar_y_b <= bar_y_t + BAR_Y_SIZE - 1;
   bar_on <=
      '1' when (BAR_X_L<=pix_x) and (pix_x<=BAR_X_R) and
               (bar_y_t<=pix_y) and (pix_y<=bar_y_b) else
      '0';
   bar_rgb <= "010"; --green
   -- new bar y-position
   process(bar_y_reg,bar_y_b,bar_y_t,refr_tick,btn,gra_still, key_code)
   begin
      bar_y_next <= bar_y_reg; -- no move
      if gra_still='1' then  --initial position of paddle
         bar_y_next <= to_unsigned((MAX_Y-BAR_Y_SIZE)/2,10);
      elsif refr_tick='1' then
         --if btn(1)='1' and bar_y_b<(MAX_Y-1-BAR_V) then
			if key_code="1000" and bar_y_b<(MAX_Y-1-BAR_V) then
            bar_y_next <= bar_y_reg + BAR_V; -- move down
         elsif btn(0)='1' and bar_y_t > BAR_V then
            bar_y_next <= bar_y_reg - BAR_V; -- move up
         end if;
      end if;
   end process;
	
------------------------------------------
--Definição dos cantos
------------------------------------------

   ball_x_l <= ball_x_reg;
   ball_y_t <= ball_y_reg;
   ball_x_r <= ball_x_l + BALL_SIZE - 1;
   ball_y_b <= ball_y_t + BALL_SIZE - 1;
	
	
	
	
   sq_ball_on <=
	
      '1' when ((ball_x_l<=pix_x) and (pix_x<=ball_x_r) 		and
               (ball_y_t<=pix_y) and (pix_y<=ball_y_b)) 		or	
					--canto superior esquerdo
					((canto_L_X<=pix_x) and (pix_x<=canto_L_X_S) and
               (canto_T_Y<=pix_y) and (pix_y<=canto_T_Y_S)) or
					--canto suerior direito
					((canto_R_X<=pix_x) and (pix_x<=canto_R_X_S) and
               (canto_T_Y<=pix_y) and (pix_y<=canto_T_Y_S)) or
					--canto inferior esquerdo
					((canto_L_X<=pix_x) and (pix_x<=canto_L_X_S) and
               (canto_B_Y<=pix_y) and (pix_y<=canto_B_Y_S)) or
					--canto inferior direito
					((canto_R_X<=pix_x) and (pix_x<=canto_R_X_S) and
               (canto_B_Y<=pix_y) and (pix_y<=canto_B_Y_S))
					else
      '0';
		
		
		----------------------------------------------------------------------
		
		-- square player 1
		--poderá não ser necessário
--   player1_x_l <= player1_x_reg;
--   player1_y_t <= player1_y_reg;

--	constant canto_player1_x		:	integer:= 100;
--	constant canto_player1_y		:	integer:= 100;
--	to_unsigned((MAX_Y-BAR_Y_SIZE)/2,10);

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
            player1_y_next <= player1_y_reg + 32; -- move down
				--player1_y_next <= player1_y_reg + BAR_V; -- move down
         elsif key_code="0011" then
            player1_y_next <= player1_y_reg - 32; -- move up
				--player1_y_next <= player1_y_reg - BAR_V; -- move up
			elsif key_code="0010" then
            player1_x_next <= player1_x_reg + 32; 
				--player1_x_next <= player1_x_reg + BAR_V; 
			elsif key_code="0001" then 
            player1_x_next <= player1_x_reg - 32; 	
				--player1_x_next <= player1_x_reg + BAR_V; 
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
				player2_y_next <= player2_y_reg + 32; -- move down
         elsif key_code="0111" then
				--player2_y_next <= player2_y_reg - BAR_V; -- move up
				player2_y_next <= player2_y_reg - 32; -- move up
			elsif key_code="1001" then
            --player2_x_next <= player2_x_reg + BAR_V; 
				player2_x_next <= player2_x_reg + 32; 
			elsif key_code="1010" then 
            --player2_x_next <= player2_x_reg - BAR_V; 	
				player2_x_next <= player2_x_reg - 32; 	
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
	
	--luva esquerda do player 1
	--A ideia é que a posição da luva seja sempre relativa ao player
   glove_p1L_x_l <= player1_x_l + 32;
   glove_p1L_y_t <= player1_y_t;
   glove_p1L_x_r <= glove_p1L_x_l + GLOVE_SIZE_X - 1;
   glove_p1L_y_b <= glove_p1L_y_t + GLOVE_SIZE_X - 1;
	
	
   glove_L_P1L_on <=
						--Luva esquerda p1
		'1' when	((glove_p1L_x_l<=pix_x) and (pix_x<=glove_p1L_x_r) and
               (glove_p1L_y_t<=pix_y) and (pix_y<=glove_p1L_y_b))
--						--Luva direita p1
--					((G_R_P1X<=pix_x) and (pix_x<=G_R_P1X_S) and
--               (G_R_P1Y<=pix_y) and (pix_y<=G_R_P1Y_S))  or
--					   --Luva esquerda p2
--					((G_L_P2X<=pix_x) and (pix_x<=G_L_P2X_S) and
--               (G_L_P2Y<=pix_y) and (pix_y<=G_L_P2Y_S)) or
--					   --Luva direita p2
--					((G_L_P2X+32<=pix_x) and (pix_x<=G_L_P2X_S+32) and
--               (G_L_P2Y+32<=pix_y) and (pix_y<=G_L_P2Y_S+32))
					
			 else
      '0';
		
	--player round
	--Para alterar o tamanho deslocamos os bits pra a esquerda
   Glove_P1L_rom_addr <= pix_y(3 downto 0) - player1_y_t(3 downto 0);
   Glove_P1L_rom_col <= pix_x(3 downto 0) - player1_x_l(3 downto 0);
	--ao alterar o "not" lemos os dados ao contrario
	Glove_P1L_rom_bit<= GLOVE_ROM(to_integer(not Glove_P1L_rom_addr), to_integer(Glove_P1L_rom_col));
	
	
	--Luva direita do player 1
	
   glove_PlR_x_l <= player1_x_l + 32;
   glove_PlR_y_t <= player1_y_t + 48;
   glove_PlR_x_r <= glove_PlR_x_l + GLOVE_SIZE_X - 1;
   glove_PlR_y_b <= glove_PlR_y_t + GLOVE_SIZE_X - 1;
	

   glove_L_PlR_on <=
		'1' when	((glove_PlR_x_l<=pix_x) and (pix_x<=glove_PlR_x_r) and
               (glove_PlR_y_t<=pix_y) and (pix_y<=glove_PlR_y_b))			
			 else
      '0';
		
	
   Glove_PlR_rom_addr <= pix_y(3 downto 0) - player1_y_t(3 downto 0);
   Glove_PlR_rom_col <= pix_x(3 downto 0) - player1_x_l(3 downto 0);
	--ao alterar o "not" lemos os dados ao contrario
	Glove_PlR_rom_bit<= GLOVE_ROM(to_integer(Glove_PlR_rom_addr), to_integer(Glove_PlR_rom_col));
	
--   Player1_rom_data <= PLAYER_1_ROM(to_integer(Player1_rom_addr));
--   Player1_rom_bit <= Player1_rom_data(to_integer(not Player1_rom_col));
--	
--   rd_ball_on <=
--      '1' when (sq_player1_on='1') and (Player1_rom_bit='1') else
--      '0';
--	--se for com mais cores já não é preciso definir a cor
--   ball_rgb <= "100";   -- red


	--luva esquerda do player 2
--   glove_p2R_x_l <= glove_p2R_x_next;
--   glove_p2R_y_t <= glove_p2R_x_reg;

   glove_p2L_x_l <= player2_x_l - 16;
   glove_p2L_y_t <= player2_y_t + 48;
   glove_p2L_x_r <= glove_p2L_x_l + GLOVE_SIZE_X - 1;
   glove_p2L_y_b <= glove_p2L_y_t + GLOVE_SIZE_X - 1;
	

   glove_L_P2_on <=
		'1' when	((glove_p2L_x_l<=pix_x) and (pix_x<=glove_p2L_x_r) and
               (glove_p2L_y_t<=pix_y) and (pix_y<=glove_p2L_y_b))			
			 else
      '0';
		
	--player round
	--Para alterar o tamanho deslocamos os bits pra a esquerda
   Glove_P2L_rom_addr <= pix_y(3 downto 0) - player2_y_t(3 downto 0);
   Glove_P2L_rom_col <= pix_x(3 downto 0) - player2_x_l(3 downto 0);
	--ao alterar o "not" lemos os dados ao contrario
	Glove_P2L_rom_bit<= GLOVE_ROM(to_integer(Glove_P2L_rom_addr), to_integer(not Glove_P2L_rom_col));		
	
	
	--luva direita do player 2
   glove_p2R_x_l <= player2_x_l - 16;
   glove_p2R_y_t <= player2_y_t;
   glove_p2R_x_r <= glove_p2R_x_l + GLOVE_SIZE_X - 1;
   glove_p2R_y_b <= glove_p2R_y_t + GLOVE_SIZE_X - 1;
	
   glove_R_P2_on <=
		'1' when	((glove_p2R_x_l<=pix_x) and (pix_x<=glove_p2R_x_r) and
               (glove_p2R_y_t<=pix_y) and (pix_y<=glove_p2R_y_b))			
			 else
      '0';
		
	--player round
	--Para alterar o tamanho deslocamos os bits pra a esquerda
   Glove_P2R_rom_addr <= pix_y(3 downto 0) - player2_y_t(3 downto 0);
   Glove_P2R_rom_col <= pix_x(3 downto 0) - player2_x_l(3 downto 0);
	--ao alterar o "not" lemos os dados ao contrario
	Glove_P2R_rom_bit<= GLOVE_ROM(to_integer(not Glove_P2R_rom_addr), to_integer(not Glove_P2R_rom_col));	
	
	--------------------------------------------------------------------------------
		
   -- round ball
	--Para alterar o tamanho deslocamos os bits pra a esquerda
	--como é que se garante que o rom adres e colum adress começa em 0?
   rom_addr <= pix_y(2 downto 0) - ball_y_t(2 downto 0);
   rom_col <= pix_x(2 downto 0) - ball_x_l(2 downto 0);
	--ao alterar o not lemos os dados ao contrario
   rom_data <= BALL_ROM(to_integer(rom_addr));
   rom_bit <= rom_data(to_integer(not rom_col));
   rd_ball_on <=
      '1' when (sq_ball_on='1') and (rom_bit='1') else
      '0';
	--se for com mais cores já não é preciso definir a cor
   ball_rgb <= "100";   -- red
	
	
   -- new ball position
	--refr_tick está a 1 quando o varrimento horizontal chega ao fim
   ball_x_next <=
      to_unsigned((MAX_X)/2,10) when gra_still='1' else
      ball_x_reg + ball_vx_reg when refr_tick='1' else
      ball_x_reg;
   ball_y_next <=
      to_unsigned((MAX_Y)/2,10) when gra_still='1' else
      ball_y_reg + ball_vy_reg when refr_tick='1' else
      ball_y_reg;
		
   -- new ball velocity
   -- wuth new hit, miss signals
   process(ball_vx_reg,ball_vy_reg,ball_y_t,ball_x_l,ball_x_r,
           ball_y_t,ball_y_b,bar_y_t,bar_y_b,gra_still)
   begin
      hit <='0';
      miss <='0';
      ball_vx_next <= ball_vx_reg;
      ball_vy_next <= ball_vy_reg;
      if gra_still='1' then            --initial velocity
         ball_vx_next <= BALL_V_N;
         ball_vy_next <= BALL_V_P;
      elsif ball_y_t < 1 then          -- reach top
         ball_vy_next <= BALL_V_P;
      elsif ball_y_b > (MAX_Y-1) then  -- reach bottom
         ball_vy_next <= BALL_V_N;
      elsif ball_x_l <= WALL_X_R  then -- reach wall
         ball_vx_next <= BALL_V_P;     -- bounce back
      elsif (BAR_X_L<=ball_x_r) and (ball_x_r<=BAR_X_R) and
            (bar_y_t<=ball_y_b) and (ball_y_t<=bar_y_b) then
            -- reach x of right bar, a hit
            ball_vx_next <= BALL_V_N; -- bounce back
            hit <= '1';
      elsif (ball_x_r>MAX_X) then     -- reach right border
         miss <= '1';                 -- a miss
      end if;
   end process;
	
   -- rgb multiplexing circuit
   process(wall_on,bar_on,rd_ball_on,wall_rgb,bar_rgb,ball_rgb,sq_player1_on,sq_player2_on, glove_L_P1L_on, glove_L_PlR_on, glove_L_P2_on, glove_R_P2_on)
   begin
      if wall_on='1' and not rd_ball_on='1' then
         rgb <= wall_rgb;
      elsif bar_on='1' then
         rgb <= bar_rgb;
      elsif rd_ball_on='1' then
         rgb <= ball_rgb;
		elsif sq_player1_on='1' and Player1_rom_bit /= "111" then
         rgb <= Player1_rom_bit;
			--rgb <= "000";
		elsif sq_player2_on='1' and Player2_rom_bit /= "111" then
         rgb <= Player2_rom_bit;
		elsif glove_L_P1L_on='1' and Glove_P1L_rom_bit /= "111" then
         rgb <= Glove_P1L_rom_bit;
		elsif glove_L_PlR_on='1' and Glove_PlR_rom_bit /= "111" then
         rgb <= Glove_PlR_rom_bit;
		elsif glove_L_P2_on='1' and Glove_P2L_rom_bit /= "111" then
			rgb <= Glove_P2L_rom_bit;
		elsif glove_R_P2_on='1' and Glove_P2R_rom_bit /= "111" then
			rgb <= Glove_P2R_rom_bit;
      else
         rgb <= "110"; -- yellow background
      end if;
   end process;
   -- new graphic_on signal
	
   graph_on <= wall_on or bar_on or rd_ball_on or sq_player1_on or sq_player2_on or glove_L_P1L_on or glove_L_PlR_on or glove_L_P2_on or glove_R_P2_on;
end arch;



