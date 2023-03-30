LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all; 
use ieee.STD_LOGIC_TEXTIO.all;
ENTITY image_generator IS
 generic ( 
  FrameToLineTime  : integer := 512; 
  LineToFrameTime  : integer := 512; 
  PIXEL_NUMBER	   : integer := 640; 
  delay_valid      : integer := 100; 
  LineToLineTime   : integer := 100; 
  LINE_NUMBER 	   : integer := 512;
  PassiveFrameTime : integer := 1620196
);

 port (
  clk 		   : in std_logic  ; 
  rstn 		   : in std_logic  ;
  
  active_frame : out std_logic ;
  pixel_valid  : out std_logic ; 
  pixel_data   : out std_logic_vector(7 downto 0)
);
END ENTITY image_generator;

ARCHITECTURE arch OF image_generator IS
	TYPE state_type is (INITIALIZATION, FRAMETOLINE, PIXEL_PRE_ACTIVE, PIXEL_ACTIVE, LINETOLINE,LINETOFRAME, PASSIVEFRAME);
	SIGNAL state         : state_type;
	SIGNAL counter       : std_logic_vector(21 downto 0);	
	SIGNAL counter_pixel : std_logic_vector(21 downto 0);		
BEGIN
	PROCESS (rstn,clk) 			
	   type int_type is file of integer;
		VARIABLE L : LINE;
		VARIABLE pixel_rd : INTEGER; 	 	
		--FILE F :TEXT open READ_MODE is "D:\line_value.txt";
		FILE F :TEXT;
	BEGIN
		if rstn = '0' then												
			pixel_valid   													<= '0';
			pixel_data   													<= (others => '0');
			counter  														<= (others => '0');
			state															<= INITIALIZATION;
			counter        													<= (others => '0');
			active_frame													<= '0';
			counter_pixel													<= (others => '0');
		elsif rising_edge(clk) then	
			case state is
				when INITIALIZATION => --belirlediğimiz gecikme süresine göre(Delay_valid) 
					pixel_valid   											<= '0';
					active_frame											<= '0';
					counter                         						<= counter + '1';	
					if(counter = delay_valid - 1) then
						counter  								  			<= (others => '0');
						state                           					<= FRAMETOLINE;					 
					end if;
				
				when FRAMETOLINE => 
					file_open(F,"D:\R_Kasal\line_value.txt",read_mode);
					active_frame											<= '1';
					counter													<= counter + '1';					
					if(counter = FrameToLineTime - 1) then
						counter  											<= (others => '0');
						state                           					<= PIXEL_PRE_ACTIVE;							
					end if;
				
				when PIXEL_PRE_ACTIVE  => 							 		  
					READLINE(F,L);	
					READ(L, pixel_rd);					
					pixel_data 												<= std_logic_vector(to_unsigned(pixel_rd,8));
					pixel_valid   											<= '1';
					counter													<= counter + '1';
					counter_pixel                              				<=	counter_pixel + '1';
					state                           						<= PIXEL_ACTIVE;
											
				when PIXEL_ACTIVE  => 							 		  
					READ(L, pixel_rd);
					pixel_data 												<= std_logic_vector(to_unsigned(pixel_rd,8));
					counter													<= counter + '1';
					counter_pixel                              				<=	counter_pixel + '1';	
					if(counter = PIXEL_NUMBER - 1) then--pixel sayısı									
					   if(endfile(F)) then
							counter  										<= (others => '0');
							state                           				<= LINETOFRAME;							
						else
							counter  										<= (others => '0');
							state                           				<= LINETOLINE;
						end if;
					end if;
				
				when LINETOLINE =>
					counter													<= counter + '1';
					pixel_valid   											<= '0';
					if( counter = LineToLineTime - 1) then
						state                           					<= PIXEL_PRE_ACTIVE;
						counter  											<= (others => '0');
							
					end if;		 
						
				when LINETOFRAME =>
					counter                          						<= counter + '1';
					pixel_valid   											<= '0';					
					if ( counter = LineToFrameTime - 1) then 
						state                           					<= PASSIVEFRAME;
						counter  											<= (others => '0');	
						
					end if;
				
				when PASSIVEFRAME =>
					counter                          						<= counter + '1';
					active_frame											<= '0';
					
					if ( counter = PassiveFrameTime - 1) then 
						state                           					<= INITIALIZATION;
						counter  											<= (others => '0');	
						file_close(F);			
					end if;
			
				when others =>   
					state 													<= INITIALIZATION;
				
			end case;
		end if;
	end process ;
END ARCHITECTURE arch;