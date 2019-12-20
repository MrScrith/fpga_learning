library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

package WS2812_DRIVER is

	type pixel_val_t is record
		red   : std_logic_vector(7 downto 0);
		blue  : std_logic_vector(7 downto 0);
		green : std_logic_vector(7 downto 0);
	end record pixel_val_t;

	component LED_SHOW
	generic (
		LED_COUNT : integer := 8
	);
	port (
		leds : in pixel_val_t(LED_COUNT downto 0);
		clk : in std_logic;
		reset : in std_logic;
		dout : out std_logic);
	end component LED_SHOW;
end package WS2812_DRIVER;

