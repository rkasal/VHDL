LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;

ENTITY button_wait IS
generic (
	wait_counter  : integer := 50000000
);
port( 
	clk     :  in std_logic;
	rstn    :  in std_logic;
	button0 :  in std_logic;
	led0   	:  out std_logic;
	led1   	:  out std_logic;
	led2   	:  out std_logic;
	led3   	:  out std_logic;
	led4   	:  out std_logic;
	led5   	:  out std_logic;
	led6   	:  out std_logic;
	led7   	:  out std_logic
	
);
END ENTITY button_wait;

ARCHITECTURE arch OF button_wait IS	
	TYPE state_type IS ( IDLE, STATE1, STATE2, STATE3, STATE4, STATE5, STATE6, STATE7, STATE8);
	SIGNAL 	state_top   : state_type;
	SIGNAL counter_next : std_logic_vector(25 downto 0);
	SIGNAL counter_back : std_logic_vector(25 downto 0);
	--constant wait_time : std_logic_vector(25 downto 0) :=x"FFFFFFFFFF";		
BEGIN
    process(rstn,clk)
    begin
       if rstn= '0' then
			led0            	<= '0';
			led1            	<= '0';
			led2            	<= '0';
			led3            	<= '0';
			led4            	<= '0';
			led5            	<= '0';
			led6            	<= '0';
			led7            	<= '0';
			counter_next    	<= (others => '0');
			counter_back    	<= (others => '0');
			state_top       	<= INITIAL;
			
	   elsif Rising_edge(clk) then          			
			case state_top is
				when INITIAL =>
					led0            							<= '0';
					led1            							<= '0';
					led2            							<= '0';
					led3            							<= '0';
					led4            							<= '0';
					led5            							<= '0';
					led6            							<= '0';
					led7            							<= '0';
					counter_next    							<= (others => '0');
					counter_back    							<= (others => '0');
					state_top       							<= IDLE;
					
				when IDLE =>
					led0            							<= '0';
					led1            							<= '0';
					led2            							<= '0';
					led3            							<= '0';
					led4            							<= '0';
					led5            							<= '0';
					led6            							<= '0';
					led7            							<= '0';					
					if(button0 = '0') then			
						counter_next    						<= counter_next + 1;
					else 
						counter_next    						<= (others => '0');
					end if;
					
					if(counter_next = wait_counter) then
						state_top       						<= STATE1;
						counter_next    						<= (others => '0');
						counter_back    						<= (others => '0');
					end if;
					
				when STATE1 =>
					led0            							<= '1';
					led1            							<= '0';
					led2            							<= '0';
					led3            							<= '0';
					led4            							<= '0';   
					led5            							<= '0';
					led6            							<= '0';
					led7            							<= '0';					
					if(button0 = '0') then			
						counter_next    						<= counter_next + 1;
						counter_back    						<= (others => '0');
					else			
						counter_back    						<= counter_back + 1;
						counter_next    						<= (others => '0');
					end if;
					
					if(counter_next = wait_counter) then
						state_top       						<= STATE2;
						counter_next    						<= (others => '0');
						counter_back    						<= (others => '0');
					elsif(counter_back = wait_counter) then
						state_top       						<= IDLE;
						counter_next    						<= (others => '0');
						counter_back    							<= (others => '0');
					end if;
						
				when STATE2 =>
					led0            							<= '1';
					led1            							<= '1';
					led2            							<= '0';
					led3            							<= '0';
					led4            							<= '0';
					led5            							<= '0';
					led6            							<= '0';
					led7            							<= '0';					
					if(button0 = '0') then			
						counter_next    						<= counter_next + 1;
						counter_back    						<= (others => '0');
					else			
						counter_back    						<= counter_back + 1;
						counter_next    						<= (others => '0');
					end if;
					
					if(counter_next = wait_counter) then
						state_top       						<= STATE3;
						counter_next    						<= (others => '0');
						counter_back    						<= (others => '0');
					elsif(counter_back = wait_counter) then
						state_top       						<= STATE1;
						counter_next    						<= (others => '0');
						counter_back    						<= (others => '0');
					end if;
						
						
				when STATE3 =>
					led0            							<= '1';
					led1            							<= '1';
					led2            							<= '1';
					led3            							<= '0';
					led4            							<= '0';
					led5            							<= '0';
					led6            							<= '0';
					led7            							<= '0';					
					if(button0 = '0') then			
						counter_next    						<= counter_next + 1;
						counter_back    						<= (others => '0');
					else			
						counter_back    						<= counter_back + 1;
						counter_next    						<= (others => '0');
					end if;
					
					if(counter_next = wait_counter) then
						state_top       						<= STATE4;
						counter_next    						<= (others => '0');
						counter_back    						<= (others => '0');
					elsif(counter_back = wait_counter) then
						state_top       						<= STATE2;
						counter_next    						<= (others => '0');
						counter_back    						<= (others => '0');
					end if;
						
						
				when STATE4 =>
					led0            							<= '1';
					led1            							<= '1';
					led2            							<= '1';
					led3            							<= '1';
					led4            							<= '0';
					led5            							<= '0';
					led6            							<= '0';
					led7            							<= '0';					
					if(button0 = '0') then			
						counter_next    						<= counter_next + 1;
						counter_back    						<= (others => '0');
					else			
						counter_back    						<= counter_back + 1;
						counter_next    						<= (others => '0');
					end if;
					
					if(counter_next = wait_counter) then
						state_top       						<= STATE5;
						counter_next    						<= (others => '0');
						counter_back    						<= (others => '0');
					elsif(counter_back = wait_counter) then
						state_top       						<= STATE3;
						counter_next    						<= (others => '0');
						counter_back    						<= (others => '0');
					end if;
						
						
				when STATE5 =>
					led0            							<= '1';
					led1            							<= '1';
					led2            							<= '1';
					led3            							<= '1';
					led4            							<= '1';
					led5            							<= '0';
					led6            							<= '0';
					led7            							<= '0';					
					if(button0 = '0') then			
						counter_next    						<= counter_next + 1;
						counter_back    						<= (others => '0');
					else			
						counter_back    						<= counter_back + 1;
						counter_next    						<= (others => '0');
					end if;
					
					if(counter_next = wait_counter) then
						state_top       						<= STATE6;
						counter_next    						<= (others => '0');
						counter_back    						<= (others => '0');
					elsif(counter_back = wait_counter) then
						state_top       						<= STATE4;
						counter_next    						<= (others => '0');
						counter_back    						<= (others => '0');
					end if;
						
				when STATE6 =>
					led0            							<= '1';
					led1            							<= '1';
					led2            							<= '1';
					led3            							<= '1';
					led4            							<= '1';
					led5            							<= '1';
					led6            							<= '0';
					led7            							<= '0';					
					if(button0 = '0') then			
						counter_next    						<= counter_next + 1;
						counter_back    						<= (others => '0');
					else			
						counter_back    						<= counter_back + 1;
						counter_next    						<= (others => '0');
					end if;
					
					if(counter_next = wait_counter) then
						state_top       						<= STATE7;
						counter_next    						<= (others => '0');
						counter_back    						<= (others => '0');
					elsif(counter_back = wait_counter) then
						state_top       						<= STATE5;
						counter_next    						<= (others => '0');
						counter_back    						<= (others => '0');
					end if;
				
				when STATE7 =>
					led0            							<= '1';
					led1            							<= '1';
					led2            							<= '1';
					led3            							<= '1';
					led4            							<= '1';
					led5            							<= '1';
					led6            							<= '1';
					led7            							<= '0';					
					if(button0 = '0') then			
						counter_next    						<= counter_next + 1;
						counter_back    						<= (others => '0');
					else			
						counter_back    						<= counter_back + 1;
						counter_next    						<= (others => '0');
					end if;
					
					if(counter_next = wait_counter) then
						state_top       						<= STATE8;
						counter_next    						<= (others => '0');
						counter_back    						<= (others => '0');
					elsif(counter_back = wait_counter) then
						state_top       						<= STATE6;
						counter_next    						<= (others => '0');
						counter_back    						<= (others => '0');
					end if;
						
						
				when STATE8 =>
					led0            							<= '1';
					led1            							<= '1';
					led2            							<= '1';
					led3            							<= '1';
					led4            							<= '1';
					led5            							<= '1';
					led6            							<= '1';
					led7            							<= '1';					
					if(button0 = '0') then			
						counter_back    						<= (others => '0');
					else			
						counter_back    						<= counter_back + 1;
					end if;
					
					if(counter_back = wait_counter) then
						state_top       						<= STATE7;
						counter_next    						<= (others => '0');
						counter_back    						<= (others => '0');
					end if;
					
				when others =>
					state_top 			<= INITIAL;
			
				end case ;																		
       end if ;
	end process ;
end architecture arch ;