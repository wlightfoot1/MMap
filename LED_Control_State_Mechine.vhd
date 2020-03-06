library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity LED_Control_State_Mechine is
	port	(clk            : in  std_logic;                         -- system clock
          reset          : in  std_logic;                         -- system reset
          PB_pulse       : in  std_logic;                         -- Pushbutton to change state  
          SW             : in  std_logic_vector(3 downto 0);      -- Switches that determine next state
          HS_LED_control : in  std_logic;                         -- Software is in control when asserted (=1)
          SYS_CLKs_sec   : in  std_logic_vector(31 downto 0);     -- Number of system clock cycles in one second
          Base_rate      : in  std_logic_vector(7 downto 0);      -- base transition time in seconds, fixed-point data type
          LED_reg			 : in  std_logic_vector(7 downto 0);      -- LED register
          LED_HW_control : out std_logic_vector(7 downto 0));     -- LEDs on the DE10-Nano board
end entity;

architecture LED_Control_State_Mechine_arch of LED_Control_State_Mechine is
---------component_list---------------------------------------------------
component Up_Counter is
	port (clock, reset	:	in std_logic;
			Up_output					:	out std_logic_vector(6 downto 0));
end component;
--------------------------------------------------------------------------
component Down_Counter is
	port (clock, reset	:	in std_logic;
			Down_output					:	out std_logic_vector(6 downto 0));
end component;
--------------------------------------------------------------------------
component Left_Shift is
	port (clock, reset	:	in std_logic;
			Left_output					:	out std_logic_vector(6 downto 0));
end component;
--------------------------------------------------------------------------
component Right_Shift is
	port (clock, reset	:	in std_logic;
			Right_output				:	out std_logic_vector(6 downto 0));
end component;
--------------------------------------------------------------------------
component Clock_Control is
	port (clk								: in std_logic;
			reset								: in std_logic;
			SYS_CLKs_sec					: in std_logic_vector(31 downto 0);
			Base_rate 						: in std_logic_vector(7 downto 0);
			clk_1hz, clk_2hz, clk_4hz	: out std_logic);
end component;		
--------------------------------------------------------------------------

type state_type is (s0, s1, s2, s3, s4);
signal curr_state, next_state	:	state_type;

signal clk_base_rate			: std_logic := '0';
signal clk_2x_base_rate		: std_logic := '0';
signal clk_4x_base_rate		: std_logic := '0';

--LED(7) signals
signal LED_const_blink	: std_logic := '0';
signal LED_display_on	: std_logic := '0';

signal count_int	: integer := 0;
signal count_max	: integer := 50000000;

signal LED_sm_control	: std_logic_vector(6 downto 0);

signal LED_up_count			: std_logic_vector(6 downto 0);
signal LED_down_count		: std_logic_vector(6 downto 0);
signal LED_left_shift		: std_logic_vector(6 downto 0);
signal LED_right_shift		: std_logic_vector(6 downto 0);

signal tog						: std_logic := '0';
signal pattern_user			: std_logic_vector(6 downto 0);
signal pattern_1				: std_logic_vector(6 downto 0) := "0001111";
signal pattern_2				: std_logic_vector(6 downto 0) := "1111000";

    begin
		
		LED_HW_control <= (LED_const_blink & LED_sm_control);

		CUSTOM_PATTERN	:	process(clk_4x_base_rate, pattern_user, pattern_1, pattern_2)
							begin
								if(rising_edge(clk_4x_base_rate)) then
									tog <= not tog;
									if(tog = '1') then
										pattern_user <= not pattern_1;
									else
										pattern_user <= not pattern_2;
									end if;
								end if;
		end process;
		
		LED7_BLINKING	:	process(clk_2x_base_rate)
							begin
								if(rising_edge(clk_2x_base_rate)) then
									LED_const_blink <= not LED_const_blink;
								end if;
		end process;
		
		STATE_MEM		:	process(clk, reset, PB_pulse, LED_display_on, count_int)
							begin
							if(reset = '1') then
								curr_state <= curr_state;
							elsif (rising_edge(clk)) then
								if (LED_display_on = '1') then
									if (count_int >= count_max) then
										count_int <= 0;
										curr_state <= next_state;
										LED_display_on <= '0';
									else
										LED_display_on <= '1';
										count_int <= count_int + 1;
									end if;
								elsif (PB_pulse = '0' and LED_display_on = '0') then
										LED_display_on <= '1';
								end if;
							end if;
		end process;
		
		NEXT_STATE_LOGIC		:	process(curr_state, SW, PB_pulse)
							begin
								case (SW) is
									when "0000" => next_state <= s0;
									when "0001" => next_state <= s1;
									when "0010" => next_state <= s2;
									when "0011" => next_state <= s3;
									when "0100" => next_state <= s4;
									when others => next_state <= curr_state;
								end case;
		end process;
		
		OUTPUT_LOGIC	: process(clk_base_rate, LED_const_blink, LED_up_count, LED_down_count, LED_left_shift, LED_right_shift, SW, LED_display_on, curr_state)
							begin
								if(LED_display_on = '0') then
									case (curr_state) is
										when s0 => LED_sm_control <= LED_up_count;
										when s1 => LED_sm_control <= LED_down_count;
										when s2 => LED_sm_control <= LED_left_shift;
										when s3 => LED_sm_control <= LED_right_shift;
										when s4 => LED_sm_control <= pattern_user;
									end case;
								else
									LED_sm_control <= "000" & SW;
								end if;
		end process;		
		
		
		
		A0	:	Up_Counter port map (clock => clk_base_rate, 
											reset => reset,
											Up_output => LED_up_count);
				
		A1	:	Down_Counter port map (clock => clk_4x_base_rate, 
											reset => reset,
											Down_output => LED_down_count);
				
		A2	:	Left_Shift port map (clock => clk_4x_base_rate, 
											reset => reset,
											Left_output => LED_left_shift);
				
		A3	:	Right_Shift port map (clock => clk_2x_base_rate, 
											reset => reset,
											Right_output => LED_right_shift);
		
		B0	:	Clock_Control port map (clk => clk,
												reset => reset,
												Base_rate => Base_rate,
												SYS_CLKs_sec => SYS_CLKs_sec,
												clk_1hz => clk_base_rate,
												clk_2hz => clk_2x_base_rate,
												clk_4hz => clk_4x_base_rate);
end architecture;