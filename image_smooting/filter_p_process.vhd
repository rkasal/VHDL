---------------------------------------
----------- Ramazan Kasal -------------
---------------------------------------
--Bu yapý filtre uygulamasý amacýyla yapýlmýþtýr.
--Görüntüdeki pixelleri 6x6 matris kullanarak yumuþatma yapar.
--Kenar pixeller hesaba alýnmayacak.
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

ENTITY hist_process IS
	generic ( 
	Line_Number  : integer 	:= 512;-- FtoL
	Pixel_Number : integer  := 640;
	ActiveFrameRtime : integer := 740;   
	ActiveFrameFtime : integer := 512	
);
	port (
	clk  			     	: in std_logic;
	rstn 			   		: in std_logic; 
	
	active_frame			: in std_logic; 		
	pixel_valid	 			: in std_logic; 
	pixel_data 		  		: in std_logic_vector(7 downto 0); 
	
	almost_full1            : in std_logic;
	empty1                  : in std_logic;
	almost_full2            : in std_logic;
	empty2                  : in std_logic;
	
	rd_data1 		 		: in std_logic_vector(7 downto 0);	
	rd_data2 		 		: in std_logic_vector(7 downto 0);	
	rd_en1 				  	: out std_logic;
	rd_en2 				  	: out std_logic;
	
	wr_en1 				  	: out std_logic;
	wr_en2 				  	: out std_logic;
	wr_data1 		 		: out std_logic_vector(7 downto 0);
	wr_data2 		 		: out std_logic_vector(7 downto 0);
	
	active_frame_o	  		: out std_logic; 
	pixel_valid_o 	  		: out std_logic; 
	pixel_data_o 	  		: out std_logic_vector(7 downto 0) 
	);
END ENTITY hist_process;
ARCHITECTURE hist_process_arch OF hist_process IS
	TYPE state_type_wr IS (INITIALIZATION, IDLE, d_val_wait, first_line, second_line_passive, second_line_active, wr_active, wr_passive, last_wait_for_fifo, last_rd_fifo );
	TYPE state_type_sum IS (INITIALIZATION, IDLE, d_val_wait, first_line, second_line_passive, second_line_active, line_active, line_passive, last_line_wait, last_Line_active );
	TYPE state_sum_wait IS (first_sum, second_sum, active_sum, last_sum, last_send_data);	
	TYPE state_type_frame IS (INITIALIZATION, IDLE, send_wait, active_frame_st, active_frame_end);	
	SIGNAL state_wr 	    : state_type_wr;
	SIGNAL state_sum   		: state_type_sum;
	SIGNAL state_sum_wait_1 : state_sum_wait;
	SIGNAL state_sum_wait_1stLine : state_sum_wait;	
	SIGNAL state_sum_wait_actLine : state_sum_wait;
	SIGNAL state_sum_wait_LastLine : state_sum_wait;
	SIGNAL state_frame      : state_type_frame;
	SIGNAL k1				: std_logic_vector(12 downto 0);
	SIGNAL counter_line		: std_logic_vector(11 downto 0);
	SIGNAL counter_line_wr	: std_logic_vector(11 downto 0);
	SIGNAL counter_frameTime: std_logic_vector(11 downto 0);
	SIGNAL pixel_data_D1	: std_logic_vector(7 downto 0);
	SIGNAL pixel_data_D2 	: std_logic_vector(7 downto 0);
	SIGNAL pixel_data_D3 	: std_logic_vector(7 downto 0);
	SIGNAL pixel_data_D4 	: std_logic_vector(7 downto 0);
	SIGNAL pixel_valid_D1 	: std_logic;
	SIGNAL pixel_valid_D2 	: std_logic;
	SIGNAL pixel_valid_D3 	: std_logic;
	SIGNAL active_frame_D1 	: std_logic;
	SIGNAL rd_data1_D1		: std_logic_vector(7 downto 0);
	SIGNAL rd_data1_D2		: std_logic_vector(7 downto 0);
	SIGNAL rd_data2_D1 		: std_logic_vector(7 downto 0);
	SIGNAL rd_data2_D2 		: std_logic_vector(7 downto 0);
BEGIN			
	process_1:PROCESS(clk,rstn)
	BEGIN
		if rstn = '0' then
			state_sum					<= INITIALIZATION;
			pixel_valid_o 				<= '0';
			pixel_data_o 				<= (others => '0');	
			k1		                    <= (others => '0');
			state_sum_wait_1stLine		<= first_sum;
			state_sum_wait_actLine		<= first_sum;
			state_sum_wait_LastLine		<= first_sum;
			counter_line               	<= (others => '0');
			
		elsif rising_edge(clk) then	
			rd_data1_d1	<= rd_data1;
			rd_data1_d2 <= rd_data1_d1; 
			rd_data2_d1	<= rd_data2;
			rd_data2_d2 <= rd_data2_d1;		
			case state_sum	is 
				when INITIALIZATION =>			
					state_sum 		       								<= IDLE;	
					pixel_valid_o 	                    				<= '0';
					pixel_data_o 	                    				<= (others => '0');
					k1		                   							<= (others => '0');
					counter_line               							<= (others => '0');
					state_sum_wait_1stLine								<= first_sum;
					state_sum_wait_actLine 								<= first_sum;
					state_sum_wait_LastLine								<= first_sum;
					
				when IDLE =>--burada active frame yi bekliyoruz					
					pixel_valid_o										<= '0';
					if( active_frame = '1' and active_frame_D1 = '0') then
						state_sum 										<= d_val_wait;
					end if;
				
				when d_val_wait =>-- burada ilk line nýn gelmesini bekliyoruz
					pixel_valid_o										<= '0';
					if( pixel_valid_D1 = '1') then		
						state_sum 										<= first_line;
					end if;
					
				when first_line =>--burada ilk line ý fifo1 e yazýyoruz
					pixel_valid_o										<= '0';
					if( pixel_valid_D1 = '0') then
						state_sum 										<= second_line_passive;
					end if;
				
				when second_line_passive =>--burada 2. line ý bekliyoruz, 1. line elimizde
					pixel_valid_o										<= '0';
					if( pixel_valid_D1 = '1') then
						state_sum 										<= second_line_active;
					end if;
				
				when second_line_active =>--burada 2. line ý fifo1 e yazýyoruz 1. line fifo1 den okuyoruz
					pixel_valid_o										<= '0';
					if( pixel_valid_D1 = '0') then
						state_sum 										<= line_passive;
					end if;
					
				when line_passive	 =>--burada line bekliyoruz
					pixel_valid_o										<= '0';
					if( pixel_valid_d1 = '1') then
						state_sum										<= line_active;							
					end if;
					
					if( active_frame = '0' ) then 
						state_sum										<= IDLE;
					end if;
					
				when line_active =>--burada line bekliyoruz
					case state_sum_wait_actLine is
						when first_sum =>						     
					        state_sum_wait_actLine 						<= second_sum;
							counter_line								<= counter_line + '1';	
							
					    when second_sum	=>						    		 
							k1 <= ("0000" &   pixel_data_d3 & '0') + ("000" & pixel_data_D3 & "00") + ("0000" & pixel_data_d2 & '0') + ("000" & rd_data1_D1 & "00") + ("00" & rd_data1_d1 & "000") + ("000" & rd_data1 & "00") + ("0000" & rd_data2_D1 & '0') + ("000" & rd_data2_d1 & "00") + ("0000" & rd_data2 & '0') ;
					    	state_sum_wait_actLine 						<= active_sum;	
					    	
					    when active_sum	=>	  
					    	k1 <= ("0000" &   pixel_data_d4 & '0') + ("000" & pixel_data_D3 & "00") + ("0000" & pixel_data_d2 & '0') + ("000" & rd_data1_D2 & "00") + ("00" & rd_data1_d1 & "000") + ("000" & rd_data1 & "00") + ("0000" & rd_data2_D2 & '0') + ("000" & rd_data2_d1 & "00") + ("0000" & rd_data2 & '0') ;
							pixel_valid_o										<= '1';
							pixel_data_o 								<=  k1(12 downto 5);		
							if( pixel_valid_d1 = '0' ) then               
								state_sum_wait_actLine					<= last_sum;
							end if;	
							
						when last_sum	=>	  
					    	k1 <= ("0000" &   pixel_data_d3 & '0') + ("000" & pixel_data_D2 & "00") + ("0000" & pixel_data_d2 & '0') + ("000" & rd_data1_D1 & "00") + ("00" & rd_data1 & "000") + ("000" & rd_data1 & "00") + ("0000" & rd_data2_D1 & '0') + ("000" & rd_data2 & "00") + ("0000" & rd_data2 & '0') ;
							pixel_valid_o										<= '1';
							pixel_data_o 								<=  k1(12 downto 5);
							state_sum_wait_actLine						<= last_send_data;
								
						when last_send_data =>
							k1 											<= (others => '0');
							pixel_valid_o										<= '1';
							pixel_data_o 								<= k1(12 downto 5);			
							state_sum_wait_actLine						<= first_sum;				
							state_sum									<= line_passive;
					end case;
				
				when others => 	
					state_sum 							<= INITIALIZATION;
			end case;
		end if;
	END PROCESS process_1;
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------	
	wr_process : PROCESS(clk,rstn)
	BEGIN
		if rstn = '0' then
			state_wr 						<= INITIALIZATION;			
			wr_en1 	                  		<= '0';	
			wr_en2 	                  		<= '0';	
			rd_en1							<= '0';	
			rd_en2                          <= '0';	
			wr_data1						<= (others => '0');
			wr_data2						<= (others => '0');
			pixel_valid_D1					<= '0'; 
			pixel_valid_D2					<= '0';
			pixel_valid_D3					<= '0';
			pixel_data_D1					<= (others => '0');
			pixel_data_D2					<= (others => '0');
			pixel_data_D3					<= (others => '0');
			active_frame_D1					<= '0';
			counter_line_wr					<= (others => '0');
			
		elsif Rising_edge(clk) then
			pixel_valid_d1 <= pixel_valid;
			pixel_valid_d2 <= pixel_valid_d1;
			pixel_valid_d3 <= pixel_valid_d2;
			pixel_data_d1  <= pixel_data;
			pixel_data_d2  <= pixel_data_d1;
			pixel_data_d3  <= pixel_data_d2;
			pixel_data_d4  <= pixel_data_d3;
			active_frame_D1<= active_frame;	
			case state_wr is
				when INITIALIZATION =>			
					wr_en1 	                  			<= '0';	
					wr_en2 	                  			<= '0';	
					rd_en1								<= '0';	
					rd_en2                            	<= '0';	
					wr_data1							<= (others => '0');
					wr_data2							<= (others => '0');
					state_wr 							<= IDLE;
					counter_line_wr						<= (others => '0');
					
				when IDLE =>--burada active frame yi bekliyoruz
					
					
					if( active_frame = '1' and active_frame_D1 = '0') then
						state_wr 						<= d_val_wait;
					end if;
				
				when d_val_wait =>-- burada ilk line nýn gelmesini bekliyoruz
					wr_en1								<= '0';
					wr_en2								<= '0';
					if( pixel_valid_D1 = '1') then
						state_wr 						<= first_line;
					end if;
					
				when first_line =>--burada ilk line ý fifo1 e yazýyoruz
					wr_en1								<= '1';
					wr_data1	 						<= pixel_data_d2;
					wr_en2								<= '0';
					
					if( pixel_valid_D1 = '0') then
						state_wr 						<= second_line_passive;
					end if;
				
				when second_line_passive =>--burada 2. line ý bekliyoruz, 1. line elimizde
					wr_en1								<= '0';
					wr_en2								<= '0';
					rd_en1								<= '0';
					rd_en2								<= '0';
					
					if( pixel_valid = '1' ) then               
						rd_en1							<= '1';
					end if;									   
					
					if( pixel_valid_D1 = '1') then
						state_wr 						<= second_line_active;
					end if;
				
				when second_line_active =>--burada 2. line ý fifo1 e yazýyoruz 1. line elimizde
					wr_en1								<= '1';
					wr_data1	 						<= pixel_data_d2;
					wr_en2								<= '1';
					wr_data2	 						<= rd_data1;
					
					if( pixel_valid = '0' ) then               
						rd_en1							<= '0';
					end if;									   
					
					if( pixel_valid_D1 = '0') then
						state_wr 						<= wr_passive;
					end if;
					
				when wr_passive =>--burada line bekliyoruz
					wr_en1								<= '0';
					wr_en2								<= '0';				
					
					if( pixel_valid = '1' ) then               --//*2 clk önceden fifo1 den istek yapmak için state++ 
						rd_en1							<= '1';--geçiþlerini pixel_valid_d1 ile kontrol ediyoruz++			
						rd_en2 							<= '1';--bu bize extra geciktirmeye sebep oldu*//
					end if;									   
				
					if( pixel_valid_d1 = '1') then--Rising_edge(pixel_valid_d1)
						state_wr						<= wr_active;	
						counter_line_wr					<= counter_line_wr + '1';		
					end if;
					
					if( active_frame = '0' and active_frame_d1 = '1') then 
						state_wr 						<= IDLE;
					end if;
				
				when wr_active =>--burada line bekliyoruz
					wr_en1								<= '1';
					wr_data1	 						<= pixel_data_d2;
					wr_en2								<= '1';
					wr_data2	 						<= rd_data1;
					
					if( pixel_valid = '0' ) then               
						rd_en1							<= '0';
						rd_en2 							<= '0';		
					end if;
					
					if( pixel_valid_D1 = '0') then					
						if( counter_line_wr = Line_Number - 2) then
							state_wr 					<= last_wait_for_fifo;
							counter_line_wr				<= (others => '0');
						else
							state_wr 					<= wr_passive;
						end if;
					end if;
					 
				when last_wait_for_fifo =>--burada line bekliyoruz
					counter_line_wr						<= counter_line_wr + '1';
					wr_en1								<= '0';
					wr_en2								<= '0';		
					if( counter_line_wr = x"61") then
						state_wr 						<= last_rd_fifo;
						counter_line_wr					<= (others => '0');
					end if;
					
				when last_rd_fifo =>--burada line bekliyoruz
					rd_en1								<= '1';
					rd_en2								<= '1';
					wr_en1								<= '0';
					wr_en2								<= '0';			
					if( empty1 = '1') then
						state_wr 						<= IDLE;
					end if;
					
				when others =>
					state_wr 							<= INITIALIZATION;
			end case;
		end if;
	END PROCESS wr_process;
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
	proc_generate_frame: process(clk,rstn)
	begin
		if rstn = '0' then			
			active_frame_o						<= '0';
			state_frame							<= INITIALIZATION;
			counter_frameTime					<= (others => '0');
			
		elsif rising_edge(clk) then	
			case state_frame is
				when INITIALIZATION =>			
					active_frame_o 	                  			<= '0';	
					state_frame 								<= IDLE;
					counter_frameTime							<= (others => '0');
					
				when IDLE =>--burada active frame yi bekliyoruz										
					active_frame_o 								<= '0';
					if( active_frame = '1' and active_frame_D1 = '0') then
						state_frame 							<= send_wait;
					end if;
							
				when send_wait =>
					active_frame_o 								<= '0';					
					counter_frameTime							<= counter_frameTime + '1';
					if( counter_frameTime = ActiveFrameRtime + 2) then
						state_frame								<= active_frame_st;	
						counter_frameTime						<= (others => '0');
					end if;		
				
				when active_frame_st =>					
					active_frame_o 								<= '1';
					if( active_frame = '0' and empty1 = '1') then
						state_frame 							<= active_frame_end;
					end if;
					
				when active_frame_end =>
					counter_frameTime							<= counter_frameTime + '1';
					if( counter_frameTime = ActiveFrameFtime + 1 ) then
						state_frame								<= IDLE;
						counter_frameTime						<= (others => '0');		
					end if;	
						
				when others => 	
					state_frame									<= INITIALIZATION;			
			end case;			
		end if;					
	end process;	
	END ARCHITECTURE hist_process_arch;