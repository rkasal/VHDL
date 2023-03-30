LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;

ENTITY kara_simsek IS
port( 
    clk     :  in std_logic;
    rstn    :  in std_logic;
    led0   	:  out std_logic;
	led1   	:  out std_logic;
	led2   	:  out std_logic;
	led3   	:  out std_logic;
	led4   	:  out std_logic;
	led5   	:  out std_logic;
	led6   	:  out std_logic;
	led7   	:  out std_logic
);
END ENTITY kara_simsek;
ARCHITECTURE arch OF kara_simsek IS	
	TYPE state_type is (INITIAL, STATE1, STATE2, STATE3, STATE4 ,STATE5, STATE6, STATE7, STATE8, STATE9, STATE10, STATE11, STATE12,STATE13,STATE14);
	SIGNAL STATE_TOP    : state_type;
	SIGNAL counter_led  : std_logic_vector(24 downto 0);
BEGIN
process(rstn,clk)
   begin
       if rstn = '0' then
			led0            <= '0';
			led1            <= '0';
			led2            <= '0';
			led3            <= '0';
			led4            <= '0';
			led5            <= '0';
			led6            <= '0';
			led7            <= '0';
			counter_led	    <= (others => '0');
			STATE_TOP       <= 	state1;
			
	   elsif Rising_edge(clk) then
	   	   	   	   	   
			case STATE_TOP is
				when initial =>
					led0            <= '0';
					led1            <= '0';
					led2            <= '0';
					led3            <= '0';
					led4            <= '0';
					led5            <= '0';
					led6            <= '0';
					led7            <= '0';
					counter_led	    <= (others => '0');
					STATE_TOP       <= 	state1;
												
				when state1 =>
					counter_led					 <= counter_led + '1';					
					led0                         <= '1';
					led1                         <= '0';
					led2                         <= '0';
					led3                         <= '0';
					led4                         <= '0';
					led5                         <= '0';
					led6                         <= '0';
					led7                         <= '0';
					if(counter_led = x"17D7840") then
						STATE_TOP                <= STATE2;
						counter_led              <= (others => '0');
					end if;
						
				when state2 =>
					counter_led					 <= counter_led + '1';
					led0                         <= '0';
					led1                         <= '1';
					led2                         <= '0';
					led3                         <= '0';
					led4                         <= '0';
					led5                         <= '0';
					led6                         <= '0';
					led7                         <= '0';
				
					if(counter_led = x"17D7840") then
						STATE_TOP                <= STATE3;
						counter_led              <= (others => '0');
					end if;
				
				when state3 =>
					counter_led					 <= counter_led + '1';
					led0                         <= '0';
					led1                         <= '0';
					led2                         <= '1';
					led3                         <= '0';
					led4                         <= '0';
					led5                         <= '0';
					led6                         <= '0';
					led7                         <= '0';
				
					if(counter_led = x"17D7840") then
						STATE_TOP                <= STATE4;
						counter_led              <= (others => '0');
					end if;
				
					when state4 =>
					counter_led					 <= counter_led + '1';
					led0                         <= '0';
					led1                         <= '0';
					led2                         <= '0';
					led3                         <= '1';
					led4                         <= '0';
					led5                         <= '0';
					led6                         <= '0';
					led7                         <= '0';
				
					if(counter_led = x"17D7840") then
						STATE_TOP                <= STATE5;
						counter_led              <= (others => '0');
					end if;
				
				when state5 =>
					counter_led					 <= counter_led + '1';
					led0                         <= '0';
					led1                         <= '0';
					led2                         <= '0';
					led3                         <= '0';
					led4                         <= '1';
					led5                         <= '0';
					led6                         <= '0';
					led7                         <= '0';
		
					if(counter_led = x"17D7840") then
						STATE_TOP                <= STATE6;
						counter_led              <= (others => '0');
					end if;
				when state6 =>
					counter_led					 <= counter_led + '1';
					led0                         <= '0';
					led1                         <= '0';
					led2                         <= '0';
					led3                         <= '0';
					led4                         <= '0';
					led5                         <= '1';
					led6                         <= '0';
					led7                         <= '0';
		
					if(counter_led = x"17D7840") then
						STATE_TOP                <= STATE7;
						counter_led              <= (others => '0');
					end if;
				
				when state7 =>
					counter_led					 <= counter_led + '1';
					led0                         <= '0';
					led1                         <= '0';
					led2                         <= '0';
					led3                         <= '0';
					led4                         <= '0';
					led5                         <= '0';
					led6                         <= '1';
					led7                         <= '0';
		
					if(counter_led = x"17D7840") then
						STATE_TOP                <= STATE8;
						counter_led              <= (others => '0');
					end if;
				
				when state8 =>
					counter_led					 <= counter_led + '1';
					led0                         <= '0';
					led1                         <= '0';
					led2                         <= '0';
					led3                         <= '0';
					led4                         <= '0';
					led5                         <= '0';
					led6                         <= '0';
					led7                         <= '1';
					
					if(counter_led = x"17D7840") then
						STATE_TOP                <= STATE9;
						counter_led              <= (others => '0');
					end if;
				
				when state9 =>
					counter_led					 <= counter_led + '1';
					led0                         <= '0';
					led1                         <= '0';
					led2                         <= '0';
					led3                         <= '0';
					led4                         <= '0';
					led5                         <= '0';
					led6                         <= '1';
					led7                         <= '0';
					
					if(counter_led = x"17D7840") then
						STATE_TOP                <= STATE10;
						counter_led              <= (others => '0');
					end if;
				
				when state10 =>
					counter_led					 <= counter_led + '1';
					led0                         <= '0';
					led1                         <= '0';
					led2                         <= '0';
					led3                         <= '0';
					led4                         <= '0';
					led5                         <= '1';
					led6                         <= '0';
					led7                         <= '0';
					
					if(counter_led = x"17D7840") then
						STATE_TOP                <= STATE11;
						counter_led              <= (others => '0');
					end if;
					
				when state11 =>
					counter_led					 <= counter_led + '1';
					led0                         <= '0';
					led1                         <= '0';
					led2                         <= '0';
					led3                         <= '0';
					led4                         <= '1';
					led5                         <= '0';
					led6                         <= '0';
					led7                         <= '0';
					
					if(counter_led = x"17D7840") then
						STATE_TOP                <= STATE12;
						counter_led              <= (others => '0');
					end if;
					
				when state12 =>
					counter_led					 <= counter_led + '1';
					led0                         <= '0';
					led1                         <= '0';
					led2                         <= '0';
					led3                         <= '1';
					led4                         <= '0';
					led5                         <= '0';
					led6                         <= '0';
					led7                         <= '0';
					
					if(counter_led = x"17D7840") then
						STATE_TOP                <= STATE13;
						counter_led              <= (others => '0');
					end if;
					
				when state13 =>
					counter_led					 <= counter_led + '1';
					led0                         <= '0';
					led1                         <= '0';
					led2                         <= '1';
					led3                         <= '0';
					led4                         <= '0';
					led5                         <= '0';
					led6                         <= '0';
					led7                         <= '0';
					
					if(counter_led = x"17D7840") then
						STATE_TOP                <= STATE14;
						counter_led              <= (others => '0');
					end if;
					
				when state14 =>
					counter_led					 <= counter_led + '1';
					led0                         <= '0';
					led1                         <= '1';
					led2                         <= '0';
					led3                         <= '0';
					led4                         <= '0';
					led5                         <= '0';
					led6                         <= '0';
					led7                         <= '0';
					
					if(counter_led = x"17D7840") then
						STATE_TOP                <= STATE1;
						counter_led              <= (others => '0');
					end if;
									
				when others => 
					STATE_TOP          <= STATE1;
							
			end case;
		end if;
end process ;
end architecture arch ;