----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    06:30:28 01/22/2023 
-- Design Name: 
-- Module Name:    color_carrier - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity color_carrier is
    Port ( clock_in : in  STD_LOGIC;
			  enable : in STD_LOGIC;																								-- enable and reset
			  output_enable : in STD_LOGIC;																						-- it is used to enable the color carrier output
			  color_select : in STD_LOGIC_VECTOR (2 downto 0) := (others => '0');									-- this is used to select the current color carrier
           square_out : out  STD_LOGIC);																						-- color carrier output
end color_carrier;

architecture Behavioral of color_carrier is
	signal phase_lock : std_logic := '1';
	signal magenta : std_logic := '0';
	signal red : std_logic := '0';
	signal yellow : std_logic := '0';
	signal green : std_logic := '1';
	signal cyan : std_logic := '1';
	signal blue : std_logic := '1';
begin

	square_out <= phase_lock when color_select = "000" and output_enable = '1' else
						magenta when color_select = "001" and output_enable = '1' else
						red when color_select = "010" and output_enable = '1' else
						yellow when color_select = "011" and output_enable = '1' else
						green when color_select = "100" and output_enable = '1' else
						cyan when color_select = "101" and output_enable = '1' else
						blue when color_select = "110" and output_enable = '1' else
						'0' when output_enable = '0';
	
	carrier_Wave: process(clock_in, enable) is
		variable lock_count : integer range 0 to 16 := 0;
		variable magenta_count : integer range 0 to 16 := 12;
		variable red_count : integer range 0 to 16 := 10;
		variable yellow_count : integer range 0 to 16 := 8;
		variable green_count : integer range 0 to 16 := 5;
		variable cyan_count : integer range 0 to 16 := 3;
		variable blue_count : integer range 0 to 16 := 1;
	
	begin
	
		if enable = '0' then
			lock_count := 0;
			magenta_count := 12;
			red_count := 10;
			yellow_count := 8;
			green_count := 5;
			cyan_count := 3;
			blue_count := 1;
			
		elsif enable = '1' then
			
			if rising_edge(clock_in) then
				
				lock_count := lock_count+1;
				magenta_count := magenta_count+1;
				red_count := red_count+1;
				yellow_count := yellow_count+1;
				green_count := green_count+1;
				cyan_count := cyan_count+1;
				blue_count := blue_count+1;
				
				-- overflow has occured, now start the count process again
				if lock_count = 14 then
					lock_count := 0;
					phase_lock <= '1';
				end if;
				if magenta_count = 14 then
					magenta_count := 0;
					magenta <= '1';
				end if;
				if red_count = 14 then
					red_count := 0;
					red <= '1';
				end if;
				if yellow_count = 14 then
					yellow_count := 0;
					yellow <= '1';
				end if;
				if green_count = 14 then
					green_count := 0;
					green <= '1';
				end if;
				if cyan_count = 14 then
					cyan_count := 0;
					cyan <= '1';
				end if;
				if blue_count = 14 then
					blue_count := 0;
					blue <= '1';
				end if;
				
				-- go to low
				if lock_count = 7 then
					phase_lock <= '0';
				end if;
				if magenta_count = 7 then
					magenta <= '0';
				end if;
				if red_count = 7 then
					red <= '0';
				end if;
				if yellow_count = 7 then
					yellow <= '0';
				end if;
				if green_count = 7 then
					green <= '0';
				end if;
				if cyan_count = 7 then
					cyan <= '0';
				end if;
				if blue_count = 7 then
					blue <= '0';
				end if;

			-- end rising edge if
			end if;
			
		end if;
	end process;
	
end Behavioral;

