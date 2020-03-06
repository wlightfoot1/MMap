library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

entity Up_Counter is
	generic
	(
		MIN_COUNT : natural := 0;
		MAX_COUNT : natural := 255
	);

	port (clock, reset	:	in std_logic;
			Up_output					:	out std_logic_vector(6 downto 0));

end entity;

architecture rtl of Up_counter is

begin

	process (clock, reset)
		variable   cnt			: integer range MIN_COUNT to MAX_COUNT;
	begin
		-- Synchronously update counter
		if (rising_edge(clock)) then
			if (reset = '1') then
				-- Reset the counter to 0
				cnt := 0;
			else
			-- Increment/decrement the counter
				cnt := cnt + 1;
			end if;
		end if;
		-- Output the current count
		Up_output <= std_logic_vector(to_unsigned(cnt, Up_output'Length));
	end process;

end rtl;
