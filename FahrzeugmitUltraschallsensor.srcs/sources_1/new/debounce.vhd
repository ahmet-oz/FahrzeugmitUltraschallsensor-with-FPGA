library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debounce is
generic (
    c_initval	: std_logic	:= '0'
);
port (
clk			: in std_logic;
signal_i	: in std_logic;
signal_o	: out std_logic
);
end debounce;

architecture Behavioral of debounce is

signal miliseconds	: std_logic := '0';

type t_state is (S0, S1, S2, S3, S4);
signal state : t_state := S0;
signal timer_en		: std_logic := '0';

begin

process(clk)
variable count0: integer range 0 to 100500;
begin
    if rising_edge(clk) then
        if  timer_en = '1'   then
            if count0 = 100000 then
                count0 := 0;
            else
                count0 := count0 + 1;
            end if;
            if count0 = 0 then
                miliseconds <= '1';
            end if;
        else
            miliseconds	<= '0';
        end if;
    end if;
end process;

process (clk) begin
if (rising_edge(clk)) then

	case state is
	
		when S0 =>
		
			if (c_initval = '0') then
				state	<= S1;
			else
				state	<= S3;
			end if;
		
		when S1 =>
		
			signal_o	<= '0';
		
			if (signal_i = '1') then
				state	<= S2;
			end if;
		
		when S2 =>
		
			signal_o	<= '0';
			timer_en	<= '1';
			
			if (miliseconds = '1') then
				state		<= S3;
				timer_en	<= '0';
			end if;
			
			if (signal_i = '0') then
				state		<= S1;
				timer_en	<= '0';
			end if;
		
		when S3 =>
		
			signal_o	<= '1';
		
			if (signal_i = '0') then
				state	<= S4;
			end if;		
		
		when S4 =>
		
			signal_o	<= '1';
			timer_en	<= '1';
			
			if (miliseconds = '1') then
				state		<= S1;
				timer_en	<= '0';
			end if;
			
			if (signal_i = '1') then
				state		<= S3;
				timer_en	<= '0';
			end if;		
	
	end case;

end if;
end process;


end Behavioral;