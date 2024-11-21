--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   07:50:10 01/22/2023
-- Design Name:   
-- Module Name:   /home/ise/Documents/FPGA project/NTSC_video_controller/color_carrier_Tb.vhd
-- Project Name:  NTSC_video_controller
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: color_carrier
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY color_carrier_Tb IS
END color_carrier_Tb;
 
ARCHITECTURE behavior OF color_carrier_Tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT color_carrier
    PORT(
         clock_in : IN  std_logic;
         enable : IN  std_logic;
         output_enable : IN  std_logic;
         color_select : IN  std_logic_vector(2 downto 0);
         square_out : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clock_in : std_logic := '0';
   signal enable : std_logic := '0';
   signal output_enable : std_logic := '0';
   signal color_select : std_logic_vector(2 downto 0) := (others => '0');

 	--Outputs
   signal square_out : std_logic;

   -- Clock period definitions
   constant clock_in_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: color_carrier PORT MAP (
          clock_in => clock_in,
          enable => enable,
          output_enable => output_enable,
          color_select => color_select,
          square_out => square_out
        );

	clock_in <= not clock_in after clock_in_period;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns
		enable <= '0';
		output_enable <= '0';
      wait for 100 ns;	
		
		enable <= '1';
		output_enable <= '1';
		wait for 500 ns;
		color_select <= "001";
		wait for 500 ns;
		color_select <= "010";
		wait for 500 ns;
		color_select <= "011";
		wait for 500 ns;
		color_select <= "100";
		wait for 500 ns;
		color_select <= "101";
		wait for 500 ns;
		color_select <= "110";
		wait for 500 ns;
		output_enable <= '0';
		
		wait;
   end process;

END;
