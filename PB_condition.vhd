library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PB_condition is
	port	(clk	:	in std_logic;
			 PB	:	in std_logic;
			 reset	:	in std_logic;
			 PB_pulse	: out std_logic);
end entity;


architecture PB_condition_arch of PB_condition is

signal clk_div0	: std_logic := '0';
signal en			: std_logic := '0';
signal count		: integer := 0; 
signal max_count 	: integer := 2500000;

begin
	
	PB_pulse <= clk_div0;
	DELAY_50mns	:	process(clk, reset, en, PB)
		begin
			if (reset = '1') then
				count <= 0;
			elsif (rising_edge(clk)) then
				if (en = '1') then
					if (count >= max_count) then
						count <= 0;
						clk_div0 <= '1';
						en <= '0';
					else
						clk_div0 <= '0';
						count <= count  + 1;
					end if;
				elsif (PB = '0' and en = '0') then
					en <= '1';
				end if;
			end if;
		end process;
				
end architecture; 