-- Copyright (C) 2017  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 17.1.0 Build 590 10/25/2017 SJ Lite Edition"
-- CREATED		"Sun Dec 22 18:18:32 2019"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY Histogram_Calculation_Top IS 
	PORT
	(
		clk :  IN  STD_LOGIC;
		rstn :  IN  STD_LOGIC;
		hist_valid :  OUT  STD_LOGIC;
		hist_pixel_data :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		hist_pixel_data_value :  OUT  STD_LOGIC_VECTOR(19 DOWNTO 0)
	);
END Histogram_Calculation_Top;

ARCHITECTURE bdf_type OF Histogram_Calculation_Top IS 

COMPONENT histogram_calculator
	PORT(clk : IN STD_LOGIC;
		 rstn : IN STD_LOGIC;
		 active_frame : IN STD_LOGIC;
		 pixel_valid : IN STD_LOGIC;
		 pixel_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 rd_data : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
		 wr_en : OUT STD_LOGIC;
		 rd_en : OUT STD_LOGIC;
		 hist_valid : OUT STD_LOGIC;
		 hist_pixel_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 hist_pixel_data_value : OUT STD_LOGIC_VECTOR(19 DOWNTO 0);
		 rd_add : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 wr_add : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 wr_data : OUT STD_LOGIC_VECTOR(19 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ram_256x20
	PORT(clk : IN STD_LOGIC;
		 rstn : IN STD_LOGIC;
		 wr_en : IN STD_LOGIC;
		 rd_en : IN STD_LOGIC;
		 rd_add : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 wr_add : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 wr_data : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
		 rd_data : OUT STD_LOGIC_VECTOR(19 DOWNTO 0)
	);
END COMPONENT;

COMPONENT video_generator
GENERIC (delay_valid : INTEGER;
			FrameToLineTime : INTEGER;
			LINE_NUMBER : INTEGER;
			LineToFrameTime : INTEGER;
			LineToLineTime : INTEGER;
			PassiveFrameTime : INTEGER;
			PIXEL_NUMBER : INTEGER
			);
	PORT(clk : IN STD_LOGIC;
		 rstn : IN STD_LOGIC;
		 active_frame : OUT STD_LOGIC;
		 pixel_valid : OUT STD_LOGIC;
		 pixel_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	active_frame :  STD_LOGIC;
SIGNAL	pixel_data :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	pixel_valid :  STD_LOGIC;
SIGNAL	rd_add :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	rd_data :  STD_LOGIC_VECTOR(19 DOWNTO 0);
SIGNAL	rd_en :  STD_LOGIC;
SIGNAL	wr_add :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	wr_data :  STD_LOGIC_VECTOR(19 DOWNTO 0);
SIGNAL	wr_en :  STD_LOGIC;


BEGIN 



b2v_inst : histogram_calculator
PORT MAP(clk => clk,
		 rstn => rstn,
		 active_frame => active_frame,
		 pixel_valid => pixel_valid,
		 pixel_data => pixel_data,
		 rd_data => rd_data,
		 wr_en => wr_en,
		 rd_en => rd_en,
		 hist_valid => hist_valid,
		 hist_pixel_data => hist_pixel_data,
		 hist_pixel_data_value => hist_pixel_data_value,
		 rd_add => rd_add,
		 wr_add => wr_add,
		 wr_data => wr_data);


b2v_inst1 : ram_256x20
PORT MAP(clk => clk,
		 rstn => rstn,
		 wr_en => wr_en,
		 rd_en => rd_en,
		 rd_add => rd_add,
		 wr_add => wr_add,
		 wr_data => wr_data,
		 rd_data => rd_data);


b2v_inst2 : video_generator
GENERIC MAP(delay_valid => 100,
			FrameToLineTime => 512,
			LINE_NUMBER => 512,
			LineToFrameTime => 512,
			LineToLineTime => 100,
			PassiveFrameTime => 1620196,
			PIXEL_NUMBER => 640
			)
PORT MAP(clk => clk,
		 rstn => rstn,
		 active_frame => active_frame,
		 pixel_valid => pixel_valid,
		 pixel_data => pixel_data);


END bdf_type;