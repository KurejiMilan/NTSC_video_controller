----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    07:04:46 01/07/2023 
-- Design Name: 
-- Module Name:    NTSC_controller - Behavioral 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity NTSC_controller is
    Port ( clk : in  STD_LOGIC;
           dac : out  STD_LOGIC_VECTOR (7 downto 0) := "01001000");
end NTSC_controller;

architecture Behavioral of NTSC_controller is
	
	-- the scan_line_states represent the various state a scan line goes through to display image on the screem
	-- the states are front porch, sync tip, breezeway, color_burst, back porch and the active video
	
	-- the picture_state holds the value of current state 
	-- i.e. is it on veritcal blanking or displaying an image line with scan line
	
	-- the color_state is used for test pattern generator and nothing more
	
	-- the vertical_sync_half_type is used to for convenience as 3175 counts is need to complete on scan line
	-- as the one pulse used in vertical blanking last for it's half i.e. 31.75 us
	-- which results to count of 1587.5 which could not be achieved, we opt for the 1st pulse to last for 1587 count
	-- while the second pulse will last for 1588 pulse (1587+1588=3175)
	
	type scan_line_states is (FP, ST, BW, CB, BP, ACTIVE);
	type vertical_sync_states is (FE, VS, BE, INACTIVE_LINE);
	type picture_state is (vertical_blanking,scan_line);
	type color_state is (black_color_output, blue_color_output, red_color_output, magenta_color_output, green_color_output,
								cyan_color_output, yellow_color_output, white_color_output);
	type vertical_sync_half_type is (first_half, second_half);
	type field_type is (odd_field, even_field);
	type pulse_type is (low, high);
	
	signal current_scan_line_state : scan_line_states := FP;											--starting with the front porch
	signal current_vertical_sync_state : vertical_sync_states := FE;								--starting with the front_equalizer
	signal color_output : color_state := black_color_output;
	signal current_picture_state : picture_state := vertical_blanking;							--always starts with vertical blanking, for now not tested
	signal current_vertical_sync_half : vertical_sync_half_type := first_half;
	signal current_field_type : field_type := odd_field;
	signal current_pulse_type : pulse_type := low;														-- always starts with low level 
	
	-- defining the level of various states
	constant blanking_level : integer := 73;
	constant horizontal_synctip_level : integer := 0;
	
	-- defining time interval for different states
	constant FP_time : integer := 75;
	constant ST_time : integer := 235;
	constant BW_time : integer := 30;
	constant CB_time : integer := 125;
	constant BP_time : integer := 80;
	constant ACTIVE_time : integer := 2630;
	
	-- defining values for various colors
	constant black : integer := 87;
	constant blue : integer := 106;
	constant red : integer := 137;
	constant magenta : integer := 157;
	constant green : integer := 186;
	constant cyan : integer := 205;
	constant yellow : integer := 237;
	constant white : integer := 225;
	
begin

	main_process:process(clk)
		variable tick_counter : integer range 0 to 4095 := 0;											-- this is used to count from 0 to 3175
		variable counter : integer range 0 to 4095 := 0;												-- used to keep track of time for the scan_line
		variable line_counter : integer range 0 to 600 := 0; 											-- the line counter is used to indicate which line is being draw
																														-- only incremented after 
		variable pulse_counter : integer range 0 to 15 := 0;
		variable color_step_counter : integer range 0 to 400 := 0;
		
		variable alternate : integer range 0 to 1000 := 0;
		variable test_pattern : bit_vector(1 downto 0) := "01";
		
	begin
		if rising_edge(clk) then
			
		-- counter counts for every clock tick
		tick_counter := tick_counter+1; 
		counter := counter+1;
		
		-- the first half and second_half should be tracked regardless if it's in vertical or horizontal blanking
		if tick_counter = 1587 and current_vertical_sync_half = first_half then
			current_vertical_sync_half <= second_half;
			
			if current_picture_state = vertical_blanking then
				counter := 0;
				pulse_counter := pulse_counter+1;
			end if;
			
			-- increment the pulse count once the first half is completed for the even field
			--if current_picture_state = vertical_blanking and current_field_type = even_field then
			--	pulse_counter := pulse_counter+1;
			--end if;
			
		end if;
		
		if tick_counter = 3175 and current_vertical_sync_half = second_half then
			current_vertical_sync_half <= first_half;
			tick_counter := 0;
			
			if current_picture_state = vertical_blanking then
				counter := 0;
				pulse_counter := pulse_counter+1;
				line_counter := line_counter+1;
			end if;
			
		end if;
		
		case current_picture_state is
				
			when vertical_blanking =>
			
					case current_vertical_sync_state is
						when FE =>
							-- the equalizing pulse is LOW for short duration of 337(6.75us) followed by HIGH for duration of 25us
							if counter <= 337 and current_vertical_sync_half = first_half then
								dac <= std_logic_vector(to_unsigned(horizontal_synctip_level, 8));
								
							elsif counter > 337 and current_vertical_sync_half = first_half then
								dac <= std_logic_vector(to_unsigned(blanking_level, 8));
							
							elsif counter <= 338 and current_vertical_sync_half = second_half then
								dac <= std_logic_vector(to_unsigned(horizontal_synctip_level, 8));
							else
								dac <= std_logic_vector(to_unsigned(blanking_level, 8));
							end if;
							
							if pulse_counter = 6 then
								current_vertical_sync_state <= VS;
								counter := 0;
								pulse_counter := 0;
							end if;
							
						when VS =>
							-- the equalizing pulse is LOW for the duration of 25us followed by HIGH
							if counter <= 1250 and current_vertical_sync_half = first_half then
								dac <= std_logic_vector(to_unsigned(horizontal_synctip_level, 8));
								
							elsif counter > 1250 and current_vertical_sync_half = first_half then
								dac <= std_logic_vector(to_unsigned(blanking_level, 8));
							
							elsif counter <= 1250 and current_vertical_sync_half = second_half then
								dac <= std_logic_vector(to_unsigned(horizontal_synctip_level, 8));
							else
								dac <= std_logic_vector(to_unsigned(blanking_level, 8));
							end if;
							
							if pulse_counter = 6 then
								current_vertical_sync_state <= BE;
								pulse_counter := 0;
								counter := 0;
							end if;
							
						when BE =>
							-- same as BE
							if counter <= 337 and current_vertical_sync_half = first_half then
								dac <= std_logic_vector(to_unsigned(horizontal_synctip_level, 8));
								
							elsif counter > 337 and current_vertical_sync_half = first_half then
								dac <= std_logic_vector(to_unsigned(blanking_level, 8));
							
							elsif counter <= 338 and current_vertical_sync_half = second_half then
								dac <= std_logic_vector(to_unsigned(horizontal_synctip_level, 8));
							else
								dac <= std_logic_vector(to_unsigned(blanking_level, 8));
							end if;
							
							if pulse_counter = 6 then
								current_vertical_sync_state <= INACTIVE_LINE;
								counter := 0;
								pulse_counter := 0;
							end if;
							
						when INACTIVE_LINE =>
							if current_field_type = odd_field then
								if counter <= 75 and current_vertical_sync_half = first_half then
									dac <= std_logic_vector(to_unsigned(blanking_level, 8));
								elsif counter > 75 and counter <= 235 and current_vertical_sync_half = first_half then
									dac <= std_logic_vector(to_unsigned(horizontal_synctip_level, 8));
								else
									dac <= std_logic_vector(to_unsigned(blanking_level, 8));
								end if;
								
								if line_counter = 21 then
									current_vertical_sync_state <= FE;
									current_picture_state <= scan_line;
									current_scan_line_state <= FP;
									counter := 0;
									pulse_counter := 0;
								end if;
							end if;
							
							if current_field_type = even_field then
								if counter <= 75 and current_vertical_sync_half = second_half then
									dac <= std_logic_vector(to_unsigned(blanking_level, 8));
								elsif counter > 75 and counter <= 235 and current_vertical_sync_half = second_half then
									dac <= std_logic_vector(to_unsigned(horizontal_synctip_level, 8));
								else
									dac <= std_logic_vector(to_unsigned(blanking_level, 8));
								end if;
								
								if line_counter = 283 then
									current_vertical_sync_state <= FE;
									current_picture_state <= scan_line;
									current_scan_line_state <= FP;
									counter := 0;
									pulse_counter := 0;
								end if;
							
							end if;
							
						when OTHERS =>
						-- FOR SYNTAX COMPLETION ONLY THIS REMAINS EMPTY
					
					-- end case for current_vertical_sync_state
					end case;
				
			when scan_line =>
			
				case current_scan_line_state is
					
					-- when the scan line is in the Front porch state
					when FP=>
						dac <= std_logic_vector(to_unsigned(blanking_level, 8));
						if counter = FP_time then
							counter := 0;
							current_scan_line_state <= ST;
						end if;
					
					-- when the scan line is in the Sync tip state	
					when ST =>
						dac <= std_logic_vector(to_unsigned(horizontal_synctip_level, 8));
						if counter = ST_time then
							counter := 0;
							current_scan_line_state <= BW;
						end if;
					
					-- when the scan line is in the Breezeway state
					when BW=>
						dac <= std_logic_vector(to_unsigned(blanking_level, 8));
						if counter = BW_time then
							counter := 0;
							current_scan_line_state <= CB;
						end if;
					
					-- when the scan line is in the color burst state
					when CB=>
						dac <= std_logic_vector(to_unsigned(blanking_level, 8));
						if counter = CB_time then
							counter := 0;
							current_scan_line_state <= BP;
						end if;
					
					-- when the scan line is in the Back porch state
					when BP=>
						dac <= std_logic_vector(to_unsigned(blanking_level, 8));
						if counter = BP_time then
							counter := 0;
							current_scan_line_state <= ACTIVE;
						end if;
					
					-- when the scan line is in the ACTIVE state
					when ACTIVE=>
						
						if counter < 235 then
							dac <= std_logic_vector(to_unsigned(black, 8));
						elsif counter > 2395 then
							dac <= std_logic_vector(to_unsigned(black, 8));
						else 
							-- for now we want to display 8 color colums, which leaves us 6 cycle without any display
							-- inserting different test_patterns
							if test_pattern = "00" then
								-- generate simple black and white blink
									if alternate < 45 then
										dac <= std_logic_vector(to_unsigned(black, 8));
									else
										dac <= std_logic_vector(to_unsigned(white, 8));
									end if;
							
							elsif test_pattern = "01" then
								-- generate different gray scale image
									if counter < 505 then
										dac <= std_logic_vector(to_unsigned(white, 8));
									elsif counter < 775 then
										dac <= std_logic_vector(to_unsigned(yellow, 8));
									elsif counter < 1045 then
										dac <= std_logic_vector(to_unsigned(cyan, 8));
									elsif counter < 1315 then
										dac <= std_logic_vector(to_unsigned(green, 8));
									elsif counter < 1585 then
										dac <= std_logic_vector(to_unsigned(magenta, 8));
									elsif counter < 1855 then
										dac <= std_logic_vector(to_unsigned(red, 8));
									elsif counter < 2125 then
										dac <= std_logic_vector(to_unsigned(blue, 8));
									else
										dac <= std_logic_vector(to_unsigned(black, 8));
									end if;
							-- test pattern generator if case
							end if;
							-- code are deleted from here
						end if;
						
						if counter = ACTIVE_time then
							counter := 0;																							-- counter set to 0 to start recording new time
							line_counter := line_counter+1;																	-- as one scan line is drawn increment the line_counter
							current_scan_line_state <= FP;																	-- again start with front porch
							color_step_counter := 0;																			-- this variable is for test only
						end if;
						
						-- if the line counter is reached to 525 then current_picture state should be vertical blanking
						-- the odd field should be displayed
						if line_counter = 525 then
							current_field_type <= odd_field;																	-- next field is odd field
							current_picture_state <= vertical_blanking;													-- this means the even field are drawn and next vertical blanking is drawn
							line_counter := 0;																					-- reset the counter to start the new line
							counter := 0;
							alternate := alternate+1;
							if alternate = 90 then
							 alternate :=0;
							end if;
						end if;
						
						-- if the line counter reaches 262 and tick counter reaches 1587 
						-- the even field should be displayed next
						if line_counter = 262 and tick_counter = 1587 then
							current_field_type <= even_field;																-- next field is even field
							current_picture_state <= vertical_blanking;													-- start the vertical blanking state
							counter := 0;
						end if;
						
					when others=>
						-- do nothing
						
				-- current_scan_line_state end case
				end case;
	
			when others =>
			-- do nothing
		
		-- end picture state case
		end case;
		-- rising edge end if
		end if;
		
	end process;

end Behavioral;

