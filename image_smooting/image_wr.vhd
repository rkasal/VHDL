---------------------------------------
----------- Ramazan Kasal -------------
---------------------------------------
--Bu yapý filtre uygulamasý amacýyla yapýlmýþtýr.
--Görüntüdeki pixelleri 6x6 matris kullanarak yumuþatma yapar.
--Kenar pixeller hesaba alýnmayacak.
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all; 
use ieee.STD_LOGIC_TEXTIO.all;
ENTITY image_wr IS
	port (
	clk  			     	: in std_logic;
	rstn 			   		: in std_logic; 
	
	active_frame			: in std_logic; 		
	pixel_valid	 			: in std_logic; 
	pixel_data 		  		: in std_logic_vector(7 downto 0); 
	
	active_frame_o	  		: out std_logic; 
	pixel_valid_o 	  		: out std_logic; 
	pixel_data_o 	  		: out std_logic_vector(7 downto 0) 
	);
END ENTITY image_wr;
ARCHITECTURE hist_process_arch OF image_wr IS
	TYPE state_type_sum IS (INITIALIZATION, IDLE, d_val_wait, line_active, line_passive );
	SIGNAL state_sum   		: state_type_sum;
	SIGNAL pixel_data_D1	: std_logic_vector(7 downto 0);
	SIGNAL pixel_valid_D1 	: std_logic;
	SIGNAL active_frame_D1 	: std_logic;
BEGIN			
	process_1:PROCESS(clk,rstn)
		VARIABLE L : LINE;
		VARIABLE pixel_wr : INTEGER; 	 	
		FILE F :TEXT;
	BEGIN
		if rstn = '0' then
			pixel_valid_o 				<= '0';
			pixel_data_o 				<= (others => '0');
			active_frame_o 				<= '0';
			pixel_data_D1				<= (others => '0');
			pixel_valid_D1				<= '0';
			state_sum					<= INITIALIZATION;
			active_frame_D1				<= '0';
			
		elsif rising_edge(clk) then	
			pixel_data_D1	<= pixel_data;
			pixel_valid_D1	<= pixel_valid;
			active_frame_D1 <= active_frame;
			case state_sum	is 
				when INITIALIZATION =>			
					pixel_valid_o 				<= '0';
					pixel_data_o 				<= (others => '0');
					active_frame_o 				<= '0';
					pixel_data_D1				<= (others => '0');
					pixel_valid_D1				<= '0';
					state_sum					<= IDLE;
					active_frame_D1				<= '0';
					
				when IDLE =>				
					pixel_valid_o								<= '0';
					if( active_frame = '1' and active_frame_D1 = '0') then
						state_sum 								<= d_val_wait;
					end if;
				
				when d_val_wait =>
					pixel_valid_o								<= '0';
					if( pixel_valid = '1') then		
						state_sum 								<= line_active;
						file_open(F,"D:\line_ham.txt",write_mode);
					end if;

				when line_active =>
					WRITE(L, TO_INTEGER(UNSIGNED(pixel_data_d1)),LEFT,4);
					if( pixel_valid = '0') then		
						state_sum 								<= line_passive;
					end if;
					
				when line_passive =>
					pixel_valid_o								<= '0';
					if( pixel_valid = '1') then
						state_sum								<= line_active;
						WRITELINE(F,L);		
					end if;
					if( active_frame = '0' ) then
						state_sum								<= IDLE;	
						WRITELINE(F,L);
					end if;
					
				when others => 	
					state_sum 									<= INITIALIZATION;
			end case;
		end if;
	END PROCESS process_1;
END ARCHITECTURE hist_process_arch;