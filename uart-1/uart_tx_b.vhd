-------------------------------------------------
------------- RAMAZAN KASAL ---------------------
-------------------------------------------------
--bu IP uart controller bloğunun transmitter bloğu için tasarlanmıştır
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;
ENTITY uart_tx_b IS
port (
	clk      	: in  std_logic;
	rstn 	 	: in  std_logic;
	uart_start  : in  std_logic;		
	uart_data 	: in  std_logic_vector(7 downto 0);
	uart_done	: out std_logic;
	uart_tx 	: out std_logic
);
END ENTITY uart_tx_b;
ARCHITECTURE arch OF uart_tx_b IS	
	TYPE state_type IS (INITIAL, IDLE, START, SEND, STOP);
	SIGNAL state	  	:  state_type;
	SIGNAL counter    	:  std_logic_vector(13 downto 0);
	SIGNAL counter_data	:  std_logic_vector(2 downto 0);
--data yı bit bit yollayamak için tanımlanan sayıcı
	CONSTANT baudrate 	:  std_logic_vector(15 downto 0) := x"1458";
--baudrate sayısı 9600 sn/baudrate için beklememiz gereken pals miktarıdır
BEGIN
	K1:process(clk,rstn)
	begin
		if rstn = '0' then--başlangıç sıfırlamaları
			uart_done				<= '0';
			uart_tx 				<= '1';
			counter_data			<= (others => '0');
			counter					<= (others => '0');
			state                   <= INITIAL;
			
		elsif Rising_edge(clk) then
--buradaki state machine aldığı başlama palsiyle data yı [start(1 bit)-data(8 bit)-stop(1bit)]
--olarak yolluyoruz	
			case state IS
				when INITIAL =>--başlangıç sıfırlama state'i
					uart_done								<= '0';
					uart_tx 								<= '1';	
					counter_data							<= (others => '0');
					counter									<= (others => '0');
					state                   				<= IDLE;
					
				when IDLE =>--uart controllerden gelen uart_start palsiyle datamızı gönderiyoruz
					uart_tx 								<= '1';	
					uart_done								<= '0';	
					if( uart_start = '1' ) then
						state 								<=  ;
					else
						
					end if;
				
				when START =>				
					counter                 				<= counter + '1';
					uart_tx									<= '0';
					uart_done								<= '0';
					if( counter = baudrate - '1' ) then
						state 								<= SEND;
						counter             				<= (others => '0');	
					end if;
					
				when SEND =>
					counter                 				<= counter + '1';
					uart_tx									<= uart_data(TO_INTEGER(UNSIGNED(counter_data)));
					uart_done								<= '0';
					if( counter = baudrate - '1' ) then
						counter            		 			<= (others => '0');
						counter_data						<= counter_data + '1';			
						if( counter_data = x"7" ) then    
							state           				<= STOP;
							counter_data					<= (others => '0');
						end if; 
					end if;
					
				when STOP =>
					counter                 				<= counter + '1';
					uart_tx 								<= '1';	
					if( counter = baudrate - '1' ) then
						counter             				<= (others => '0');	
						state 								<= IDLE;	
						uart_done							<= '1';	
					end if;
					
				when others => 
					state  									<= INITIAL;
			end case;
		end if;
	end process K1;
END ARCHITECTURE arch;