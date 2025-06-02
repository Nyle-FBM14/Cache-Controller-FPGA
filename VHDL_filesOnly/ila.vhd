-------------------------------------------------------------------------------
-- Copyright (c) 2023 Xilinx, Inc.
-- All Rights Reserved
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor     : Xilinx
-- \   \   \/     Version    : 13.4
--  \   \         Application: XILINX CORE Generator
--  /   /         Filename   : ila.vhd
-- /___/   /\     Timestamp  : Sun Oct 29 23:18:12 EDT 2023
-- \   \  /  \
--  \___\/\___\
--
-- Design Name: VHDL Synthesis Wrapper
-------------------------------------------------------------------------------
-- This wrapper is used to integrate with Project Navigator and PlanAhead

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY ila IS
  port (
    CONTROL: inout std_logic_vector(35 downto 0);
    CLK: in std_logic;
    DATA: in std_logic_vector(63 downto 0);
    TRIG0: in std_logic_vector(7 downto 0));
END ila;

ARCHITECTURE ila_a OF ila IS
BEGIN

END ila_a;
