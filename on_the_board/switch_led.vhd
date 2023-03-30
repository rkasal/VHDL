LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;

ENTITY switch_led IS
port( 
    clk     :  in std_logic;
    rstn    :  in std_logic;
    led0   	:  out std_logic;
	led1   	:  out std_logic;
	led2   	:  out std_logic;
	led3   	:  out std_logic;
	button0 :  in std_logic;
	button1 :  in std_logic;
	button2 :  in std_logic;
	button3	:  in std_logic
);
END ENTITY switch_led;

ARCHITECTURE arch OF switch_led IS	
	TYPE state_type IS (INITIAL,STATE1, STATE2, STATE3, STATE4);
	SIGNAL 	state_top  : state_type;
	SIGNAL counter_led : std_logic_vector(20 downto 0);
BEGIN
    process(rstn,clk)
    begin
       if rstn= '0' then--baþlangýcýmýzda out rd_data mýzý sýfýrladýk
			counter_led   	<= (others=>'0');
			led0         	<= '0';
			led1			<= '0';
			led2          	<= '0';
			led2          	<= '0';
			state_top       <= INITIAL;
	   elsif Rising_edge(clk) then          			
			case state_top is
				when INITIAL =>
					counter_led   		<= (others=>'0');
					led0         		<= '0';
					led1				<= '0';
					led2          		<= '0';
					led2          		<= '0';
					state_top       	<= STATE1;
					
				when STATE1 =>
					if(button0 = '1') then
						led0         	<= '1';
					else
						led0         	<= '0';
					end if;
					
					if(button1 = '1') then
						led1         	<= '1';
					else
						led1         	<= '0';
					end if;
					
					if(button2 = '1') then
						led2         	<= '1';
					else
						led2         	<= '0';
					end if;
					
					if(button3 = '1') then
						led3         	<= '1';
					else
						led3         	<= '0';
					end if;
				
				when others =>
					state_top 			<= STATE1;
			
				end case ;																		
       end if ;
	end process ;
end architecture arch ;