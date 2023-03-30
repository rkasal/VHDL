LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
ENTITY video_pad IS
 generic ( 
  LineToFrameTime  : integer := 512; -- LtoF
  LineToLineTime   : integer := 100; -- LtoL
  LINE_NUMBER 	   : integer := 512; -- LN
  PIXEL_NUMBER     : integer := 640;
  PassiveFrameTime : integer := 1620196
);

 port (
  clk 		   	 : in std_logic  ; 
  rstn 		   	 : in std_logic  ;
  
  i_active_frame : in std_logic ;
  i_pixel_valid  : in std_logic ; 
  i_pixel_data   : in std_logic_vector(7 downto 0);
  
  rd_data1		 : in std_logic_vector(7 downto 0);
  wr_data1		 : out std_logic_vector(7 downto 0);  
  rd_en1	     : out std_logic ; 
  wr_en1		 : out std_logic ; 
  
  o_active_frame : out std_logic ;
  o_pixel_valid  : out std_logic ; 
  o_pixel_data   : out std_logic_vector(7 downto 0)
  
);
END ENTITY video_pad;
ARCHITECTURE arch OF video_pad IS
	TYPE state_type1 is ( INITIALIZATION, IDLE, first_line_wait, first_line_send, passive_line, fill_fifo, last_line_wait, last_line_send, falling_frame);
	TYPE state_type2 is ( inside_fifo1, last_pattern);
	TYPE state_type3 is ( INITIALIZATION, IDLE, first_wait_pixel, first_line_wr, wait_pixel, fill_fifo );
	TYPE state_type4 is ( head, active_line, tail);
	SIGNAL state1	     : state_type1;
	SIGNAL last_2_lines  : state_type2;
	SIGNAL state_fill    : state_type3;
	SIGNAL add_pattern   : state_type4;
	SIGNAL counter       : std_logic_vector(21 downto 0);--bu sayıcı yı  clk sayarken kullanıyoruz onun için her state geçişlerin de stateden çıkmadan sıfırlıyoruz
	SIGNAL counter_line  : std_logic_vector(10 downto 0);
	SIGNAL counter_value : std_logic_vector(7 downto 0);
	SIGNAL SkipToIdle    : std_logic;
	SIGNAL i_pixel_valid_d1 : std_logic;
	SIGNAL i_pixel_valid_d2 : std_logic;
	SIGNAL i_pixel_valid_d3 : std_logic;
	SIGNAL i_pixel_data_d1   : std_logic_vector(7 downto 0);
	SIGNAL i_pixel_data_d2   : std_logic_vector(7 downto 0);
	SIGNAL i_pixel_data_d3   : std_logic_vector(7 downto 0);
	SIGNAL i_active_frame_d1  : std_logic;
	
BEGIN
	padding_pro : PROCESS (rstn,clk) 	
	BEGIN
		if rstn = '0' then
			o_active_frame 				<= '0';
			o_pixel_valid   			<= '0';
			o_pixel_data   				<= (others => '0');
			counter  					<= (others => '0');
			counter_line				<= (others => '0');
			rd_en1						<= '0';
			state1					    <= INITIALIZATION;
			last_2_lines				<= inside_fifo1;
			SkipToIdle 					<= '0';
			i_pixel_valid_d1  			<= '0';
			i_pixel_valid_d2  			<= '0';
			i_pixel_valid_d3  			<= '0';
			i_pixel_data_d1  			<= (others => '0');
			i_pixel_data_d2  			<= (others => '0');
			i_pixel_data_d3  			<= (others => '0');
			add_pattern					<= head;
			
		elsif rising_edge(clk) then	
			i_pixel_valid_d1  <= i_pixel_valid;
			i_pixel_valid_d2  <= i_pixel_valid_d1;
			i_pixel_valid_d3  <= i_pixel_valid_d2;
			i_pixel_data_d1   <= i_pixel_data;
			i_pixel_data_d2   <= i_pixel_data_d1; 
			i_pixel_data_d3   <= i_pixel_data_d2;
			i_active_frame_d1 <= i_active_frame;		
			
			case state1 is
				when INITIALIZATION =>
					o_active_frame 							<= '0';
					o_pixel_valid   						<= '0';
					o_pixel_data   							<= (others => '0');
					i_pixel_valid_d1  						<= '0';
					i_pixel_valid_d2  						<= '0';
					i_pixel_valid_d3  						<= '0';
					i_pixel_data_d1  						<= (others => '0');
					i_pixel_data_d2  						<= (others => '0');
					i_pixel_data_d3  						<= (others => '0');
					counter  								<= (others => '0');
					counter_line							<= (others => '0');
					state1				  	   				<= IDLE;
					last_2_lines							<= inside_fifo1;
					SkipToIdle 								<= '0';
					rd_en1									<= '0';
					add_pattern								<= head;
					
				when IDLE =>
					o_active_frame 							<= '0';
					o_pixel_valid   						<= '0';
					o_pixel_data   							<= (others => '0');
					if( i_active_frame_d1 = '1' ) then
						state1								<= first_line_wait;
					end if;
				
				when first_line_wait =>
					o_active_frame 							<= '1';
					o_pixel_valid   						<= '0';
					o_pixel_data   							<= (others => '0');
					if( i_pixel_valid = '1') then
						state1								<= first_line_send;
					end if;
					
				when first_line_send =>
						case add_pattern is
							when head =>
								o_active_frame 							<= '1';
								o_pixel_valid   						<= '1';
								o_pixel_data   							<= (others => '0');
								add_pattern								<= active_line;
								
							when active_line =>						
								o_active_frame 							<= '1';
								o_pixel_valid   						<= '1';	
								o_pixel_data   							<= (others => '0');
								if( i_pixel_valid_d1 = '0') then
									add_pattern							<= tail;
								end if;
							
							when tail =>
								o_active_frame 							<= '1';
								o_pixel_valid   						<= '1';
								o_pixel_data   							<= (others => '0');
								add_pattern								<= head;
								state1									<= passive_line;
						end case;
						
				when passive_line =>
					o_active_frame 							<= '1';
					o_pixel_valid   						<= '0';
					o_pixel_data   							<= (others => '0');
					
					if( i_pixel_valid = '1') then
						rd_en1								<= '1';
						state1 								<= fill_fifo;
						counter_line						<= counter_line + '1';
					end if;
				
				when fill_fifo =>
					case add_pattern is
						when head =>
							o_active_frame 							<= '1';
							o_pixel_valid   						<= '1';
							o_pixel_data   							<= (others => '0');
							add_pattern								<= active_line;
							
						when active_line =>						
							o_active_frame 							<= '1';
							o_pixel_valid   						<= '1';
							o_pixel_data   							<= rd_data1;
							if( i_pixel_valid = '0') then
								rd_en1								<= '0';
							end if;
							
							if( i_pixel_valid_d1 = '0') then
								add_pattern							<= tail;
							end if;						
						
						when tail =>
							o_active_frame 							<= '1';
							o_pixel_valid   						<= '1';
							o_pixel_data   							<= (others => '0');
							add_pattern								<= head;
							if( counter_line = LINE_NUMBER - 1 ) then 
								state1	 							<= last_line_wait;
								counter_line						<= (others => '0');
							else 	
								state1								<= passive_line;
							end if;
							
					end case;
				when last_line_wait =>
					counter									<= counter + '1';
					o_active_frame							<= '1';
					o_pixel_valid							<= '0';
					o_pixel_data							<= (others => '0');
					
					if( counter = LineToLineTime - 3 ) then 
						rd_en1								<= '1';	
						counter 							<= (others => '0');
						state1								<= last_line_send;						
					end if;
					
				when  last_line_send =>
					case last_2_lines is
						when inside_fifo1 =>
							case add_pattern is
								when head =>
									o_active_frame 							<= '1';
									o_pixel_valid   						<= '1';
									o_pixel_data   							<= (others => '0');
									add_pattern								<= active_line;
									
								when active_line =>						
									counter									<= counter + '1';
									o_active_frame 							<= '1';
									o_pixel_valid   						<= '1';	
									o_pixel_data   							<= rd_data1;
									if( counter = PIXEL_NUMBER - 2) then
										rd_en1								<= '0';							
									end if;
									if( counter = PIXEL_NUMBER - 1) then
										add_pattern							<= tail;
									end if;
									
								when tail =>
									o_active_frame 							<= '1';
									o_pixel_valid   						<= '1';
									o_pixel_data   							<= (others => '0');
									add_pattern								<= head;
									counter									<= (others => '0');
									last_2_lines							<= last_pattern;
									state1									<= last_line_wait;
							end case;	
							
						when last_pattern =>
							case add_pattern is
								when head =>
									o_active_frame 							<= '1';
									o_pixel_valid   						<= '1';
									o_pixel_data   							<= (others => '0');
									add_pattern								<= active_line;
									
								when active_line =>						
									counter									<= counter + '1';
									o_active_frame 							<= '1';
									o_pixel_valid   						<= '1';	
									o_pixel_data   							<= (others => '0');
									if( counter = PIXEL_NUMBER - 2) then
										rd_en1								<= '0';							
									end if;
									
									if( counter = PIXEL_NUMBER - 1) then
										add_pattern							<= tail;
									end if;
								
								when tail =>
									o_active_frame 							<= '1';
									o_pixel_valid   						<= '1';
									o_pixel_data   							<= (others => '0');
									add_pattern								<= head;
									counter									<= (others => '0');
									last_2_lines							<= inside_fifo1;
									state1									<= falling_frame;
									SkipToIdle 								<= '1';
						end case;
					end case;
					
				when falling_frame => 
					counter									<= counter + '1';
					o_active_frame							<= '1';
					o_pixel_valid							<= '0';
					o_pixel_data							<= (others => '0');
					if( counter = LineToFrameTime - 2 ) then 
						counter 							<= (others => '0');
						state1								<= IDLE;
						SkipToIdle 							<= '0';
					end if;
	
				when others =>
					state1	 								<= INITIALIZATION;
			end case;
		end if;
	end process padding_pro ;
	
	fill_fifo_pro : PROCESS (rstn,clk) 	
	BEGIN
		if rstn = '0' then
			wr_en1 						<= '0';
			wr_data1	  				<= (others => '0');
			state_fill				   	<= INITIALIZATION;
			
		elsif rising_edge(clk) then		
			case state_fill is
				when INITIALIZATION =>
					wr_en1 									<= '0';
					wr_data1	  							<= (others => '0');
					state_fill					  	   		<= IDLE;
				
				when IDLE =>
					wr_en1 									<= '0';
					if( i_active_frame = '1' and i_active_frame_d1 = '0') then
						state_fill 							<= wait_pixel;
					end if;
				
				when first_wait_pixel =>
					wr_en1 									<= '0';
					if( i_pixel_valid_d1 = '1') then 
						state_fill							<= first_line_wr;
					end if;
				
				when first_line_wr =>
					wr_en1 									<= '1';
					wr_data1 								<= i_pixel_data_d2 ;
					if( i_pixel_valid_d1 = '0') then 
						state_fill							<= first_wait_pixel;
					end if;
				
				when wait_pixel =>
					wr_en1 									<= '0';
					if( SkipToIdle = '1') then
						state_fill							<= IDLE;
					
					elsif( i_pixel_valid_d1 = '1') then 
						state_fill							<= first_line_wr;	
					end if;
					
				when fill_fifo =>
					wr_en1 									<= '1';
					wr_data1 								<= i_pixel_data_d2 ;
					if( i_pixel_valid_d1 = '0') then 
						state_fill							<= wait_pixel;
					end if;
				
				when others =>
					state_fill								<= INITIALIZATION;
				
			end case;
		end if;
	end process fill_fifo_pro;
END ARCHITECTURE arch;