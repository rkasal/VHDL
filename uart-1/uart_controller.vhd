-------------------------------------------------
------------- RAMAZAN KASAL ---------------------
-------------------------------------------------
--bu IP Uart haberleşmesi için tasarlanmıştır.
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;
ENTITY uart_controller IS
port(
	clk       	: in  std_logic;
	rstn 	  	: in  std_logic;	
	uart_done	: in  std_logic;
	button1     : in  std_logic;
	rx_ready    : in  std_logic;
	uart_start  : out std_logic;
	uart_data   : out std_logic_vector(7 downto 0)
);
END ENTITY uart_controller;
ARCHITECTURE arch OF uart_controller IS	
	TYPE state_type1 IS (INITIAL, WAIT_BUTON, FIRST, IDLE, TRIGGER);
	TYPE state_type2 IS (K, A, S, A_2, L);
	SIGNAL state1 : state_type1;
	SIGNAL state2 : state_type2;
	SIGNAL uart_done_d1 : std_logic;	
--state1 butonla kontrol için tasarlanmıştır.
--state2 istediğimiz veriyi sırayla yollamak için tasarlanmıştır
--burada "KASAL" datasını yolladık 
BEGIN	
	K1:process(clk,rstn)	
	begin	
		if rstn = '0'then--başlangıç sıfırlamaları	
			uart_start 			<= '0';
		    uart_data   		<= (others => '0');
			state1				<= INITIAL;	
			state2				<= K;
		
		elsif Rising_edge(clk) then
			uart_done_d1 <= uart_done;
			case state1 is	
				when INITIAL => 
					uart_start 							<= '0';
					uart_data   						<= (others => '0');
					state1               				<= WAIT_BUTON;
					state2								<= K;
				
				when WAIT_BUTON => --bu state de button'a basınca ilk datayı atıyoruz
					if(button1 = '0') then
						state1							<= IDLE;
						uart_data 						<= x"4B";
						state2							<= A;
						uart_start 						<= '1';
					end if;						
					
				when IDLE =>				
					uart_start 							<= '0';	
					if(uart_done = '1')	then--transfer tamamlandı biti bekliyor		
						case state2 is
							when K =>--istediğimiz data'yı ASCII olarak yolluyoruz					
								uart_data 					<= x"4B";
								state2						<= A;
								uart_start 					<= '1';
								if(button1 = '1') then 
									state1 					<= WAIT_BUTON;
									uart_start 				<= '0';
								end if;
							
							when A => 
								uart_data 			 		<= x"41";
								state2						<= S;
								uart_start 					<= '1';
							
							when S => 						
								uart_data 					<= x"53";
								state2						<= A_2;
								uart_start 					<= '1';
							
							when A_2 => 						
								uart_data 					<= x"41";
								state2						<= L;
								uart_start 					<= '1';
							
							when L => 					
								uart_data 					<= x"4C";
								state2						<= K;
								uart_start 					<= '1';
								
						end case;
					end if;
					
				when others => 	
					state1                     			<= INITIAL;
			end case;
		end if;
	end process K1;
END ARCHITECTURE arch;