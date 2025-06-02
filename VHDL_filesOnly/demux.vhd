----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:48:48 10/29/2023 
-- Design Name: 
-- Module Name:    demux - Behavioral 
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

entity demux is
    Port ( bram_dout : in  STD_LOGIC_VECTOR (7 downto 0);
           dout_select : in  STD_LOGIC;
           sdram_din : out  STD_LOGIC_VECTOR (7 downto 0);
           cpu_din : out  STD_LOGIC_VECTOR (7 downto 0));
end demux;

architecture Behavioral of demux is

begin
	WITH dout_select SELECT
		sdram_din <=	bram_dout WHEN '0',
							"00000000" WHEN OTHERS;
	WITH dout_select SELECT
		cpu_din <=	bram_dout WHEN '1',
						"00000000" WHEN OTHERS;

end Behavioral;

