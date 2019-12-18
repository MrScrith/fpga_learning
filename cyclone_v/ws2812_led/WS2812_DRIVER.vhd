library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;



type pixel_val_t is record
	red   : std_logic_vector(7 downto 0);
	blue  : std_logic_vector(7 downto 0);
	green : std_logic_vector(7 downto 0);
end record pixel_val_t;

entity LED_SHOW is
generic (
	LED_COUNT : integer := 8
);
port (
	leds : in pixel_val_t(LED_COUNT downto 0);
	clk : in std_logic;
	reset : in std_logic;
	dout : out std_logic);
end entity;
	
architecture behavior of LED_SHOW is
	
	type bit_cycle_t is (zero_high, zero_low, one_high, one_low, rest_low);

	signal bit_cycle : bit_cycle_t := rest_low;

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

	signal bit_counter : integer := 0;
	signal color_counter : integer := 0;
	signal pixel_counter : integer := 0;

	signal current_color : unsigned(23 downto 0) := (others => '0');
	
begin
	ledout : process(clk)
	begin
	
		if (rising_edge(clk) and bit_counter != bit_counter'high) then
			if (reset = '0') then
				bit_counter <= 0;
				color_counter <= 0;
				pixel_counter <= 0;
				bit_cycle <= rest_low;
				current_color <= (others => '0');
			else
				if ((bit_counter = 0) and not (bit_cycle = rest_low)) then
					-- we have finished whatever part we are currently working on.
					if (bit_cycle = zero_high) then
						-- send second half of 0 bit
						bit_cycle <= zero_low;
						bit_counter <= ZERO_LOW_COUNT;
					elsif (bit_cycle = one_high) then
						-- send second half of 1 bit
						bit_cycle <= one_low;
						bit_counter <= ONE_LOW_COUNT;
					else
						-- bit_cycle is either zero_low, one_low or rest_low, which means
						-- we need to step to the next part.
						if (color_counter = 0) then
							color_counter <= 23;
							
							pixel_counter <= pixel_counter + 1;
							
							if ( leds(pixel_counter) = leds'high ) then
								-- We have reached the end of the array
								-- enter rest mode.
								bit_cycle <= rest_low;
								current_color <= (others => '0');
								bit_counter <= REST_COUNT;
							else
								
								current_color <= leds(pixel_counter);
							
								if ( current_color(0) = '0') then
									bit_cycle <= zero_high;
									bit_counter <= ZERO_HIGH_COUNT;
								else
									bit_cycle <= one_high;
									bit_counter <= ONE_HIGH_COUNT;
								end if;
							end if;
						else
							-- sequence on to next color
							color_counter <= color_counter - 1;
							current_color(22 downto 0) <= current_color(23 downto 1);

							if ( current_color(0) = '0') then
								bit_cycle <= zero_high;
								bit_counter <= ZERO_HIGH_COUNT;
							else
								bit_cycle <= one_high;
								bit_counter <= ONE_HIGH_COUNT;
							end if;
						end if;
					end if;
				else
					bit_counter <= bit_counter - 1;
				end if;
			end if;
			-- Now that we know what to output, set output.
			if ((bit_cycle = zero_high) or (bit_cycle = one_high)) then
				dout <= '1';
			else
				-- zero_low, one_low or rest
				dout <= '0';
			end if;
		end if;
	end process ledout;	
end behavior;