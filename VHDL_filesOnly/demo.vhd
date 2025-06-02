----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:53:29 10/29/2023 
-- Design Name: 
-- Module Name:    demo - Behavioral 
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

entity demo is
    Port (
        clk  : in  STD_LOGIC;
        rst  : in  STD_LOGIC;
        data : out STD_LOGIC_VECTOR (63 downto 0)
    );
end demo;

architecture Behavioral of demo is
    -- chipscope cores
    component icon
        PORT (
            CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
            CONTROL1 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0)
        );
    end component;

    component mux
        Port (
            sdram_dout : in  std_logic_vector(7 downto 0);
				cpu_dout   : in  std_logic_vector(7 downto 0);
            din_select : in  std_logic;
            bram_din   : out std_logic_vector(7 downto 0)
        );
    end component;

    component demux
        Port (
            bram_dout   : in  std_logic_vector(7 downto 0);
            dout_select : in  std_logic;
            sdram_din   : out std_logic_vector(7 downto 0);
            cpu_din     : out std_logic_vector(7 downto 0)
        );
    end component;

    component ila
        PORT (
            CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
            CLK     : IN STD_LOGIC;
            DATA    : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
            TRIG0   : IN STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    end component;

    component vio
        PORT (
            CONTROL    : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
            ASYNC_OUT  : OUT STD_LOGIC_VECTOR(17 DOWNTO 0)
        );
    end component;

    COMPONENT sram
        PORT (
            clka  : IN STD_LOGIC;
            wea   : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            dina  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    -- cache controller
    component cache_controller
        Port (
            clk         : in  STD_LOGIC;
            addr_in     : in STD_LOGIC_VECTOR (13 downto 0);
            wrRDcpu     : in  STD_LOGIC;
            cs          : in  STD_LOGIC;
				addr_out    : out STD_LOGIC_VECTOR (13 downto 0);
            rdy         : out STD_LOGIC;
            wrRDmem     : out STD_LOGIC;
            mms         : out STD_LOGIC;
            cacheAddr   : out STD_LOGIC_VECTOR (7 downto 0);
            wen         : out STD_LOGIC_VECTOR (0 downto 0);
            din_select  : out STD_LOGIC;
            dout_select : out STD_LOGIC;
				state_a		: out std_logic_vector (2 downto 0);
				valid	: out std_logic;
				dirty	: out std_logic
        );
    end component;

    -- cpu
    component CPU_gen
        Port ( 
            clk     : in  STD_LOGIC;
            rst     : in  STD_LOGIC;
            trig    : in  STD_LOGIC;
            -- Interface to the Cache Controller.
            Address : out  STD_LOGIC_VECTOR (15 downto 0);
            wr_rd   : out  STD_LOGIC;
            cs      : out  STD_LOGIC;
            DOut    : out  STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    -- sdram controller with sdram
    component sdram_controller
        Port ( 
            clk   : std_logic;
            addr  : in  STD_LOGIC_VECTOR (13 downto 0);
            wrRD  : in  STD_LOGIC;
            mms   : in  STD_LOGIC;
            din   : in  STD_LOGIC_VECTOR (7 downto 0);
            dout  : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

   -- signals
	signal address     : std_logic_vector(13 downto 0) := (others => '0'); --connects cpu address and CC addr in
	signal cpu_address : std_logic_vector(15 downto 0) := (others => '0');
	signal sdram_address : std_logic_vector(13 downto 0) := (others => '0'); --connects CC addr out to sdram CC
	
	signal state		 : std_logic_vector (2 downto 0);
	signal bram_addr   : std_logic_vector(7 downto 0) := (others => '0'); --connect cacheAddr and sram addra
	signal bram_din    : std_logic_vector(7 downto 0) := (others => '0');
	signal bram_dout   : std_logic_vector(7 downto 0) := (others => '0');
	signal bram_wen    : std_logic_vector(0 downto 0) := (others => '0');
	signal cpu_dout    : std_logic_vector(7 downto 0) := (others => '0');
	signal sdram_dout  : std_logic_vector(7 downto 0) := (others => '0');
	signal cpu_din    : std_logic_vector(7 downto 0) := (others => '0');
	signal sdram_din  : std_logic_vector(7 downto 0) := (others => '0');
	signal din_select  : std_logic := '0';
	signal dout_select : std_logic := '0';
	signal wr_rd_cpu   : std_logic := '0';
	signal rdy         : std_logic := '0';
	signal wr_rd_mem   : std_logic := '0';
	signal mms         : std_logic := '0';
	signal cs          : std_logic := '0';
	signal ila_data    : std_logic_vector(63 downto 0) := (others => '0');
	signal trig0       : std_logic_vector(7 DOWNTO 0) := (others => '0');
	signal vio_out     : std_logic_vector(17 downto 0) := (others => '0');
	signal control0    : std_logic_vector(35 DOWNTO 0) := (others => '0');
	signal control1    : std_logic_vector(35 DOWNTO 0) := (others => '0');
	signal vbit			 : std_logic := '0';
	signal dbit        : std_logic := '0';

begin

   --control0 <= (others => '0');
   --control1 <= (others => '0');
	address <= cpu_address(13 downto 0);

   -- icon
   iconA : icon
       port map (
           CONTROL0 => control0,
           CONTROL1 => control1
       );

   -- ila
   ilaA : ila
       port map (
           CONTROL => control0,
           CLK     => clk,
           DATA    => ila_data,
           TRIG0   => trig0
       );

   -- vio
   system_vio : vio
       port map (
           CONTROL   => control1,
           ASYNC_OUT => vio_out
       );

   -- bram
   cache : sram
       PORT MAP (
           clka  => clk,
           wea   => bram_wen, -- Matched signal types
           addra => bram_addr,
           dina  => bram_din,
           douta => bram_dout
       );

   -- cpu
   CPU : CPU_gen
       port map (
           clk     => clk,
           rst     => rst,
           trig    => rdy,
           Address => cpu_address,
           wr_rd   => wr_rd_cpu,
           cs      => cs,
           DOut    => cpu_dout
       );

   -- MUX and DEMUX
   MUX_inst : MUX
       port map (
           cpu_dout   => cpu_dout,
           sdram_dout => sdram_dout,
           din_select => din_select,
           bram_din   => bram_din
       );

   DEMUX_inst : DEMUX
       port map (
           bram_dout   => bram_dout,
           dout_select => dout_select,
           sdram_din   => sdram_din,
           cpu_din     => cpu_din
       );

   -- cache controller
   cache_ctrl : cache_controller
       port map (
           clk         => clk,
           addr_in     => address,
           wrRDcpu     => wr_rd_cpu,
           cs          => cs,
			  addr_out	  => sdram_address,
           rdy         => rdy,
           wrRDmem     => wr_rd_mem,
           mms         => mms,
           cacheAddr   => bram_addr,
           wen         => bram_wen,
           din_select  => din_select,
           dout_select => dout_select,
			  state_a	  => state,
			  valid       => vbit,
			  dirty       => dbit
       );

   -- connecting to the sdram controller
   sdram_ctrl : sdram_controller
       port map (
           clk  => clk,
           addr => address,
           wrRD => wr_rd_mem,
           mms  => mms,
           din  => sdram_din,
           dout => sdram_dout
       );

   -- Output data from the ILA
	ila_data(63 downto 50) <= address; --address from cpu to cache controller
	ila_data(49) <= wr_rd_cpu;
	ila_data(48) <= cs;
	ila_data(47 downto 34) <= sdram_address; --address cache controller sends to main mem
	ila_data(33) <= wr_rd_mem;
	ila_data(32) <= mms;
	ila_data(31 downto 24) <= bram_addr; --address cache controller sends to cache
	ila_data(23) <= bram_wen(0);
	ila_data(22 downto 15) <= bram_din; --data entering cache
	ila_data(14 downto 7) <= bram_dout; --data leaving cache
	ila_data(6) <= din_select;
	ila_data(5) <= dout_select;
	ila_data(4) <= rdy;
	ila_data(3 downto 1) <= state;
	ila_data(0) <= dbit;
	
   data <= ila_data;

end Behavioral;
