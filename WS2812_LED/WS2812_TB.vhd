library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

ENTITY WS2812_TB IS

END WS2812_TB;

ARCHITECTURE ARCH_TB OF WS2812_TB IS

	SIGNAL s_clk_50Mhz : STD_LOGIC := '0';
	SIGNAL s_sys_reset : STD_LOGIC := '0';
	SIGNAL s_led_set_rgb : STD_LOGIC_VECTOR(23 DOWNTO 0) := x"000000";
	SIGNAL s_led_set_index : INTEGER := 99;
	SIGNAL s_data_out : STD_LOGIC := '0';
	

	COMPONENT WS2812_DRIVER IS
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
	END COMPONENT WS2812_DRIVER;

	BEGIN
-- P_TEST testbench process
	P_TEST: PROCESS
	BEGIN
	    REPORT "Reset the driver";
		s_sys_reset <= '1';
		wait for 1 us;
		s_sys_reset <= '0';
		
		wait for 1 us;
		
		s_led_set_index <= 0;
		s_led_set_rgb   <= x"FF0000";
		
		wait for 1 us;
		
		s_led_set_index <= 1;
		s_led_set_rgb   <= x"00FF00";
		
		wait for 1 us;
		
		s_led_set_index <= 2;
		s_led_set_rgb   <= x"0000FF";
		
		wait for 1 us;
		
		s_led_set_index <= 3;
		s_led_set_rgb   <= x"555555";
		
		wait for 1 us;
		
		s_led_set_index <= 4;
		s_led_set_rgb   <= x"AAAAAA";
		
		wait for 1 us;
		
		s_led_set_index <= 5;
		s_led_set_rgb   <= x"C095E3";
		
		wait for 1 us;
		
		s_led_set_index <= 6;
		s_led_set_rgb   <= x"FFF384";
		
		wait for 1 us;
		
		s_led_set_index <= 7;
		s_led_set_rgb   <= x"E3ABD5";
		
		wait for 1 us;
		
		s_led_set_index <= 9;
		s_led_set_rgb   <= x"000000";
		
		REPORT "Colors loaded, now to watch output";
		
		wait for 100 ms;
		
	END PROCESS;





-- P_50Mhz_CLK clock process
	P_50Mhz_Clk : PROCESS
	BEGIN
		s_clk_50Mhz <= '1';
		WAIT FOR 10 ns;
		s_clk_50Mhz <= '0';
		WAIT FOR 10 ns;
	
	END PROCESS;
	
	
	
	U_WS2812: WS2812_DRIVER
	GENERIC MAP (
		G_LED_COUNT => 8,
		G_ZERO_HIGH_COUNT => 11,
		G_ZERO_LOW_COUNT => 34,
		G_ONE_HIGH_COUNT => 34,
		G_ONE_LOW_COUNT => 11,
		G_REST_COUNT => 14000
	)
	PORT MAP (
		i_led_set_rgb => s_led_set_rgb,
		i_led_set_index => s_led_set_index,
		i_clk => s_clk_50Mhz,
		i_reset => s_sys_reset,
		o_data_out => s_data_out
	);

END ARCH_TB;