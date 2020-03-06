--Quartus Prime VHDL Template
-- Basic Shift Register
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity Right_Shift is
	port (clock, reset	:	in std_logic;
			Right_output				:	out std_logic_vector(6 downto 0));
end entity;

architecture Right_Shift_arch of Right_Shift is

signal shift_right_temp	:	unsigned(6 downto 0) := "0000001";

begin
SHIFT_R	: process(clock, reset)
	begin
		if (rising_edge(clock)) then
			if (reset = '1') then
				shift_right_temp <= to_unsigned(1, shift_right_temp'Length);
			else
				shift_right_temp <= shift_right_temp(0) & shift_right_temp(6 downto 1);
			end if;
		end if;
		Right_output <= std_logic_vector(shift_right_temp);
	end process;
	
	
end architecture;
