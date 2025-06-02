----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:43:19 10/29/2023 
-- Design Name: 
-- Module Name:    mux - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux is
    Port ( sdram_dout : in  STD_LOGIC_VECTOR (7 downto 0);
           cpu_dout : in  STD_LOGIC_VECTOR (7 downto 0);
           din_select : in  STD_LOGIC;
           bram_din : out  STD_LOGIC_VECTOR (7 downto 0));
end mux;

architecture Behavioral of mux is

begin
	WITH din_select SELECT
		bram_din <=	sdram_dout WHEN '0',
						cpu_dout WHEN OTHERS;

end Behavioral;

