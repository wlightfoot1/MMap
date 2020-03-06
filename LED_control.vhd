library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

LIBRARY altera;
USE altera.altera_primitives_components.all;

entity LED_control is
    port(
        clk            : in  std_logic;                         -- system clock
        reset          : in  std_logic;                         -- system reset
        PB             : in  std_logic;                         -- Pushbutton to change state  
        SW             : in  std_logic_vector(3 downto 0);      -- Switches that determine next state
        HS_LED_control : in  std_logic;                         -- Software is in control when asserted (=1)
        SYS_CLKs_sec   : in  std_logic_vector(31 downto 0);     -- Number of system clock cycles in one second
        Base_rate      : in  std_logic_vector(7 downto 0);      -- base transition time in seconds, fixed-point data type
        LED_reg        : in  std_logic_vector(7 downto 0);      -- LED register
        LED            : out std_logic_vector(7 downto 0)       -- LEDs on the DE10-Nano board
    );
end entity LED_control;

architecture LED_control_arch of LED_control is

component LED_Control_State_Mechine is 
	port	(clk            : in  std_logic;                         -- system clock
          reset          : in  std_logic;                         -- system reset
          PB_pulse       : in  std_logic;                         -- Pushbutton to change state  
          SW             : in  std_logic_vector(3 downto 0);      -- Switches that determine next state
          HS_LED_control : in  std_logic;                         -- Software is in control when asserted (=1)
          SYS_CLKs_sec   : in  std_logic_vector(31 downto 0);     -- Number of system clock cycles in one second
          Base_rate      : in  std_logic_vector(7 downto 0);      -- base transition time in seconds, fixed-point data type
          LED_reg			 : in  std_logic_vector(7 downto 0);      -- LED register
          LED_HW_control : out std_logic_vector(7 downto 0));     -- LEDs on the DE10-Nano board
end component;

component PB_condition is
	port	(clk			:	in std_logic;
			 PB			:	in std_logic;
			 reset		:	in std_logic;
			 PB_pulse	: out std_logic);
end component;

signal PB_s					: std_logic;
signal PB_pulse_s			: std_logic;
signal LEDS_s				: std_logic_vector(7 downto 0);
signal LED_HW_control	: std_logic_vector(7 downto 0);

begin

	LED <= LEDS_s;

	CONTROLER	:	process (HS_LED_control, LED_reg, LED_HW_control)
					begin
					
						if (HS_LED_control = '1') then
							LEDS_s <= LED_reg;
						else
							LEDS_s <= LED_HW_control;
						end if;
	end process;
	
	A1	:	PB_condition port map(
			clk 		=> clk,
			PB			=> PB,
			reset		=> reset,
			PB_pulse	=> PB_pulse_s);

	A2	:	LED_Control_State_Mechine port map(
			clk				=> clk,
			reset				=> reset,
			PB_pulse			=> PB_pulse_s,
			HS_LED_control	=> HS_LED_control,
			SW					=> SW,
			SYS_CLKs_sec	=> SYS_CLKs_sec,
			LED_reg			=> LED_reg,
			Base_rate		=> Base_rate,
			LED_HW_control	=> LED_HW_control);

end architecture; 