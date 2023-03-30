-------------------------------------------------
------------- RAMAZAN KASAL ---------------------
-------------------------------------------------
--bu IP uart controller bloğunun receiver bloğu için tasarlanmıştır
--RS-232 protokolünde haberleşme yapılır. rs-232 active low çalışır
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;
ENTITY uart_rx_b IS
port (
	clk      	: in  std_logic;--50 MHz 
	rstn 	 	: in  std_logic;
	rx_data     : in  std_logic;--data nın alındığı pin
	rx_ready    : out std_logic;--alınan data tamamlandı çıkışı
	led0        : out std_logic;--alınan datamız ledlerde çıkış olarak veriliyor
	led1        : out std_logic;--alınan datamız ledlerde çıkış olarak veriliyor
	led2        : out std_logic;--alınan datamız ledlerde çıkış olarak veriliyor
	led3        : out std_logic;--alınan datamız ledlerde çıkış olarak veriliyor
	led4        : out std_logic;--alınan datamız ledlerde çıkış olarak veriliyor
	led5        : out std_logic;--alınan datamız ledlerde çıkış olarak veriliyor
	led6        : out std_logic;--alınan datamız ledlerde çıkış olarak veriliyor
	led7        : out std_logic --alınan datamız ledlerde çıkış olarak veriliyor
);
END ENTITY uart_rx_b;
ARCHITECTURE arch OF uart_rx_b IS	
	TYPE state_type IS (INITIAL, IDLE, START, SEND, STOP);
	SIGNAL state3 : state_type ;
	SIGNAL data_top : std_logic_vector(7 downto 0);--yollanacak data
	SIGNAL counter : std_logic_vector(13 downto 0);
	SIGNAL counter_data	:  std_logic_vector(2 downto 0);
--data yı bit bit yollayamak için tanımlanan sayıcı
	CONSTANT baudrate   :  std_logic_vector(15 downto 0) := x"1458";
	CONSTANT baudrate_2 :  std_logic_vector(11 downto 0) := x"A2C";
--baudrate sayısı 9600 sn/baudrate için beklememiz gereken pals miktarıdır
--baudrate_2 baudrate sayısının yarısıdır
BEGIN
	K1:process(clk,rstn)
	begin
		if rstn = '0' then--başlangıç sıfırlamaları
			data_top 						<= (others => '0');
			rx_ready						<= '0';
			counter_data					<= (others => '0');
			counter							<= (others => '0');
			state3							<= INITIAL;
			
		elsif Rising_edge(clk) then
--burdaki state machine gelen bilgiyi almak için IDLE de rx hattının logic-0(start) olmasını bekliyor.
			case state3 is 
				when INITIAL =>--başlangıç sıfırlamaları
					data_top 								<= (others => '0');
					rx_ready								<= '0';
					counter_data							<= (others => '0');
					counter									<= (others => '0');
					state3									<= IDLE;
					
				when IDLE =>--rx_data pininden start biti(logic-1'İ) bekleniyor						
					rx_ready                       			<= '0';	
					counter_data							<= (others => '0');
					counter									<= (others => '0');
					if( rx_data = '0' ) then--rx_data logic-1 olduğunda start a geçiliyor		
						state3 								<= START;
					else
						state3 								<= IDLE;
					end if;
					led0                                    <= data_top(0);
					led1                                    <= data_top(1);
					led2                                    <= data_top(2);
					led3                                    <= data_top(3);
					led4                                    <= data_top(4);
					led5                                    <= data_top(5);
					led6                                    <= data_top(6);
					led7                                    <= data_top(7);
					--aldığımız data ya göre ledler yanıyor
				when START =>				
					counter                 				<= counter + '1';
					rx_ready								<= '0';
					if( counter = baudrate_2 - '1' ) then
						if(rx_data = '0') then--start hala logic-1 mi?
							state3 							<= START;
						else
							state3 							<= IDLE;
						end if;
					end if;
					if( counter = baudrate - '1' ) then		
						state3 								<= SEND;
						counter             				<= (others => '0');	
					end if;			
					
				when SEND =>--data burada alınıyor			
					counter                 				<= counter + '1';
					if( counter = baudrate_2 - '1' ) then--alınan data bit bit data_top a aktarılıyor
						data_top(TO_INTEGER(UNSIGNED(counter_data))) <= rx_data;
					end if;
					
					if( counter = baudrate - '1' ) then
						counter            		 			<= (others => '0');
						counter_data						<= counter_data + '1';			
						if( counter_data = x"7" ) then  
							state3           				<= STOP;
							counter_data					<= (others => '0');
						--son bitten sonra baudrate ye ulaşılınca stop statesine geçilir 
						end if; 
					end if;
					
				when STOP =>--stop biti kontrol logic-0 mı kontrol ediliyor
					counter                 				<= counter + '1';
					if( counter = baudrate_2 - '1' ) then
						if(rx_data = '1' ) then
							state3		  					<= STOP;
							--eğer stop biti logic-0 sa stop statesinde kalınır
						else
							state3		  					<= IDLE;
							data_top						<= (others => '0');
							--eğer stop biti logic-0 değilse data_top sıfırlanı ve
							--IDLE'la dönülür
						end if;
					end if;
					
					if( counter = baudrate - '1' ) then
						counter             				<= (others => '0');	
						state3								<= IDLE;	
						rx_ready							<= '1';	
					end if;
					
				when others => 
					state3  								<= INITIAL;
			end case;
		end if;
	end process K1;
END ARCHITECTURE arch;