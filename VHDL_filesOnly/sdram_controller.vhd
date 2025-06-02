----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:54:25 10/29/2023 
-- Design Name: 
-- Module Name:    sdram_controller - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sdram_controller is
    Port ( clk	: std_logic;
			  addr : in  STD_LOGIC_VECTOR (13 downto 0);
           wrRD : in  STD_LOGIC;
           mms : in  STD_LOGIC;
           din : in  STD_LOGIC_VECTOR (7 downto 0);
           dout : out  STD_LOGIC_VECTOR (7 downto 0));
end sdram_controller;

architecture Behavioral of sdram_controller is

	type RAM is array (16384 downto 0) of std_logic_vector (7 downto 0);
	
	signal SDRAM: RAM := (others => (others => '0'));
	
begin
	process(clk)
	begin
		if(clk'Event and clk='1') then
			if(wrRD = '1' and mms = '1') then
				SDRAM(conv_integer(unsigned(addr))) <= din;
			elsif(wrRD = '0' and mms = '1') then
				dout <= SDRAM(conv_integer(unsigned(addr)));
			end if;
		end if;
	end process;
end Behavioral;

