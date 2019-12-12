library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


entity WS2812_LED is
port (
	clk : in std_logic;
	reset : in std_logic;
	dout : out std_logic);
end WS2812_LED;

architecture behavior of WS2812_LED is

type block_cycle_t is (led0, led1, led2, led3, led4, led5, led6, led7, rest);

signal block_cycle : block_cycle_t := rest;

type bit_cycle_t is (zero_high, zero_low, one_high, one_low, rest_low);

signal bit_cycle : bit_cycle_t := zero_low;

-- 220ns to 380ns - 11 to 19 clock cycles
constant ZERO_HIGH_COUNT : integer := 11;

-- 580ns to 1us - 34 to 50 clock cycles
constant ZERO_LOW_COUNT : integer := 34;

-- 580ns to 1us - 34 to 50 clock cycles
constant ONE_HIGH_COUNT : integer := 34;

-- 220ns to 420ns - 11 to 21 clock cycles
constant ONE_LOW_COUNT : integer := 11;

-- >280us - >14000 clock cycles
constant REST_COUNT : integer := 14000;
--                                                      GGGGGGGGRRRRRRRRBBBBBBBB
constant LED0_COLOR : std_logic_vector(23 downto 0) := "000000001111111100000000"; -- Red
constant LED1_COLOR : std_logic_vector(23 downto 0) := "100000001111111100000000"; -- Orange
constant LED2_COLOR : std_logic_vector(23 downto 0) := "111111111111111100000000"; -- Yellow
constant LED3_COLOR : std_logic_vector(23 downto 0) := "111111110000000000000000"; -- Green
constant LED4_COLOR : std_logic_vector(23 downto 0) := "000000000000000011111111"; -- Blue
constant LED5_COLOR : std_logic_vector(23 downto 0) := "000000000100101110000010"; -- Indigo
constant LED6_COLOR : std_logic_vector(23 downto 0) := "000000001001010011010011"; -- Violet
constant LED7_COLOR : std_logic_vector(23 downto 0) := "000000001111111111111111"; -- Magenta

signal bit_counter : integer := REST_COUNT;
signal color_counter : integer := 0;
signal current_color : std_logic_vector(23 downto 0) := (others => '0');


begin
	
	ledout : process(clk)
	begin
	
		if (rising_edge(clk)) then
			if (reset = '1') then
				bit_counter := REST_COUNT;
				color_counter := 0;
				block_cycle := rest;
				bit_cycle := zero_low;
				current_color := (others => '0');
			else
				if (bit_counter = 0) then
					-- we have finished whatever part we are currently working on.
					if (bit_cycle = zero_high) then
						-- send second half of 0 bit
						bit_cycle := zero_low;
						bit_counter := ZERO_LOW_COUNT;
					elsif (bit_cycle = one_high) then
						-- send second half of 1 bit
						bit_cycle := one_low;
						bit_counter := ONE_LOW_COUNT;
					else
						-- we need to step to the next part.
						if (color_counter = 0) then
							color_counter := 23;
							case block_cycle is
								when led0 =>
									block_cycle := led1;
									current_color := LED1_COLOR;
								when led1 =>
									block_cycle := led2;
									current_color := LED2_COLOR;
								when led2 =>
									block_cycle := led3;
									current_color := LED3_COLOR;
								when led3 =>
									block_cycle := led4;
									current_color := LED4_COLOR;
								when led4 =>
									block_cycle := led5;
									current_color := LED5_COLOR;
								when led5 =>
									block_cycle := led6;
									current_color := LED6_COLOR;
								when led6 =>
									block_cycle := led7;
									current_color := LED7_COLOR;
								when led7 =>
									block_cycle := rest;
									current_color := (others => '0');
								when rest =>
									block_cycle := led0;
									current_color := LED0_COLOR;
							end case;
							
							if ( block_cycle = rest ) then
								bit_cycle := rest_low;
								bit_counter := REST_COUNT;
							elsif ( current_color(0) = '0') then
								bit_cycle := zero_high;
								bit_counter := ZERO_HIGH_COUNT;
							else
								bit_cycle := one_high;
								bit_counter := ONE_HIGH_COUNT;
							end if;
								
						end if;
					end if;
				else
					bit_counter := bit_counter - 1;
				end if;
			
			
			end if;
			
			-- Now that we know what to output, set output.
			if ((bit_cycle = zero_high) or (bit_cycle = one_high)) then
				dout := '1';
			else
				-- zero_low, one_low or rest
				dout := '0';
			end if;
		end if;
	end process ledout;	
	
		

end behavior;