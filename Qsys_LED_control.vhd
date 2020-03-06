library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

entity Qsys_LED_control is
	port(	clk					: in std_logic;
			reset_n				: in std_logic; --reset asserted low
			avs_s1_write		: in std_logic;
			avs_s1_read			: in std_logic;
			pushbutton			: in std_logic;
			avs_s1_address		: in std_logic_vector(1 downto 0);
			avs_s1_readdata	: out std_logic_vector(31 downto 0);
			avs_s1_writedata	: in std_logic_vector(31 downto 0);
			switches				: in std_logic_vector(3 downto 0);
			LEDs					: out std_logic_vector(7 downto 0));
end entity;

architecture Qsys_LED_control_arch of Qsys_LED_control is
component LED_control is
		port	(clk            : in  std_logic;                         -- system clock
				 reset          : in  std_logic;                         -- system reset
				 PB             : in  std_logic;                         -- Pushbutton to change state  
				 SW             : in  std_logic_vector(3 downto 0);      -- Switches that determine next state
				 HS_LED_control : in  std_logic;                        -- Software is in control when asserted (=1)
				 SYS_CLKs_sec   : in  std_logic_vector(31 downto 0);  -- Number of system clock cycles in one second
				 Base_rate      : in  std_logic_vector(7 downto 0);   -- base transition time in seconds, fixed-point data type
				 LED_reg        : in  std_logic_vector(7 downto 0);      -- LED register
				 LED            : out std_logic_vector(7 downto 0));     -- LEDs on the DE10-Nano board
end component;
	
	
	
	signal HS_LED_control_reg 	: std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(0, 32)); --HS_LED_control
	signal SYS_CLKs_sec_reg 	: std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(50000000, 32)); --SYS_CLKs_sec
	signal Base_rate_reg 		: std_logic_vector(31 downto 0) := "00000000000000000000000000010000"; --BAse_rate_reg
	signal LED_reg_reg 			: std_logic_vector(31 downto 0) := "00000000000000000000000001010101";  --LED_reg
	
	
	
	begin
	
--	HS_LED_control <= HS_LED_control_reg(0);
--	SYS_CLKs_sec	<= ;
--	LED_reg			<= "01010101";
--	Base_rate		<= "00010000";
	
		process (clk, avs_s1_read) is
			begin
				if(rising_edge(clk)) and (avs_s1_read = '1') then
					case (avs_s1_address) is
						when "00" => avs_s1_readdata <= HS_LED_control_reg;
						when "01" => avs_s1_readdata <= SYS_CLKs_sec_reg;
						when "10" => avs_s1_readdata <= Base_rate_reg;
						when "11" => avs_s1_readdata <= LED_reg_reg;
						when others => avs_s1_readdata <= (others => '0');
					end case;
				elsif(rising_edge(clk)) and (avs_s1_write = '1') then
					case (avs_s1_address) is
						when "00" => HS_LED_control_reg <= avs_s1_writedata;
						when "01" => SYS_CLKs_sec_reg <= avs_s1_writedata;
						when "10" => Base_rate_reg <= avs_s1_writedata;
						when "11" => LED_reg_reg <= avs_s1_writedata;
						when others => null;
					end case;
				end if;
		end process;
		
		A1	:	LED_control port map(
		clk				=> clk,
		reset				=> not reset_n,
		PB					=> pushbutton,
		HS_LED_control	=> HS_LED_control_reg(0),
		SW					=> switches,
		Base_rate		=> Base_rate_reg(7 downto 0),
		LED_reg			=> LED_reg_reg(7 downto 0),
		LED				=> LEDs,
		SYS_CLKs_sec	=> SYS_CLKs_sec_reg);
end architecture;