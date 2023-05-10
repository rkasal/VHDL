library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_top is
end tb_top;

architecture Behavioral of tb_top is

    constant c_clkperiod    : time := 10 ns;

    constant c_baud115200_p : time := 8.68 us;
    constant c_baud1M_p     : time := 1.00 us;

    constant c_baud115200   : integer :=115200;
    constant c_baud1M       : integer := 1000000;

    constant c_W_1_1        : std_logic_vector (9 downto 0) := '1' & x"AB" & '0';
    constant c_W_1_2        : std_logic_vector (9 downto 0) := '1' & x"CD" & '0';
    constant c_W_1_3        : std_logic_vector (9 downto 0) := '1' & x"11" & '0';
    constant c_W_1_4        : std_logic_vector (9 downto 0) := '1' & x"03" & '0';
    constant c_W_1_5        : std_logic_vector (9 downto 0) := '1' & x"67" & '0';
    constant c_W_1_6        : std_logic_vector (9 downto 0) := '1' & x"F3" & '0';

    constant c_W_2_1        : std_logic_vector (9 downto 0) := '1' & x"AB" & '0';
    constant c_W_2_2        : std_logic_vector (9 downto 0) := '1' & x"CD" & '0';
    constant c_W_2_3        : std_logic_vector (9 downto 0) := '1' & x"22" & '0';
    constant c_W_2_4        : std_logic_vector (9 downto 0) := '1' & x"03" & '0';
    constant c_W_2_5        : std_logic_vector (9 downto 0) := '1' & x"00" & '0';
    constant c_W_2_6        : std_logic_vector (9 downto 0) := '1' & x"9D" & '0';

    constant c_W_3_1        : std_logic_vector (9 downto 0) := '1' & x"AB" & '0';
    constant c_W_3_2        : std_logic_vector (9 downto 0) := '1' & x"CD" & '0';
    constant c_W_3_3        : std_logic_vector (9 downto 0) := '1' & x"22" & '0';
    constant c_W_3_4        : std_logic_vector (9 downto 0) := '1' & x"03" & '0';
    constant c_W_3_5        : std_logic_vector (9 downto 0) := '1' & x"34" & '0';
    constant c_W_3_6        : std_logic_vector (9 downto 0) := '1' & x"F3" & '0';



    signal clk : std_logic :='0';
    signal rx_d : std_logic :='1';
    signal tx_d : std_logic :='0';


    component top is
        generic
        (
            c_clkfreq		: integer := 100_000_000;
			c_baudrate		: integer := 115_200;
			c_stopbit		: integer := 2;
			
			RAM_WIDTH 		: integer 	:= 8;				
			RAM_DEPTH 		: integer 	:= 128;				
			RAM_PERFORMANCE : string 	:= "LOW_LATENCY" 
        );
        Port
        (
			clk      		: in std_logic;
			rx_i			: in std_logic;
			tx_o			: out std_logic
        );
    end component top; 
begin
	-----DUT
    dut : top
        generic map
        (
            c_clkfreq         =>  100000000,
            c_baudrate        =>  c_baud115200
			 
        )
        Port map
        (
            clk         	=>  clk,
            rx_i  	     	=>  rx_d,
            tx_o  	     	=>  tx_d
        );
    -----------------------------------------------------------
    -- Clocks and Reset
    -----------------------------------------------------------
    CLK_GEN : process
    begin
        clk <= '1';
        wait for c_clkperiod / 2.0 ;
        clk <= '0';
        wait for c_clkperiod / 2.0 ;
    end process CLK_GEN;

    P_STIMULI : process
    begin

        wait for 5*c_baud115200_p;
        ------------------------------------------------------------------------
            for i in 0 to 9 loop
                rx_d <= c_W_1_1(i);
                wait for c_baud115200_p;
            end loop;
            rx_d <= '1';
            wait for c_baud115200_p;
            --
            for i in 0 to 9 loop
                rx_d <= c_W_1_2(i);
                wait for c_baud115200_p;
            end loop;
            rx_d <= '1';
            wait for c_baud115200_p;
            --
            for i in 0 to 9 loop
                rx_d <= c_W_1_3(i);
                wait for c_baud115200_p;
            end loop;
            rx_d <= '1';
            wait for c_baud115200_p;
            --
            for i in 0 to 9 loop
                rx_d <= c_W_1_4(i);
                wait for c_baud115200_p;
            end loop;
            rx_d <= '1';
            wait for c_baud115200_p;
            --
            for i in 0 to 9 loop
                rx_d <= c_W_1_5(i);
                wait for c_baud115200_p;
            end loop;
            rx_d <= '1';
            wait for c_baud115200_p;
            --
            for i in 0 to 9 loop
                rx_d <= c_W_1_6(i);
                wait for c_baud115200_p;
            end loop;
            rx_d <= '1';
            wait for 1ms;
        --------------------------------------------------------------------------------
            for i in 0 to 9 loop
                rx_d <= c_W_2_1(i);
                wait for c_baud115200_p;
            end loop;
            rx_d <= '1';
            wait for c_baud115200_p;
            --
            for i in 0 to 9 loop
                rx_d <= c_W_2_2(i);
                wait for c_baud115200_p;
            end loop;
            rx_d <= '1';
            wait for c_baud115200_p;
            --
            for i in 0 to 9 loop
                rx_d <= c_W_2_3(i);
                wait for c_baud115200_p;
            end loop;
            rx_d <= '1';
            wait for c_baud115200_p;
            --
            for i in 0 to 9 loop
                rx_d <= c_W_2_4(i);
                wait for c_baud115200_p;
            end loop;
            rx_d <= '1';
            wait for c_baud115200_p;
            --
            for i in 0 to 9 loop
                rx_d <= c_W_2_5(i);
                wait for c_baud115200_p;
            end loop;
            rx_d <= '1';
            wait for c_baud115200_p;
            --
            for i in 0 to 9 loop
                rx_d <= c_W_2_6(i);
                wait for c_baud115200_p;
            end loop;
            rx_d <= '1';
            wait for 1ms;
        --------------------------------------------------------------------------------
            for i in 0 to 9 loop
                rx_d <= c_W_3_1(i);
                wait for c_baud115200_p;
            end loop;
            rx_d <= '1';
            wait for c_baud115200_p;
            --
            for i in 0 to 9 loop
                rx_d <= c_W_3_2(i);
                wait for c_baud115200_p;
            end loop;
            rx_d <= '1';
            wait for c_baud115200_p;
            --
            for i in 0 to 9 loop
                rx_d <= c_W_3_3(i);
                wait for c_baud115200_p;
            end loop;
            rx_d <= '1';
            wait for c_baud115200_p;
            --
            for i in 0 to 9 loop
                rx_d <= c_W_3_4(i);
                wait for c_baud115200_p;
            end loop;
            rx_d <= '1';
            wait for c_baud115200_p;
            --
            for i in 0 to 9 loop
                rx_d <= c_W_3_5(i);
                wait for c_baud115200_p;
            end loop;
            rx_d <= '1';
            wait for c_baud115200_p;
            --
            for i in 0 to 9 loop
                rx_d <= c_W_3_6(i);
                wait for c_baud115200_p;
            end loop;
            rx_d <= '1';
            wait for 1ms;
            
        --
		
		assert false
		report "SIM DOWN";
				
    end process P_STIMULI;

    

end Behavioral;
