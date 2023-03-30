LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;

ENTITY password IS
port(
	clk     :  in std_logic;
    rst     :  in std_logic;
    button0 :  in std_logic;--şifre girme ve açma butonu   
	switch0 :  in std_logic;--şifre girilen anahhtarlar
	switch1 :  in std_logic;--şifre girilen anahhtarlar
	switch2 :  in std_logic;--şifre girilen anahhtarlar
	switch3 :  in std_logic;--şifre girilen anahhtarlar	
	led0   	:  out std_logic;--sağdaki kilit gibi kullanılan ledler
	led1   	:  out std_logic;--sağdaki kilit gibi kullanılan ledler
	led2   	:  out std_logic;--sağdaki kilit gibi kullanılan ledler
	led3   	:  out std_logic;--sağdaki kilit gibi kullanılan ledler
	led4   	:  out std_logic;--soldaki kilit gibi kullanılan ledler
	led5   	:  out std_logic;--soldaki kilit gibi kullanılan ledler
	led6   	:  out std_logic;--soldaki kilit gibi kullanılan ledler
	led7   	:  out std_logic --soldaki kilit gibi kullanılan ledler
);
END ENTITY password;

ARCHITECTURE arch OF password IS
	TYPE state_type IS (INITIAL, IDLE, STATE1, STATE2, STATE3, STATE4);	
	TYPE state_type1 IS (IDLE, STATE1, STATE2);
	SIGNAL state_top 	: state_type;
	SIGNAL toggle       : state_type1;--yanlış girilmesi durumunda 3 kere led yapma durumu
	SIGNAL password1	: std_logic_vector(3 downto 0);--parola değişkenimiz
	SIGNAL password2	: std_logic_vector(3 downto 0);--parola değişkenimiz
	SIGNAL button_0 	: std_logic;
	SIGNAL button_0_D1  : std_logic;	
	SIGNAL counter_led  : std_logic_vector(2 downto 0);--yanlış girildiğinde 3 kere toggle yapması için counter
	SIGNAL counter_wait : std_logic_vector(23 downto 0);--yanlış girildiğinde ledlerin yanıp sönmesi için beklenilen süre
	constant wait_time  : std_logic_vector(23 downto 0) := x"BEBC20" ;--[0.25sn] beklemek için oluşturulan sabit
BEGIN
	process(clk,rst)
	begin
		if rst = '0' then
			led0            	<= '0';
			led1            	<= '0';
			led2            	<= '0';
			led3            	<= '0';
			led4            	<= '0';
			led5            	<= '0';
			led6            	<= '0';
			led7            	<= '0';
			state_top       	<= INITIAL;
			toggle              <= IDLE;
			counter_led			<= (others => '0');
						
		elsif Rising_edge(clk) then
			button_0 			<= button0 ;
			button_0_D1			<= button_0;
			case state_top is
				when INITIAL =>	--baslangıç sıfırlamaları
					led0            							<= '0';
					led1            							<= '0';
					led2            							<= '0';
					led3            							<= '0';
					led4            							<= '0';
					led5            							<= '0';
					led6            							<= '0';
					led7            							<= '0';
					state_top       							<= IDLE;
					toggle              						<= IDLE;
					counter_led									<= (others => '0');
				
				when IDLE => --şifre girilmesi için beklenen kısım
					if(button_0_D1 = '1' and button_0 = '0') then
						password1(0)							<= switch0;
						password1(1)							<= switch1;
						password1(2)							<= switch2;
						password1(3)							<= switch3;
						state_top       						<= STATE1;
						led0									<= '1';
						led1                                	<= '1';
						led2                                	<= '1';
						led3                                	<= '1';
					else	
						led0            						<= '0';
						led1            						<= '0';
						led2            						<= '0';
						led3            						<= '0';
						led4            						<= '0';
						led5            						<= '0';
						led6            						<= '0';
						led7            						<= '0';
					end if;
					
				when STATE1	=> --ilk şifrenin girilidiği 2. şifre için beklenilen durum
					if(button_0_D1 = '1' and button_0 = '0') then 
						password2(0)							<= switch0;
					    password2(1)							<= switch1;
					    password2(2)							<= switch2;
					    password2(3)							<= switch3;
						state_top       						<= STATE2;
						led4									<= '1';
						led5                                	<= '1';
						led6                                	<= '1';
						led7                                	<= '1';	
					else 	
						led4									<= '0';
						led5                                	<= '0';
						led6                                	<= '0';
						led7                                	<= '0';
						led0									<= '1';
						led1                                	<= '1';
						led2                                	<= '1';
						led3                                	<= '1';
						
					end if;
					
				when STATE2	=> --şifrelerin girilip ledlerin aktif olduğu kısım, yanlış şifre girilirse 3 kere led yakar
					if(button_0_D1 = '1' and button_0 = '0') then 
						if(password1(0) = switch0 and password1(1) = switch1 and password1(2) = switch2 and password1(3) = switch3) then
							state_top							<= STATE3;
							toggle								<= IDLE;
							led0            					<= '0';
							led1            					<= '0';
							led2            					<= '0';
							led3            					<= '0';
						else 	
							toggle                              <= STATE1;	
						end if;						
					else	
						case toggle is	
							when IDLE =>	
								led0            				<= '1';
								led1            				<= '1';
								led2            				<= '1';
								led3            				<= '1';
								led4            				<= '1';
								led5            				<= '1';
								led6            				<= '1';
								led7            				<= '1';	
								
							when STATE1	=>--yanlış girilince ledlerin 3 kere yanıp söndüğü durumun söndüğü kısım
								led0            				<= '0';	
								led1            				<= '0';
								led2            				<= '0';
							    led3            				<= '0';								
								counter_wait					<= counter_wait + '1';
								if(counter_wait = wait_time and counter_led < 3 ) then	
									toggle             			<= STATE2;									
									counter_wait				<= (others => '0');
								elsif(counter_led > 2 ) then
									toggle          			<= IDLE;
									counter_led					<=	(others => '0');	
								end if;	
								
							when  STATE2 =>--yanlış girilince ledlerin 3 kere yanıp yandığı durumun söndüğü kısım
								led0            				<= '1';	
								led1            				<= '1';
								led2            				<= '1';
							    led3            				<= '1';
								counter_wait					<= counter_wait + '1';
								if(counter_wait = wait_time) then	
									toggle             			<= STATE1;
									counter_wait				<= (others => '0');
									counter_led					<= counter_led + '1';
								end if;								
						end case;
					end if;
					
				when STATE3 =>--ilk şifrenin çözülüp ikinci şifrenin girilmesinin beklendiği durum
					if(button_0_D1 = '1' and button_0 = '0') then 
						if(password2(0) = switch0 and password2(1) = switch1 and password2(2) = switch2 and password2(3) = switch3) then
							state_top							<= IDLE;
							toggle								<= IDLE;
							led4            					<= '0';
							led5            					<= '0';
							led6            					<= '0';
							led7            					<= '0';
						else 	
							toggle                              <= STATE1;	
						end if;	
										
					else
						case toggle is	
							when IDLE =>			
								led0            				<= '0';
								led1            				<= '0';
								led2            				<= '0';
								led3            				<= '0';
								led4            				<= '1';
								led5            				<= '1';
								led6            				<= '1';
								led7            				<= '1';
							
							when STATE1	=> --yanlış girilince ledlerin 3 kere yanıp söndüğü durumun söndüğü kısım
								led4            				<= '0';	
								led5            				<= '0';
								led6            				<= '0';
								led7            				<= '0';
								counter_wait					<= counter_wait + '1';								
								if(counter_wait = wait_time and counter_led < 3 ) then	
									toggle             			<= STATE2;									
									counter_wait				<= (others => '0');
								elsif(counter_led > 2 ) then
									toggle          			<= IDLE;	
									counter_led					<=	(others => '0');		
								end if;	
								
							when  STATE2 =>	--yanlış girilince ledlerin 3 kere yanıp yandığı durumun söndüğü kısım
								led4            				<= '1';	
								led5            				<= '1';
								led6            				<= '1';
								led7            				<= '1';
								counter_wait					<= counter_wait + '1';
								if(counter_wait = wait_time) then	
									toggle             			<= STATE1;
									counter_wait				<= (others => '0');
									counter_led					<= counter_led + '1';
								end if;								
						end case;					
					end if;				
				when others => 
					state_top                                   <= INITIAL;
			end case;
		end if;
	end process;
END ARCHITECTURE arch;
	
