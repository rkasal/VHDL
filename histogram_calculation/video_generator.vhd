LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
ENTITY video_generator IS
 generic ( 
  FrameToLineTime  : integer := 512; -- FtoL
  LineToFrameTime  : integer := 512; -- LtoF
  LineToLineTime   : integer := 100; -- LtoL
  PIXEL_NUMBER	    : integer := 640; -- PN
  LINE_NUMBER 	    : integer := 512; -- LN
  PassiveFrameTime : integer := 1620196;  -- should be calculated to get 25Hz video @50MHz clk 
  delay_valid      : integer := 100 --dışarıdan girdiğimiz videonun başlaması için keyfi değer. 
                                    --Bunu ileride enable alacağımız bir sistemiçin oluşturduk.
  --if lerimizin içinde, bu sayıları counter a eşit şartımızı sağlarken 1 çıkarmamızın sebebi counter'ımızın '0' a eşit olmasından dolayıdır.
  --counter'ımız 1 den başlatsak 1 çıkarmamıza gerek olmazdı. 
);

 port (
  clk 		   : in std_logic  ; 
  rstn 		   : in std_logic  ;
  
  active_frame : out std_logic ;
  pixel_valid  : out std_logic ; 
  pixel_data   : out std_logic_vector(7 downto 0)
);
END ENTITY video_generator;
ARCHITECTURE arch OF video_generator IS
TYPE state_type is (INITIALIZATION, FRAMETOLINE, PIXEL_ACTIVE, LINETOLINE, LINETOFRAME, PASSIVEFRAME);--PASSIVEFRAME 25Hz i yakalamamız için(40ms) hesapladığımız(PassiveFrameTime) değer.
SIGNAL state         : state_type;
SIGNAL counter       : std_logic_vector(21 downto 0);--bu sayıcı yı  clk sayarken kullanıyoruz onun için her state geçişlerin de stateden çıkmadan sıfırlıyoruz
SIGNAL counter_line  : std_logic_vector(10 downto 0);
SIGNAL counter_value : std_logic_vector(7 downto 0);
BEGIN
PROCESS (rstn,clk) 	
	BEGIN
	if rstn = '0' then
		 active_frame 							<= '0';
		 pixel_valid   							<= '0';
		 pixel_data   							<= (others => '0');
		 counter  								<= (others => '0');
		 counter_line							<= (others => '0');
		 state					  	   			<= INITIALIZATION;
		 counter                         		<= (others => '0');
		 counter_value							<= (others => '0');
	elsif rising_edge(clk) then	
		 case state is
			 when INITIALIZATION => --belirlediğimiz gecikme süresine göre(Delay_valid) 
				 active_frame 					<= '0';
				 pixel_valid   					<= '0';
				 counter                        <= counter + '1';	
				 if(counter = delay_valid - 1) then--bu süreyi kendimiz keyfi verdik
					 counter  					<= (others => '0');
					 state                      <= FRAMETOLINE;					 
				 end if;
			 
			 when FRAMETOLINE => 
				 counter						<= counter + '1';	
				 active_frame 					<= '1';		
				 if(counter = FrameToLineTime - 1) then
					 counter  					<= (others => '0');
					 state                      <= PIXEL_ACTIVE;			
				 end if;
			 
			 when LINETOLINE =>--burada active_frame ile işimiz yok. çünkü hiçbir şekilde active_frame LOW iken buraya gelmiyoruz.
				 counter						<= counter + '1';
				 pixel_valid   					<= '0';
				 if( counter = LineToLineTime - 1) then
					state                       <= PIXEL_ACTIVE;
					counter  					<= (others => '0');		
				 end if;		 
								  
			 when PIXEL_ACTIVE  => 
				 counter						<= counter + '1';				 
				 counter_value					<= counter_value + '1';				  
				 pixel_valid   					<= '1';
				 pixel_data					<= counter(7 downto 0);
				
				if( counter_value = 0) then
					pixel_data					<= x"00";
				elsif( counter_value = x"01") then
					pixel_data					<= x"01";
					counter_value				<= (others => '0');
				--elsif( counter_value = x"02") then
				--	pixel_data					<= x"02";
				--elsif( counter_value = x"03") then
				--	pixel_data					<= x"02";
				--elsif( counter_value = x"04") then
				--	pixel_data					<= x"02";
				--	counter_value				<= (others => '0');	
				--elsif( counter_value = x"05") then
				--	pixel_data					<= x"02";
				--elsif( counter_value = x"06") then
				--	pixel_data					<= x"03";
				--	counter_value				<= (others => '0');
			   end if;
				 
				 if( counter = PIXEL_NUMBER - 1 ) then 
					if (counter_line = LINE_NUMBER - 1 ) then--Line sayımız 512 olduğunda state miz LtoF ye gidecek.
						counter  				<= (others => '0');
						counter_value			<= (others => '0');
						counter_line			<= (others => '0');
						state                   <= LINETOFRAME;				
						
					else-- line sayımız 512 değilse  LINETOLINE a gidecek
						counter  				<= (others => '0');
						counter_value			<= (others => '0');
						state                   <= LINETOLINE;
						counter_line			<= counter_line + '1';
					end if;
				 end if;
							  
			 when LINETOFRAME =>
				 counter                        <= counter + '1';
				 pixel_valid   					<= '0';
				 
				 if ( counter = LineToFrameTime - 1) then 
					state                       <= PASSIVEFRAME;
					counter  					<= (others => '0');					
				 end if;
				 
			 when PASSIVEFRAME => --50 Hz yakalamak için bizim hesapladığımız süreyi bu statede elde ediyoruz.
				 counter                         <= counter + '1';
				 active_frame 					 <= '0';
				 if( counter = PassiveFrameTime - 1) then
					counter  					 <= (others => '0');
					state                        <= FRAMETOLINE;
				 end if;	
				 
			 when others =>   
				 state <= INITIALIZATION;
			 
		 end case;
   end if;
end process ;
END ARCHITECTURE arch;