library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


entity WS2812_LED is
port (
	clk : in std_logic;
	reset : in std_logic;
	dout : out std_logic;
	block_out : out std_logic_vector(7 downto 0)--;
	--bit_out : out std_logic_vector(4 downto 0);
	--bit_counter_out : out unsigned(13 downto 0);
	--color_counter_out : out unsigned(4 downto 0);
	--current_color_out : out unsigned(23 downto 0)
	);
end WS2812_LED;

architecture behavior of WS2812_LED is

type block_cycle_t is (led0, led1, led2, led3, led4, led5, led6, led7, rest);

signal block_cycle : block_cycle_t := rest;

type bit_cycle_t is (zero_high, zero_low, one_high, one_low, rest_low);

signal bit_cycle : bit_cycle_t := rest_low;

-- 220ns to 380ns - 11 to 19 clock cycles
constant ZERO_HIGH_COUNT : unsigned(13 downto 0) := "00000000001011"; --11

-- 580ns to 1us - 34 to 50 clock cycles
constant ZERO_LOW_COUNT : unsigned(13 downto 0) := "00000000100010"; --34

-- 580ns to 1us - 34 to 50 clock cycles
constant ONE_HIGH_COUNT : unsigned(13 downto 0) := "00000000100010"; --34

-- 220ns to 420ns - 11 to 21 clock cycles
constant ONE_LOW_COUNT : unsigned(13 downto 0) := "00000000001011"; --11

-- >280us - >14000 clock cycles
constant REST_COUNT : unsigned(13 downto 0) := "11011010110000"; -- 14000

--                                                      GGGGGGGGRRRRRRRRBBBBBBBB
constant LED0_COLOR : unsigned(23 downto 0) := "000000001111111100000000"; -- Red
constant LED1_COLOR : unsigned(23 downto 0) := "100000001111111100000000"; -- Orange
constant LED2_COLOR : unsigned(23 downto 0) := "111111111111111100000000"; -- Yellow
constant LED3_COLOR : unsigned(23 downto 0) := "111111110000000000000000"; -- Green
constant LED4_COLOR : unsigned(23 downto 0) := "000000000000000011111111"; -- Blue
constant LED5_COLOR : unsigned(23 downto 0) := "000000000100101110000010"; -- Indigo
constant LED6_COLOR : unsigned(23 downto 0) := "000000001001010011010011"; -- Violet
constant LED7_COLOR : unsigned(23 downto 0) := "000000001111111111111111"; -- Magenta

signal bit_counter : unsigned(13 downto 0) := (others => '0');
signal color_counter : unsigned(4 downto 0) := (others => '0');
signal current_color : unsigned(23 downto 0) := (others => '0');

signal reg_out : std_logic := '0';

begin
	
	dout <= reg_out;
	--bit_counter_out <= bit_counter;
	--color_counter_out <= color_counter;
	--current_color_out <= current_color;
	
	ledout : process(clk)
	begin
	
		if (rising_edge(clk)) then
			if (reset = '1') then
				bit_counter <= (others => '0');
				color_counter <= (others => '0');
				block_cycle <= rest;
				bit_cycle <= rest_low;
				--bit_out <= "00001";
				current_color <= (others => '0');
				block_out <= "10101010";
			else
				if (bit_counter = "00000000000000") then
					-- we have finished whatever part we are currently working on.
					if (bit_cycle = zero_high) then
						-- send second half of 0 bit
						bit_cycle <= zero_low;
						bit_counter <= ZERO_LOW_COUNT;
						--bit_out <= "10000";
					elsif (bit_cycle = one_high) then
						-- send second half of 1 bit
						bit_cycle <= one_low;
						bit_counter <= ONE_LOW_COUNT;
						--bit_out <= "00100";
					else
					   -- bit_cycle is either zero_low, one_low or rest_low, which means
						-- we need to step to the next part.
						if (color_counter = "00000") then
							color_counter <= "10111"; --23
							case block_cycle is
								when rest =>
									block_cycle <= led0;
									current_color <= LED0_COLOR;
									block_out <= "10000000";
									bit_cycle <= zero_high;
									bit_counter <= ZERO_HIGH_COUNT;
									--bit_out <= "01000";
								when led0 =>
									block_cycle <= led1;
									current_color <= LED1_COLOR;
									block_out <= "01000000";
									
									bit_cycle <= one_high;
									bit_counter <= ONE_HIGH_COUNT;
									--bit_out <= "00010";
								when led1 =>
									block_cycle <= led2;
									current_color <= LED2_COLOR;
									block_out <= "00100000";
									
									bit_cycle <= one_high;
									bit_counter <= ONE_HIGH_COUNT;
									--bit_out <= "00010";
								when led2 =>
									block_cycle <= led3;
									current_color <= LED3_COLOR;
									block_out <= "00010000";
									
									bit_cycle <= one_high;
									bit_counter <= ONE_HIGH_COUNT;
									--bit_out <= "00010";
								when led3 =>
									block_cycle <= led4;
									current_color <= LED4_COLOR;
									block_out <= "00001000";
									bit_cycle <= zero_high;
									bit_counter <= ZERO_HIGH_COUNT;
									--bit_out <= "01000";
								when led4 =>
									block_cycle <= led5;
									current_color <= LED5_COLOR;
									block_out <= "00000100";
									bit_cycle <= zero_high;
									bit_counter <= ZERO_HIGH_COUNT;
									--bit_out <= "01000";
								when led5 =>
									block_cycle <= led6;
									current_color <= LED6_COLOR;
									block_out <= "00000010";
									bit_cycle <= zero_high;
									bit_counter <= ZERO_HIGH_COUNT;
									--bit_out <= "01000";
								when led6 =>
									block_cycle <= led7;
									current_color <= LED7_COLOR;
									block_out <= "00000001";
									bit_cycle <= zero_high;
									bit_counter <= ZERO_HIGH_COUNT;
									--bit_out <= "01000";
								when led7 =>
									block_cycle <= rest;
									current_color <= (others => '0');
									block_out <= "10101010";
									bit_cycle <= rest_low;
									bit_counter <= REST_COUNT;
									--bit_out <= "00001";
							end case;
							
							
						else
						   -- sequence on to next color
							color_counter <= color_counter - 1;
							current_color(22 downto 0) <= current_color(23 downto 1);
						end if;
					end if;
				else
					bit_counter <= bit_counter - 1;
					
				end if;
			
			
			end if;
			
			-- Now that we know what to output, set output.
			if ((bit_cycle = zero_high) or (bit_cycle = one_high)) then
				reg_out <= '1';
			else
				-- zero_low, one_low or rest
				reg_out <= '0';
			end if;
		end if;
	end process ledout;	
	
		

end behavior;