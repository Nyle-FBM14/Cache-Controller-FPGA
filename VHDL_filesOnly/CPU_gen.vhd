----------------------------------------------------------------------------------
-- Company:				Ryerson University 
-- Engineer: 			Victor Dumitriu
-- 
-- Design Name: 		CPU Read/Write Transaction Generator
-- Module Name:		CPU_gen - Behavioral 
-- Target Devices: 	XC3S500E
--
-- Description: 		A testbench circuit for course COE758, Project 1.
--							The circuit plays the role of a CPU, generating read
--							and write transactions to various addresses. The Cache
--							Controller being designed for Project 1 must respond to
--							these transactions.
--
-- Dependencies: 		None.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CPU_gen is
	Port ( 
		clk 		: in  STD_LOGIC;
      rst 		: in  STD_LOGIC;
      trig 		: in  STD_LOGIC;
		-- Interface to the Cache Controller.
      Address 	: out  STD_LOGIC_VECTOR (15 downto 0);
      wr_rd 	: out  STD_LOGIC;
      cs 		: out  STD_LOGIC;
      DOut 		: out  STD_LOGIC_VECTOR (7 downto 0)
	);
end CPU_gen;

architecture Behavioral of CPU_gen is

	-- Pattern storage and control.
	signal patOut : std_logic_vector(24 downto 0);
	signal patCtrl : std_logic_vector(2 downto 0) := "111";
	signal updPat : std_logic;
	
	-- Main control.
	signal st1 : std_logic_vector(2 downto 0) := "000";
	signal st1N : std_logic_vector(2 downto 0);
	
	-- Rising edge detection.
	signal rReg1, rReg2 : std_logic;
	signal trig_r : std_logic;

begin

	--------------------------------------------------------------------------
	-- Main control FSM.
	--------------------------------------------------------------------------
	
	-- State storage.
	process(clk, rst, st1N)
	begin
		if(rst = '1')then
			st1 <= "000";
		else
			if(clk'event and clk = '1')then
				st1 <= st1N;
			end if;
		end if;
	end process;
	
	-- Next state generation.
	process(st1, trig_r)
	begin
		if(st1 = "000")then
			if(trig_r = '1')then
				st1N <= "001";
			else
				st1N <= "000";
			end if;
		elsif(st1 = "001")then
			st1N <= "010";
		elsif(st1 = "010")then
			st1N <= "011";
		elsif(st1 = "011")then
			st1N <= "100";
		elsif(st1 = "100")then
			st1N <= "101";
		elsif(st1 = "101")then
			st1N <= "000";
		else
			st1N <= "000";
		end if;
	end process;
	
	-- Output generation.
	process(st1)
	begin
		if(st1 = "000")then
			updPat <= '0';
			cs <= '0';
		elsif(st1 = "001")then
			updPat <= '1';
			cs <= '0';
		elsif(st1 = "010")then
			updPat <= '0';
			cs <= '1';
		elsif(st1 = "011")then
			updPat <= '0';
			cs <= '1';
		elsif(st1 = "100")then
			updPat <= '0';
			cs <= '1';
		elsif(st1 = "101")then
			updPat <= '0';
			cs <= '1';
		else
		end if;
	end process;
	
	--------------------------------------------------------------------------
	-- Pattern generator and control circuit.
	--------------------------------------------------------------------------
	
	-- Generator control circuit.
	process(clk, rst, updPat, patCtrl)
	begin
		if(rst = '1')then
			patCtrl <= "111";
		else
			if(clk'event and clk = '1')then
				if(updPat = '1')then
					patCtrl <= patCtrl + "001";
				else
					patCtrl <= patCtrl;
				end if;
			end if;
		end if;
	end process;
	
	-- Pattern storage.
	process(patCtrl)
	begin
		if(patCtrl = "000")then
			patOut <= "0001000100000000101010101"; --write 0xAA into address:010001 000 00000 						miss dbit=0
		elsif(PatCtrl = "001")then
			patOut <= "0001000100000010101110111"; --write 0xBB into adress:010001 000 00010 						hit
		elsif(PatCtrl = "010")then
			patOut <= "0001000100000000000000000"; --read from address: 010001 000 00000 should be 0xAA 			hit
		elsif(PatCtrl = "011")then
			patOut <= "0001000100000010000000000"; --read from address: 010001 000 00010 should be 0xBB 			hit
		elsif(PatCtrl = "100")then
			patOut <= "0011001101000110000000000"; --read from address: 110011 010 00110 should be 0x00 			miss dbit=0
		elsif(PatCtrl = "101")then
			patOut <= "0100010001000100000000000"; --read from address: 000100 010 00100 should be 0x00			miss dbit=0
		elsif(PatCtrl = "110")then
			patOut <= "0101010100000100110011001"; --write 0xCC to address: 010101 000 00100							miss dbit=1
		else
			patOut <= "0110011000000110000000000"; --read from address: 100110 000 00110								miss dbit=1
		end if;
	end process;
	
	--------------------------------------------------------------------------
	-- Rising edge detector.
	--------------------------------------------------------------------------
	
	-- Register 1
	process(clk, trig)
	begin
		if(clk'event and clk = '1')then
			rReg1 <= trig;
		end if;
	end process;
	
	-- Register 2
	process(clk, rReg1)
	begin
		if(clk'event and clk = '1')then
			rReg2 <= rReg1;
		end if;
	end process;
	
	trig_r <= rReg1 and (not rReg2);
	
	--------------------------------------------------------------------------
	-- Output connections.
	--------------------------------------------------------------------------
	
	-- Output mapping:
	-- Address [24 .. 9]
	-- Data [8 .. 1]
	-- Wr/Rd [0]
	
	Address(15 downto 0) <= patOut(24 downto 9);
	DOut(7 downto 0) <= patOut(8 downto 1);
	wr_rd <= patOut(0);


end Behavioral;
