library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
	generic(
	c_initval	: std_logic	:= '0'
	);
	port(
	clk: in std_logic;
	trigger: out std_logic;
	echo: in std_logic;
	motor_l_f: out std_logic;
	motor_l_r: out std_logic;
	motor_r_f: out std_logic;
	motor_r_r: out std_logic;
	LED: out std_logic_vector(7 downto 0)
	);
end top;

architecture Behavioral of top is

	component debounce is
		generic (
		c_initval	: std_logic	:= '0'
		);
		port (
		clk			: in std_logic;
		signal_i	: in std_logic;
		signal_o	: out std_logic
		);
	end component;

	signal microseconds: std_logic := '0';
	signal	motor_r_r_s: std_logic;
	signal	motor_r_f_s: std_logic;
	signal	motor_l_r_s: std_logic;
	signal	motor_l_f_s: std_logic;
	signal counter: std_logic_vector(17 downto 0);
	signal leds: std_logic_vector(7 downto 0);
	signal trigger_s: std_logic;
	signal echo_deb: std_logic;
	signal	ctrl: std_logic := '0';

	begin


	echo_debounce : debounce
	generic map(
	c_initval	=> c_initval
	)
	port map(
	clk			=> clk,
	signal_i	=> echo,
	signal_o	=> echo_deb
	);
		
	process(clk)
	variable count0: integer range 0 to 150;
	begin
		if rising_edge(clk) then
			if count0 = 50 then
				count0 := 0;
			else
				count0 := count0 + 1;
			end if;
			if count0 = 0 then
				microseconds <= not microseconds;
			end if;
		end if;
	end process;
	
	process(microseconds)
	variable count1: integer range 0 to 262143;
	begin
		if rising_edge(microseconds) then
			if count1 = 0 then


				counter <= "000000000000000000";
				trigger <= '1';

			elsif count1 = 10 then
				trigger <= '0';

			end if;

			if echo_deb = '1' then
				counter <= counter + 1;
			end if;

			if count1 = 249999 then
				
				-- counter = 23530 => 400cm 
				-- counter = 1600 => 27cm
				-- counter = 800 => 27cm  

				if counter /= 0 then
					if counter > 0 and counter <= 500  then
						leds <= "00000001";
						ctrl <= '1';
					elsif counter >500 and counter <= 1600  then
						leds <= "00000011";	
						ctrl <= '1';
					elsif counter >1600 and counter <= 2100  then
						leds <= "00000111";	
					elsif counter >2100 and counter <= 2900  then
						leds <= "00001111";	
					elsif counter >2900 and counter <= 3700  then
						leds <= "00011111";	
					elsif counter >3700 and counter <= 4500  then
						leds <= "00111111";	
					elsif counter >4500 and counter <= 5200  then
						leds <= "01111111";
					else
						leds <= "11111111";
					end if;
					if counter < 1600	then
					 	motor_r_f_s <= '1';
					 	motor_r_r_s <= '0';
					 	motor_l_f_s <= '0';
					 	motor_l_r_s <= '0';	
					 	ctrl <= '0';
					else
						motor_r_f_s <= '1';
					 	motor_r_r_s <= '0';
					 	motor_l_f_s <= '1';
					 	motor_l_r_s <= '0';
					end if;
				end if;

				count1 := 0;
			else
				count1 := count1 + 1;
			end if;


		end if;

	end process;
	LED <= leds;
	trigger <= trigger_s;
	motor_r_f <= motor_r_f_s;
	motor_r_f <= motor_r_f_s;
	motor_l_f <= motor_l_f_s;
	motor_l_f <= motor_l_f_s;
	
end Behavioral;