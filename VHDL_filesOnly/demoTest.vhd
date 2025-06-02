--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:19:06 10/30/2023
-- Design Name:   
-- Module Name:   /home/student2/nmelegri/coe758/project1v2/project1/cacheContProject/demoTest.vhd
-- Project Name:  cacheContProject
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: demo
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
 
ENTITY demoTest IS
END demoTest;
 
ARCHITECTURE behavior OF demoTest IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT demo
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         data : OUT  std_logic_vector(63 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '1';

 	--Outputs
   signal data : std_logic_vector(63 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: demo PORT MAP (
          clk => clk,
          rst => rst,
          data => data
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		      wait for 100 ns;	
		
		rst <= '0';
		
      wait for clk_period*100;

      -- insert stimulus here 
		

      wait;
   end process;

END;
