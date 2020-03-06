-- Quartus Prime VHDL Template
-- Basic Shift Register
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Left_Shift is
	port (clock, reset	:	in std_logic;
			Left_output				:	out std_logic_vector(6 downto 0));
end entity;

architecture Left_Shift_arch of Left_Shift is

signal shift_left_temp	:	unsigned(6 downto 0) := "0000011";

begin
SHIFT_R	: process(clock, reset)
	begin
		if (rising_edge(clock)) then
			if (reset = '1') then
				shift_left_temp <= to_unsigned(3, shift_left_temp'Length);
			else
				shift_left_temp <= shift_left_temp(5 downto 0) & shift_left_temp(6);
			end if;
		end if;
		Left_output <= std_logic_vector(shift_left_temp);
	end process;
	
	
end architecture;

