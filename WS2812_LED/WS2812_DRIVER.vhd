library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;



ENTITY WS2812_DRIVER IS
	
	
	GENERIC 
	(
		G_LED_COUNT : INTEGER := 8;
		-- 220ns to 380ns
		G_ZERO_HIGH_COUNT : INTEGER := 11;
	
		-- 580ns to 1us - 34 to 50 clock cycles
		G_ZERO_LOW_COUNT : INTEGER := 34;
	
		-- 580ns to 1us - 34 to 50 clock cycles
		G_ONE_HIGH_COUNT : INTEGER := 34;
	
		-- 220ns to 420ns - 11 to 21 clock cycles
		G_ONE_LOW_COUNT : INTEGER := 11;
	
		-- >280us - >14000 clock cycles
		G_REST_COUNT : INTEGER := 14000
	);
	PORT 
	(
		i_led_set_rgb : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
		i_led_set_index : IN INTEGER;
		i_clk : IN STD_LOGIC;
		i_reset : IN STD_LOGIC;
		o_data_out : OUT STD_LOGIC
	);
END WS2812_DRIVER;
	
ARCHITECTURE rtl OF WS2812_DRIVER IS

	CONSTANT REST_INDEX : INTEGER := G_LED_COUNT;

	
	TYPE t_bit_cycle IS (zero_high, zero_low, one_high, one_low, rest_low);
	
	SIGNAL r_bit_cycle : t_bit_cycle := zero_low;
	
	SIGNAL r_led_set_rgb1 : STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL r_led_set_rgb2 : STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL r_led_set_index1 : INTEGER;
	SIGNAL r_led_set_index2 : INTEGER;
	
	
	-- led memory data
	TYPE t_led_data IS ARRAY(INTEGER RANGE<>) OF STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL led_data : t_led_data(G_LED_COUNT-1 DOWNTO 0) := (OTHERS => X"000000");
	
	
	SIGNAL r_bit_counter : INTEGER := G_REST_COUNT;
	SIGNAL r_color_counter : INTEGER := 0;
	SIGNAL r_current_color : STD_LOGIC_VECTOR(23 DOWNTO 0) := (OTHERS => '0');

	BEGIN
	
	led_data_writing: PROCESS (i_clk, i_reset, i_led_set_index)
	BEGIN
		IF ( i_reset = '1' ) THEN
			-- Reset s
			r_led_set_rgb1   <= x"000000";
			r_led_set_rgb2   <= x"000001";
			r_led_set_index1 <= 0;
			r_led_set_index2 <= 1;
			for i in 0 to (G_LED_COUNT - 1) loop
				led_data(i) <= (OTHERS => '0');
			end loop;
		ELSIF ( RISING_EDGE ( i_clk ) ) THEN
			-- Debounce signals
			r_led_set_rgb1 <= i_led_set_rgb;
			r_led_set_rgb2 <= r_led_set_rgb1;
			r_led_set_index1 <= i_led_set_index;
			r_led_set_index2 <= r_led_set_index1;
			
			
			IF ( ( r_led_set_index2 < G_LED_COUNT ) AND
			   ( r_led_set_index1 = r_led_set_index2 ) AND 
			   (r_led_set_rgb1 = r_led_set_rgb2 ) ) THEN
			
				led_data(r_led_set_index2) <= r_led_set_rgb2;
			ELSE
				led_data <= led_data;
			END IF;
				
		END IF;
	
	
	END PROCESS;


	
	leo_data_out : process(i_clk, i_reset)
	
		VARIABLE v_block_index : INTEGER := REST_INDEX;
		
	begin
	
		if (i_reset = '1') then 
				r_bit_counter <= 0;
				r_color_counter <= 0;
				v_block_index := REST_INDEX;
				r_bit_cycle <= zero_low;
				r_current_color <= (others => '0');
		elsif (rising_edge(i_clk)) then
			
			
			if (r_bit_counter = 0) then
				-- we have finished whatever part we are currently working on.
				if (r_bit_cycle = zero_high) then
					-- send second half of 0 bit
					r_bit_cycle <= zero_low;
					r_bit_counter <= G_ZERO_LOW_COUNT;
				elsif (r_bit_cycle = one_high) then
					-- send second half of 1 bit
					r_bit_cycle <= one_low;
					r_bit_counter <= G_ONE_LOW_COUNT;
				else
				   -- r_bit_cycle is either zero_low, one_low or rest_low, which means
					-- we need to step to the next part.
					if (r_color_counter = 0) then
						r_color_counter <= 23;
						
						if (v_block_index < REST_INDEX ) THEN
							v_block_index := v_block_index + 1;
							if (v_block_index = REST_INDEX ) THEN
								r_current_color <= (others => '0');
							else
								r_current_color <= led_data(v_block_index);
							end if;
						elsif (v_block_index = REST_INDEX ) THEN
							v_block_index := 0;
							r_current_color <= led_data(v_block_index);
						end if;
						
						
						if ( v_block_index = REST_INDEX ) then
							r_bit_cycle <= rest_low;
							r_bit_counter <= G_REST_COUNT;
						elsif ( r_current_color(0) = '0') then
							r_bit_cycle <= zero_high;
							r_bit_counter <= G_ZERO_HIGH_COUNT;
						else
							r_bit_cycle <= one_high;
							r_bit_counter <= G_ONE_HIGH_COUNT;
						end if;
					else
					   -- sequence on to next color
						r_color_counter <= r_color_counter - 1;
						r_current_color(22 downto 0) <= r_current_color(23 downto 1);
						
						if ( r_current_color(0) = '0') then
							r_bit_cycle <= zero_high;
							r_bit_counter <= G_ZERO_HIGH_COUNT;
						else
							r_bit_cycle <= one_high;
							r_bit_counter <= G_ONE_HIGH_COUNT;
						end if;
					end if;
				end if;
			else
				r_bit_counter <= r_bit_counter - 1;
			end if;
		end if;
		-- Now that we know what to output, set output.
		if ((r_bit_cycle = zero_high) or (r_bit_cycle = one_high)) then
			o_data_out <= '1';
		else
			-- zero_low, one_low or rest
			o_data_out <= '0';
		end if;
			
	end process leo_data_out;	
	
	
	
END rtl;



