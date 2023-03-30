---------------------------------------------------
--------------- RAMAZAN KASAL ---------------------
---------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all; 
LIBRARY work;
ENTITY uart_top IS 
	PORT
	(
		clk  :  IN  STD_LOGIC;
		rstn :  IN  STD_LOGIC;
		button1 :  IN  STD_LOGIC;
		uart_rx :  IN  STD_LOGIC;
		uart_tx :  OUT  STD_LOGIC;
		led0 :  OUT  STD_LOGIC;
		led1 :  OUT  STD_LOGIC;
		led2 :  OUT  STD_LOGIC;
		led3 :  OUT  STD_LOGIC;
		led4 :  OUT  STD_LOGIC;
		led5 :  OUT  STD_LOGIC;
		led6 :  OUT  STD_LOGIC;
		led7 :  OUT  STD_LOGIC
	);
END uart_top;

ARCHITECTURE bdf_type OF uart_top IS 

COMPONENT uart_controller
	PORT(clk : IN STD_LOGIC;
		 rstn : IN STD_LOGIC;
		 uart_done : IN STD_LOGIC;
		 button1 : IN STD_LOGIC;
		 rx_ready : IN STD_LOGIC;
		 uart_start : OUT STD_LOGIC;
		 uart_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT uart_tx_b
	PORT(clk : IN STD_LOGIC;
		 rstn : IN STD_LOGIC;
		 uart_start : IN STD_LOGIC;
		 uart_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 uart_done : OUT STD_LOGIC;
		 uart_tx : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT uart_rx_b
	PORT(clk : IN STD_LOGIC;
		 rstn : IN STD_LOGIC;
		 rx_data : IN STD_LOGIC;
		 rx_ready : OUT STD_LOGIC;
		 led0 : OUT STD_LOGIC;
		 led1 : OUT STD_LOGIC;
		 led2 : OUT STD_LOGIC;
		 led3 : OUT STD_LOGIC;
		 led4 : OUT STD_LOGIC;
		 led5 : OUT STD_LOGIC;
		 led6 : OUT STD_LOGIC;
		 led7 : OUT STD_LOGIC
	);
END COMPONENT;

SIGNAL	rx_data :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	rx_ready :  STD_LOGIC;
SIGNAL	uart_data :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	uart_done :  STD_LOGIC;
SIGNAL	uart_start :  STD_LOGIC;

BEGIN 

b2v_inst : uart_controller
PORT MAP(clk => clk,
		 rstn => rstn,
		 uart_done => uart_done,
		 button1 => button1,
		 rx_ready => rx_ready,
		 uart_start => uart_start,
		 uart_data => uart_data);

b2v_inst1 : uart_tx_b
PORT MAP(clk => clk,
		 rstn => rstn,
		 uart_start => uart_start,
		 uart_data => uart_data,
		 uart_done => uart_done,
		 uart_tx => uart_tx);

b2v_inst2 : uart_rx_b
PORT MAP(clk => clk,
		 rstn => rstn,
		 rx_data => uart_rx,
		 rx_ready => rx_ready,
		 led0 => led0,
		 led1 => led1,
		 led2 => led2,
		 led3 => led3,
		 led4 => led4,
		 led5 => led5,
		 led6 => led6,
		 led7 => led7);

END bdf_type;