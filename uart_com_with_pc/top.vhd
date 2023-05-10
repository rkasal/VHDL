library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ram_pkg.all;
USE std.textio.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
generic ( 
c_clkfreq		: integer := 100_000_000;
c_baudrate		: integer := 115_200;
c_stopbit		: integer := 2;

RAM_WIDTH 		: integer 	:= 8;				
RAM_DEPTH 		: integer 	:= 128;				
RAM_PERFORMANCE : string 	:= "LOW_LATENCY"    

);
port (
clk      		: in std_logic;
rx_i			: in std_logic;
tx_o			: out std_logic
);
end top;

architecture Behavioral of top is
component block_ram is
generic(
RAM_WIDTH 		: integer 	:= 16;			
RAM_DEPTH 		: integer 	:= 128;			
RAM_PERFORMANCE : string 	:= "LOW_LATENCY" 
);
port( 
addra : in std_logic_vector((clogb2(RAM_DEPTH)-1) downto 0);
dina  : in std_logic_vector(RAM_WIDTH-1 downto 0);		  	
clka  : in std_logic;                       			  	
wea   : in std_logic;                       			  		
douta : out std_logic_vector(RAM_WIDTH-1 downto 0)   		
);
end component;

component uart_tx is
generic (
c_clkfreq		: integer := 100_000_000;
c_baudrate		: integer := 115_200;
c_stopbit		: integer := 2
);
port (
clk				: in std_logic;
din_i			: in std_logic_vector (7 downto 0);
tx_start_i		: in std_logic;
tx_o			: out std_logic;
tx_done_tick_o	: out std_logic
);
end component;

component uart_rx is
generic (
c_clkfreq		: integer := 100_000_000;
c_baudrate		: integer := 115_200
);
port (
clk				: in std_logic;
rx_i			: in std_logic;
dout_o			: out std_logic_vector (7 downto 0);
rx_done_tick_o	: out std_logic
);
end component;

signal dout_o 			: std_logic_vector(7 downto 0) := (others=>'0');
signal rx_done_tick_o 	: std_logic := '0';
signal din_i 			: std_logic_vector(7 downto 0) := (others=>'0');
signal tx_start_i	 	: std_logic := '0';
signal tx_done_tick_o 	: std_logic := '0';

--ram sinyals
signal addra            : std_logic_vector((clogb2(RAM_DEPTH)-1) downto 0);
signal dina             : std_logic_vector(RAM_WIDTH-1 downto 0);		  	
signal wea              : std_logic;                       			  	
signal douta            : std_logic_vector(RAM_WIDTH-1 downto 0) ;	

type states is (S_IDLE, S_WRITE, S_COMMAND, S_READ, S_TRANSMIT);
signal state : states := S_IDLE;

signal databuffer : std_logic_vector (6*8-1 downto 0) := (others => '0');
signal checksum   : std_logic_vector (7 downto 0) := (others => '0');
signal sumcntr		: integer range 0 to 7 := 0;
begin

P_RX : uart_rx  	
generic map(    	
c_clkfreq		=> c_clkfreq	,
c_baudrate		=> c_baudrate	   
)              	
port map(       	
clk				=> clk			,
rx_i			=> rx_i			,
dout_o			=> dout_o		,
rx_done_tick_o	=> rx_done_tick_o

);

P_TX : uart_tx 	
generic map(	
c_clkfreq		=> c_clkfreq	,
c_baudrate		=> c_baudrate	,
c_stopbit		=> c_stopbit	
)          
port map(       
clk				=> clk			,
din_i			=> din_i		,
tx_start_i		=> tx_start_i	,
tx_o			=> tx_o			,
tx_done_tick_o	=> tx_done_tick_o
);

P_RAM : block_ram 
generic map( 
RAM_WIDTH 			=> RAM_WIDTH 		,
RAM_DEPTH 			=> RAM_DEPTH 		,
RAM_PERFORMANCE 	=> RAM_PERFORMANCE 
)
port map (
addra 				=> addra 	      ,
dina  				=> dina  	      ,
clka  				=> clk  	      ,
wea   				=> wea   	  	  ,
douta  				=> douta  	 
);	
	


P_MAIN : process (clk) begin
if(rising_edge(clk)) then 

	case state is 
	
		when S_IDLE =>
			wea				<= '0';
			sumcntr						<= 0;
			
			if(rx_done_tick_o = '1') then 
			
				--bu blok gelen 8 bitleri toplayıp checksumı hesaplıyor. 
				databuffer(7 downto 0) 			<= dout_o;
				databuffer(6*8-1 downto 1*8) 	<= databuffer(5*8-1 downto 0);
				
			end if;	
			if(databuffer(6*8-1 downto 4*8) = x"ABCD" ) then
			
				if(checksum = databuffer(7 downto 0)) then 
					state						<= S_COMMAND;
					
				else
					checksum					<= checksum + dout_o;
				end if;			
				
			end if;
			
		when S_COMMAND =>
				
			checksum							<= (others => '0');
								
			if(databuffer(4*8-1 downto 3*8) = x"11") then
			
				state 							<= S_WRITE;
				databuffer(4*8-1 downto 3*8)	<= x"33";
				
			elsif(databuffer(4*8-1 downto 3*8) = x"22" ) then
			
				state 							<= S_READ;	
				databuffer(4*8-1 downto 3*8)	<= x"44";
			else
			
				state 							<= S_IDLE;
				databuffer(5*8-1 downto 0)		<= (others => '0');
					
			end if;
		
		when S_WRITE =>
			
			wea									<= '1'; 			
			addra								<= databuffer(3*8-2 downto 2*8); 
			dina								<= databuffer(2*8-1 downto 1*8);		
			state 								<= S_TRANSMIT;
			sumcntr								<= 5;
			databuffer(1*8-1 downto 0)			<= databuffer(6*8-1 downto 5*8) + databuffer(5*8-1 downto 4*8) + 
												   databuffer(4*8-1 downto 3*8) + databuffer(3*8-1 downto 2*8) + 
												   databuffer(2*8-1 downto 1*8)	;
			tx_start_i 							<= '1';											
			din_i 								<= databuffer(6*8-1 downto 5*8);
			
		when S_READ =>
			
			wea							<= '0';
			addra						<= databuffer(3*8-2 downto 2*8);
			sumcntr						<= sumcntr + 1;
			
				if(sumcntr = 1) then
					
					databuffer(2*8-1 downto 1*8) 	<= douta;
					state 							<= S_TRANSMIT ;
					sumcntr							<= 5;
					databuffer(1*8-1 downto 0)		<= databuffer(6*8-1 downto 5*8) + databuffer(5*8-1 downto 4*8) + 
													   databuffer(4*8-1 downto 3*8) + databuffer(3*8-1 downto 2*8) + 
													   douta;
					tx_start_i 						<= '1';
					din_i 							<= databuffer(6*8-1 downto 5*8);	
				end if;		
				
		when S_TRANSMIT =>
			
			wea				<= '0';
			
			if(sumcntr = 0) then
								
				tx_start_i 						<= '0';
				
				if(tx_done_tick_o = '1' ) then
				
					checksum						<= (others => '0');
					databuffer(6*8-1 downto 0)		<= (others => '0');
					state							<= S_IDLE;
					
				end if;
				
				
			else						
				
				din_i 								<= databuffer(sumcntr*8-1 downto (sumcntr-1)*8);
				tx_start_i 							<= '1';
				
				if(tx_done_tick_o = '1' ) then
					
					sumcntr							<= sumcntr - 1;
					--checksum						<= checksum + databuffer(6*8-1 downto 5*8);
					--databuffer(6*8-1 downto 1*8) 	<= databuffer(5*8-1 downto 0);	
					--din_i 						<= databuffer(6*8-1 downto 5*8);
					
				end if;
			end if;			
			
	
	end case;
 




end if;

end process;



end Behavioral;
