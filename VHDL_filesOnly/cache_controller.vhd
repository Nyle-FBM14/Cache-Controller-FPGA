----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:03:01 10/28/2023 
-- Design Name: 
-- Module Name:    cache_controller - Behavioral 
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

entity cache_controller is
    Port ( clk : in  STD_LOGIC;
           addr_in : in  STD_LOGIC_VECTOR (13 downto 0);
           wrRDcpu : in  STD_LOGIC;
           cs : in  STD_LOGIC;
			  addr_out : out STD_LOGIC_VECTOR (13 downto 0);
           rdy : out  STD_LOGIC;
           wrRDmem : out  STD_LOGIC;
           mms : out  STD_LOGIC;
			  cacheAddr: out STD_LOGIC_VECTOR (7 downto 0);
			  wen: out STD_LOGIC_VECTOR (0 DOWNTO 0);
           din_select : out  STD_LOGIC;
           dout_select : out  STD_LOGIC;
			  state_a	:out STD_LOGIC_VECTOR (2 downto 0);
			  valid	: out std_logic;
			  dirty	: out std_logic
			  );
end cache_controller;

architecture Behavioral of cache_controller is
	signal tag : STD_LOGIC_VECTOR (5 downto 0);
	signal index: std_logic_vector(2 downto 0);
	signal offset: std_logic_vector(4 downto 0);
	signal state: std_logic_vector(2 downto 0) := "000";
	signal next_state: std_logic_vector(2 downto 0) := "000";
	--signal hit: std_logic;
	signal vbit: std_logic;
	signal dbit: std_logic;
	signal counter: std_logic_vector(4 downto 0) := (others => '0');
	signal try : std_logic;
	
	--signal sBram_addr: std_logic_vector(2 downto 0); --using index signal
	signal sBram_din, sBram_dout: std_logic_vector(7 downto 0);
	signal sBram_wen: std_logic_vector(0 downto 0) := "0";

	COMPONENT bram
	  PORT (
		 clka : IN STD_LOGIC;
		 wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		 addra : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	  );
	END COMPONENT;
begin
	service_bram : bram
	  PORT MAP (
		 clka => clk,
		 wea => sBram_wen,
		 addra => index,
		 dina => sBram_din,
		 douta => sBram_dout
	  );

	tag <= addr_in(13 downto 8);
	index <= addr_in(7 downto 5);
	offset <= addr_in(4 downto 0);
	--fsm states
	--000 - 0 ready
	--001 - 1 checking tag
	--010 - 2 read
	--011 - 3 write
	--100 - 4 delay read from main memory
	--101 - 5 read from main memory
	--110 - 6 write to main memory
	--111 - 7 delay write from main memory
	
	process(clk)
	begin
		if(clk'Event and clk = '1') then
			if(state = "000") then --checks for cpu request
				if(cs = '1') then
					rdy <= '0';
					next_state <= "001";
				else
					rdy <= '1';
					next_state <= "000";
				end if;
				wen <= "0";
				mms <= '0';
				sBram_wen <= "0";
			--**************************************************************************************	
			elsif(state = "001") then --if hit check read/write
				--check tag
				sBram_wen <= "0";
				vbit <= sBram_dout(6);
				dbit <= sBram_dout(7);
				
				if(sBram_dout(5 downto 0) = tag and vbit = '1') then --if hit check if read or write request
					--hit
					if(wrRDcpu = '0') then
						next_state <= "010"; --go to read state
					else
						next_state <= "011"; --go to write state
					end if;
				else																	--if miss check if dbit is 0 or 1
					--miss
					if(dbit = '0') then 
						next_state <= "101"; --go to dbit=0 state
					else
						next_state <= "110"; --go to dbit=1 state
					end if;
				end if;
				rdy <= '0';
				wen <= "0";
				mms <= '0';
			--**************************************************************************************
			elsif(state = "010") then --process read request
				--ready
					dout_select <= '1'; --direct cache data to cpu
					wen <= "0";			  --read from cache
					mms <= '0';
					
					cacheAddr(7 downto 5) <= index;
					cacheAddr(4 downto 0) <= offset;
					
					sBram_wen <= "0";
					next_state <= "000";
					rdy <= '1';
			--**************************************************************************************
			elsif(state = "011") then --process write request
				--write
					wen <= "1"; --write to cache
					mms <= '0';
					din_select <= '1'; --direct cpu data to cache
					cacheAddr(7 downto 5) <= index;
					cacheAddr(4 downto 0) <= offset;
					
					--update tag info
					sBram_wen <= "1";
					sBram_din(7) <= '1'; --sets dbit to 1
					sBram_din(6) <= '1';	--sets vbit to 1
					sBram_din(5 downto 0) <= tag;
					
					next_state <= "000";
					rdy <= '1';
			--**************************************************************************************
			elsif(state = "100") then --waited 1 clock cycle before asserting main mem strobe
				rdy <= '0';
				mms <= '1';
				wen <= "0";
				wrRDmem <= '0';
				din_select <= '0'; --direct data from main memory to cache
				
				if(counter = "11111") then
					--update tag info
					sBram_wen <= "1";
					sBram_din(7) <= '0'; --sets dbit to 1
					sBram_din(6) <= '1';	--sets vbit to 1
					sBram_din(5 downto 0) <= tag; --change tag to the one given by CPU
					next_state <= "001"; --service initial request
					counter <= "00000";
				else
					counter <= counter + '1';
					next_state <= "101";
				end if;
			--**************************************************************************************
			elsif(state = "101") then --read from main mem
				rdy <= '0';
				mms <= '0';
				addr_out(13 downto 8) <= tag;
				addr_out(7 downto 5) <= index;
				addr_out(4 downto 0) <= counter;
				wen <= "1"; --write to cache
				wrRDmem <= '0'; --read from main memory
				din_select <= '0'; --direct main memory data to cache
				
				sBram_wen <= "0";
				next_state <= "100";
			--**************************************************************************************
			elsif(state = "110") then --write to main mem
				rdy <= '0';
				sBram_wen <= "0"; --read from service bram to get tag to be replaced
				mms <= '0';
				addr_out(13 downto 8) <= sBram_dout(5 downto 0);
				addr_out(7 downto 5) <= index;
				addr_out(4 downto 0) <= counter;
				wen <= "0"; --read from cache
				wrRDmem <= '1'; --write to main memory
				dout_select <= '0'; --direct cache data to main memory
				
				next_state <= "111";
			
			elsif(state = "111") then --waited 1 clock cycle before asserting main mem strobe
				rdy <= '0';
				mms <= '1';
				wen <= "0";
				wrRDmem <= '1';
				dout_select <= '0';
				sBram_wen <= "0";
				
				if(counter = "11111") then
					next_state <= "101"; --read block requested by cpu from main memory
					counter <= "00000";
				else
					counter <= counter + '1';
					next_state <= "110";
				end if;
				
			else
				next_state <= state; 
			end if;
		end if;
		state_a <= state;
		state <= next_state;
		valid <= vbit;
		dirty <= dbit;
		
	end process;
end Behavioral;

