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
-- CREATED		"Sat Jan 04 16:50:19 2020"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY video_pad_top IS 
	PORT
	(
		clk :  IN  STD_LOGIC;
		rstn :  IN  STD_LOGIC;
		o_active_frame :  OUT  STD_LOGIC;
		o_pixel_valid :  OUT  STD_LOGIC;
		o_pixel_data :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END video_pad_top;

ARCHITECTURE bdf_type OF video_pad_top IS 

COMPONENT video_pad
GENERIC (LINE_NUMBER : INTEGER;
			LineToFrameTime : INTEGER;
			LineToLineTime : INTEGER;
			PassiveFrameTime : INTEGER;
			PIXEL_NUMBER : INTEGER
			);
	PORT(clk : IN STD_LOGIC;
		 rstn : IN STD_LOGIC;
		 i_active_frame : IN STD_LOGIC;
		 i_pixel_valid : IN STD_LOGIC;
		 i_pixel_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 rd_data1 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 rd_en1 : OUT STD_LOGIC;
		 wr_en1 : OUT STD_LOGIC;
		 o_active_frame : OUT STD_LOGIC;
		 o_pixel_valid : OUT STD_LOGIC;
		 o_pixel_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 wr_data1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT fifo
	PORT(clock : IN STD_LOGIC;
		 rdreq : IN STD_LOGIC;
		 wrreq : IN STD_LOGIC;
		 data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 almost_full : OUT STD_LOGIC;
		 empty : OUT STD_LOGIC;
		 q : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
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
SIGNAL	almost_full1 :  STD_LOGIC;
SIGNAL	empty1 :  STD_LOGIC;
SIGNAL	pixel_data :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	pixel_valid :  STD_LOGIC;
SIGNAL	rd_data1 :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	rd_en1 :  STD_LOGIC;
SIGNAL	wr_data1 :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	wr_en1 :  STD_LOGIC;


BEGIN 



b2v_inst : video_pad
GENERIC MAP(LINE_NUMBER => 512,
			LineToFrameTime => 512,
			LineToLineTime => 100,
			PassiveFrameTime => 1620196,
			PIXEL_NUMBER => 640
			)
PORT MAP(clk => clk,
		 rstn => rstn,
		 i_active_frame => active_frame,
		 i_pixel_valid => pixel_valid,
		 i_pixel_data => pixel_data,
		 rd_data1 => rd_data1,
		 rd_en1 => rd_en1,
		 wr_en1 => wr_en1,
		 o_active_frame => o_active_frame,
		 o_pixel_valid => o_pixel_valid,
		 o_pixel_data => o_pixel_data,
		 wr_data1 => wr_data1);


b2v_inst1 : fifo
PORT MAP(clock => clk,
		 rdreq => rd_en1,
		 wrreq => wr_en1,
		 data => wr_data1,
		 q => rd_data1);


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