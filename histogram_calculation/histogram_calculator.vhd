LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

ENTITY histogram_calculator IS
port (
	clk  			  		 : in std_logic;
	rstn 			   		 : in std_logic; 
	
	active_frame 			 : in std_logic; 
	pixel_valid	 			 : in std_logic; 
	pixel_data  			 : in std_logic_vector(7 downto 0); 
	
	wr_en 					 : out std_logic;
	wr_add  		   		 : out std_logic_vector (7 downto 0);
	wr_data 		   		 : out std_logic_vector(19 downto 0);

	rd_en 				  	 : out std_logic;
	rd_add 					 : out std_logic_vector(7 downto 0);
	rd_data 		 		 : in std_logic_vector(19 downto 0);
	
	hist_valid            : out std_logic;
	hist_pixel_data       : out std_logic_vector(7 downto 0);
	hist_pixel_data_value : out std_logic_vector(19 downto 0)
);
END ENTITY histogram_calculator;
ARCHITECTURE arch OF histogram_calculator IS
TYPE state_type IS (INITIALIZATION, FVAL_WAIT, ALL_RAM_DATA_ZERO, LVAL_WAIT, HIST_CALC, HIST_SEND);
TYPE state_type2 IS (READ_1_ST, READ_2_ST, HIST_DATA, WR_1_ST, WR_2_ST);
TYPE state_type3 IS (READ_1_ST, READ_2_ST, SEND_DATA);
SIGNAL state1 		       : state_type;
SIGNAL state2 		       : state_type2;
SIGNAL state3 		       : state_type3;
SIGNAL pixel_data_D1	   : std_logic_vector(7 downto 0);
SIGNAL pixel_data_D2 	   : std_logic_vector(7 downto 0);
SIGNAL pixel_data_D3 	   : std_logic_vector(7 downto 0);
SIGNAL pixel_data_D4 	   : std_logic_vector(7 downto 0);
SIGNAL pixel_data_D5 	   : std_logic_vector(7 downto 0);
SIGNAL pixel_valid_D1 	   : std_logic;
SIGNAL pixel_valid_D2 	   : std_logic;
SIGNAL pixel_valid_D3 	   : std_logic;
SIGNAL pixel_valid_D4 	   : std_logic;
SIGNAL pixel_valid_D5 	   : std_logic;
SIGNAL active_frame_D1 	   : std_logic;
SIGNAL counter_ram         : std_logic_vector(7 downto 0);
SIGNAL hist_pixel_data_int : std_logic_vector(7 downto 0);
BEGIN
PROCESS(clk,rstn)
BEGIN
	if rstn = '0' then
		hist_valid                              <= '0';
		hist_pixel_data							<= (others => '0');
		hist_pixel_data_value					<= (others => '0');
		pixel_data_D1							<= (others => '0');
		pixel_data_D2							<= (others => '0');
		pixel_data_D3							<= (others => '0');
		pixel_data_D4							<= (others => '0');
		pixel_data_D5							<= (others => '0');
		pixel_valid_D1							<= '0'; 
		pixel_valid_D2							<= '0';
		pixel_valid_D3							<= '0';
		pixel_valid_D4							<= '0';
		pixel_valid_D5							<= '0';
		active_frame_D1							<= '0';
		counter_ram								<= (others => '0');
		wr_en									<= '0';
		wr_add									<= (others => '0');
		wr_data									<= (others => '0');
		rd_en									<= '0';
		rd_add									<= (others => '0');
		state1                                  <= INITIALIZATION;
		state2                                  <= READ_1_ST;
		state3									<= READ_1_ST;
		hist_pixel_data_int						<= (others => '0');

	elsif rising_edge(clk) then
		pixel_data_D1							<=pixel_data;
		pixel_data_D2							<=pixel_data_D1;
		pixel_data_D3							<=pixel_data_D2;
		pixel_data_D4							<=pixel_data_D3;
		pixel_data_D5							<=pixel_data_D4;
		pixel_valid_D1 							<=pixel_valid;		
		pixel_valid_D2							<=pixel_valid_D1;
		pixel_valid_D3							<=pixel_valid_D2;
		pixel_valid_D4							<=pixel_valid_D3;
		pixel_valid_D5							<=pixel_valid_D4;
		active_frame_D1							<=active_frame;
		CASE state1 IS
			when INITIALIZATION =>
				hist_valid                     	<= '0';
				hist_pixel_data					<= (others => '0');
				hist_pixel_data_value			<= (others => '0');
				counter_ram        				<= (others => '0');
				state1                          <= FVAL_WAIT;
				state2                          <= READ_1_ST;
				state3                          <= READ_1_ST;
				wr_en							<= '0';
				wr_add							<= (others => '0');
				wr_data							<= (others => '0');
				rd_en							<= '0';
				rd_add							<= (others => '0');
				
			when FVAL_WAIT =>		
				hist_pixel_data					<= (others => '0');
				hist_pixel_data_value			<= (others => '0');
				hist_valid                      <= '0';
				rd_en      						<= '0';
				wr_en							<= '0';
				if( active_frame = '1' and active_frame_D1 = '0') then
					state1                      <= ALL_RAM_DATA_ZERO;
				end if;
					
			when ALL_RAM_DATA_ZERO =>--Bu state'de RAM adresleri sıfırlanacak
				wr_en          					<= '1'; 
				wr_add         					<= counter_ram;
				wr_data        					<= (others => '0');				
				if( counter_ram = x"FF") then	
					counter_ram   				<= (others => '0');
					state1        				<= LVAL_WAIT;
						
				else	
					counter_ram        			<= counter_ram + '1';					
				end if;
			
			when LVAL_WAIT =>--Bu state'de DVAL bekleniyor
				if( pixel_valid = '1') then
					state1                      <= HIST_CALC;					
						
				elsif( active_frame_D1 = '1' and active_frame = '0' ) then
					state1                      <= HIST_SEND;				
					
				else--RAM den okuma yaparken 2 clk gecikme olduğu için pixel_valid = '1' olduğunda burada okuma komutları atıyoruz					
					rd_en						<= '0';
					rd_add						<= (others => '0');
					wr_en						<= '0';	
				end if;
						
			when HIST_CALC =>					
				CASE state2 IS								
					when READ_1_ST =>--RAM den okuma yaparken 2 clk gecikme olduğu için bu state'de sadece okuma komutları atıyoruz
						rd_add      			<= pixel_data_D1;
						rd_en      				<= '1';														
						state2                  <= READ_2_ST;
				
					when READ_2_ST =>--RAM den okuma yaparken 2 clk gecikme olduğu için bu state'de sadece okuma komutları atıyoruz									
						rd_add      			<= pixel_data_D1;
						state2                  <= WR_1_ST;
		
					when WR_1_ST =>--ilk data mızın RAM deki değerini arttırıyoruz										
						wr_en                   <= '1' ;
						wr_add                  <= pixel_data_D3 ;
						wr_data                 <= rd_data + 1 ;							
						rd_add      			<= pixel_data_D1;
						state2                  <=	WR_2_ST;
													
					when WR_2_ST =>--ikinci data mızın RAM deki değerini bir önceki data ya bakarak arttırıyoruz																		                          			
						if( pixel_data_D3 = pixel_data_D4) then		
							state2              <=	HIST_DATA;
							rd_add      		<= pixel_data_D1;
							wr_add              <= pixel_data_D3 ;
							wr_data             <= rd_data + 2 ;	
								
						else		
							state2              <=	HIST_DATA;
							wr_add              <= pixel_data_D3 ;
							wr_data             <= rd_data + 1 ;
							rd_add      		<= pixel_data_D1;
						end if;	
						
					when HIST_DATA =>--RAM deki bilgimiz geldi, gelen RAM(pixel_data) yı 1 arttırıp ilgili RAM adresine yazacağız					
						if( pixel_data_D3 = pixel_data_D4 and pixel_data_D3 = pixel_data_D5) then
							rd_add      		<= pixel_data_D1;
							wr_add              <= pixel_data_D3 ;
							wr_data             <= rd_data + 3 ;																						
							
						elsif( pixel_data_D3 = pixel_data_D4 or pixel_data_D3 = pixel_data_D5  ) then	
							rd_add      		<= pixel_data_D1;
							wr_add              <= pixel_data_D3 ;
							wr_data             <= rd_data + 2 ;																						
						
						else 	
							rd_add      		<= pixel_data_D1;
							wr_add              <= pixel_data_D3 ;
							wr_data             <= rd_data + 1;							
						end if;	
						
						if( pixel_valid_D2	= '0') then--DVAL sıfır olduğunda DVAL beklemeye gidecek
							state1				<= LVAL_WAIT;
							state2				<= READ_1_ST;
						end if;					
					END CASE;
					
			when HIST_SEND =>--Ekrana Histogram değerlerimizi yazdıracağız					
				CASE state3 IS
					when READ_1_ST =>
						rd_add      				<= counter_ram;
						rd_en      					<= '1';
						counter_ram					<= counter_ram + '1';
						state3                 		<= READ_2_ST;
								
					when READ_2_ST =>			
						rd_add      				<= counter_ram;
						rd_en      					<= '1';
						counter_ram					<= counter_ram + '1';
						state3                 		<= SEND_DATA;
							
					when SEND_DATA =>		
						hist_pixel_data				<= hist_pixel_data_int;
						hist_pixel_data_int			<= hist_pixel_data_int + '1';
						hist_pixel_data_value		<= rd_data;
						hist_valid                  <= '1';
						counter_ram					<= counter_ram + '1';
						rd_add      				<= counter_ram;						
						if( counter_ram = x"FF") then		
							rd_en                   <= '0';
								
						elsif( hist_pixel_data_int = x"FF") then		
						   counter_ram   			<= (others => '0');
							state1                  <= FVAL_WAIT;
							state2					<= READ_1_ST;
							state3					<= READ_1_ST;
						end if;	
						
			  END CASE;			
		END CASE;
	end if;
END PROCESS;
END ARCHITECTURE arch;