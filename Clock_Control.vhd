library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity Clock_Control is
	port (clk								: in std_logic;
			reset								: in std_logic;
			SYS_CLKs_sec					: in std_logic_vector(31 downto 0);
			Base_rate 						: in std_logic_vector(7 downto 0);
			clk_1hz, clk_2hz, clk_4hz	: out std_logic);
end entity;
	
architecture Clock_Control_arch of Clock_Control is

signal full_scaled_CLKs_sec		: unsigned(39 downto 0);
signal scaled_CLKs_sec				: unsigned(35 downto 0);

signal max_count 			: unsigned(35 downto 0) := x"000000000";
signal base_1x_count		: unsigned(35 downto 0) := x"000000000";
signal base_2x_count 	: unsigned(35 downto 0) := x"000000000";
signal base_4x_count 	: unsigned(35 downto 0) := x"000000000";

signal clk_1x_div			: std_logic := '0';
signal clk_2x_div			: std_logic := '0';
signal clk_4x_div			: std_logic := '0';

	begin
		full_scaled_CLKs_sec <= unsigned(SYS_CLKs_sec) * unsigned(Base_rate);
		scaled_CLKs_sec <= full_scaled_CLKs_sec(39 downto 4);
		
		max_count <= scaled_CLKs_sec;
		
		clk_1hz <= clk_1x_div;
		clk_2hz <= clk_2x_div;
		clk_4hz <= clk_4x_div;
		
		CLOCK_1x	:	process(clk, reset)
					begin
						if (reset = '1') then
							base_1x_count <= "000000000000000000000000000000000000";
						elsif(rising_edge(clk)) then
							if (base_1x_count >= max_count) then
								base_1x_count <= "000000000000000000000000000000000000";
								clk_1x_div <= not clk_1x_div;
							else
								base_1x_count <= base_1x_count + 1;
							end if;
						end if;
					end process;
	
		CLOCK_2x	:	process(clk, reset)
					begin
						if (reset = '1') then
							base_2x_count <= "000000000000000000000000000000000000";
						elsif(rising_edge(clk)) then
							if (base_2x_count >= max_count) then
								base_2x_count <= "000000000000000000000000000000000000";
								clk_2x_div <= not clk_2x_div;
							else
								base_2x_count <= base_2x_count + 2;
							end if;
						end if;
					end process;
	
		CLOCK_4x	:	process(clk, reset)
					begin
						if (reset = '1') then
							base_4x_count <= "000000000000000000000000000000000000";
						elsif(rising_edge(clk)) then
							if (base_4x_count >= max_count) then
								base_4x_count <= "000000000000000000000000000000000000";
								clk_4x_div <= not clk_4x_div;
							else
								base_4x_count <= base_4x_count + 4;
							end if;
						end if;
					end process;
					
					
		

end architecture;