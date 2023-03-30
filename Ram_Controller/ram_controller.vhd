LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;--birim dönüşümü yapmak için bu kütüphane up			
ENTITY ram_controller IS
port (
	clk 		: in  std_logic;
	rstn 	   : in  std_logic;
	wr_en 	: out std_logic;
	wr_data 	: out std_logic_vector(7 downto 0);
	wr_add 	: out std_logic_vector(7 downto 0);
	rd_en 	: out std_logic;
	rd_add 	: out std_logic_vector(7 downto 0);
	rd_data  : in  std_logic_vector(7 downto 0);
	error    : out std_logic  --yazma ve okuma nın eşitliğini kontrol ediyoruz
	
);
END ENTITY ram_controller;
ARCHITECTURE arch OF ram_controller IS
Type state_type is (INITIALIZATION, ALL_RAM_DATA_ZERO, ALL_RAM_DATA_ADRESS);
--3 durumumuz var: boşta, RAM sıfırlama, RAM a adres değerini o adrese yazma
signal state : state_type;
signal counter : std_logic_vector(7 downto 0);--ram adresslerine ulaşma için bi sayıcı tanımlıyoruz
signal counter_d1 : std_logic_vector(7 downto 0);
signal counter_d2 : std_logic_vector(7 downto 0);
signal counter_d3 : std_logic_vector(7 downto 0);
BEGIN
PROCESS (rstn,clk) 
begin
	if(rstn        		   <= '0') then 
	counter 			      	<= (others => '0');
   wr_en 						<= '0';
	wr_data 						<= (others => '0');
	wr_add 						<= (others => '0');
	rd_en				 			<= '0';
	rd_add						<= (others => '0');
	state					  	   <= INITIALIZATION;--başlangıçta statemizi İDLE ye atıyoruz
	error                   <= '0'; --error u hata durumun da 1 olması için '0' yapıyoruz
	--başlangıç sıfırlamaları yapıyoruz. çıkışlar ve signaller
	counter_d1					<=	(others => '0');--yazma okuma sonunda ALL_RAM_DATA_ADRESS state'inde yazmanın 255. adresteki ve okumanın 254. 
	--adreslerde değerleri kaybetmemek için sayacımızı 1 clk geciktirdik.
	counter_d2					<=	(others => '0');--yazma okuma sonunda ALL_RAM_DATA_ADRESS state'inde yazmanın 2 clk gecikmeyle olduğu için
	--sonlarda olan istenmeyen durumlar için counter sayacımızı 2 clk geciktirdik
	counter_d3 					<=	(others => '0');--yazılanla okunanı kontrol için 2 clk gecikme sağladık
		
	elsif rising_edge(clk) then--başla
		counter_d1 <= counter;--counter ın 1 clk gecikmiş halini counter_d_1 e atıyoruz
		counter_d2 <= counter_d1;--counter ın 2 clk gecikmiş halini counter_d_2 e atıyoruz
		counter_d3 <= counter_d2;--counter ın 3 clk gecikmiş halini counter_d_3 e atıyoruz
   case state is

		when INITIALIZATION  => -- RAM adreslerine 0 yazdırıyoruz
			counter 			      			<= (others => '0');
			wr_en 								<= '0';
			wr_data 								<= (others => '0');
			wr_add 								<= (others => '0');
			rd_en				 					<= '0';
			rd_add								<= (others => '0');
			state					  	   		<= ALL_RAM_DATA_ZERO;--başlangıçta statemizi İDLE ye atıyoruz
			error                   		<= '0';
						
		when ALL_RAM_DATA_ZERO =>
			if(counter        /=  x"FF") then
				wr_en          				<= '1';
				rd_en   							<= '0';
				wr_add         				<= counter;
				wr_data        				<= (others => '0');
				counter        				<= counter + '1';
				state         			 		<= ALL_RAM_DATA_ZERO;
			
			else 
				wr_en  							<= '1';--gecikme olmaması için enableyi kesmiyoruz
				wr_add  							<= counter;
				wr_data 							<= (others => '0');
				counter 							<= (others => '0');
				state   							<= ALL_RAM_DATA_ADRESS;
			end if;
		
		when ALL_RAM_DATA_ADRESS => -- RAM adreslerine adress değerini yazdırıyoruz ve kontrol ediyoruz
			if(counter 			/=  x"FF") then
				wr_en   							<= '1';
				wr_add  							<= counter;
				if(counter_d1			/=  x"FF") then
					rd_add  							<= counter_d1;				
				end if;
				wr_data 							<= counter;
				rd_en   							<= '1';
				counter 							<= counter + '1' ;
				state   							<= ALL_RAM_DATA_ADRESS;
				if(rd_data /= counter_d3 and counter > 2) then --yazılanla okunan aynı m kontrol ediliyor
					error							<=  '1';
				else 
					error							<=  '0';
				end if;
				
			elsif(counter_d1 	/=  x"FF") then --yazma okuma sonunda ALL_RAM_DATA_ADRESS state'inde yazmanın 255. adresteki ve okumanın 254. 
	--adreslerde değerleri kaybetmemek için sayacımızı 1 clk geciktirdik.
				wr_en   							<= '1';
				wr_add  							<= counter;
				wr_data 							<= counter;
				rd_en   							<= '1';
				rd_add  							<= counter_d1 ;
				counter 							<= x"FF";
				state   							<= ALL_RAM_DATA_ADRESS;
				if(rd_data /= counter_d3) then --yazılanla okunan aynı m kontrol ediliyor
					error							<=  '1';
				else 
					error							<=  '0';
				end if;
			
			elsif(counter_d2 	/=  x"FF") then --yazma okuma sonunda ALL_RAM_DATA_ADRESS state'inde yazmanın 2 clk gecikmeyle olduğu için
	--sonlarda olan istenmeyen durumlar için counter sayacımızı 2 clk geciktirdik
				wr_en   							<= '1';
				wr_add  							<= counter_d1;
				wr_data 							<= counter;
				rd_en   							<= '1';
				rd_add  							<= counter_d1 ;
				counter_d1 						<= x"FF";
				state   							<= ALL_RAM_DATA_ADRESS;
				if(rd_data /= counter_d3) then --yazılanla okunan aynı m kontrol ediliyor
					error							<=  '1';
				else 
					error							<=  '0';
				end if;
					
			else 
				wr_en   							<= '1';--gecikme olmaması için enableyi kesmiyoruz
				wr_add  							<= counter_d2 ;
				wr_data 							<= counter ;
				rd_en   							<= '1';--gecikme olmaması için enableyi kesmiyoruz
				rd_add  							<= counter_d1 ;
				counter 			      		<= (others => '0');
				state   							<= INITIALIZATION;				
				if(rd_data /= counter_d3) then --yazılanla okunan aynı mı kontrol ediliyor
					error							<=  '1';
				else 
					error							<=  '0';
				end if;
			end if;	
		when others => 	state <= INITIALIZATION;--herhangi bir olağandışı durumda Başlangıç state'ye döndürüyoruz
	end case;
	end if ;
end process ;
END ARCHITECTURE arch;
