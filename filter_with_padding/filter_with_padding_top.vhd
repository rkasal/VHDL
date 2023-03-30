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
-- CREATED		"Mon Dec 30 09:33:32 2019"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY filter_with_padding_top IS 
	PORT
	(
		clk :  IN  STD_LOGIC;
		rstn :  IN  STD_LOGIC;
		active_frame_o :  OUT  STD_LOGIC;
		pixel_valid_o :  OUT  STD_LOGIC;
		pixel_data_o :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END filter_with_padding_top;

ARCHITECTURE bdf_type OF filter_with_padding_top IS 

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

COMPONENT hist_process
GENERIC (ActiveFrameFtime : INTEGER;
			ActiveFrameRtime : INTEGER;
			Line_Number : INTEGER;
			Pixel_Number : INTEGER
			);
	PORT(clk : IN STD_LOGIC;
		 rstn : IN STD_LOGIC;
		 active_frame : IN STD_LOGIC;
		 pixel_valid : IN STD_LOGIC;
		 almost_full1 : IN STD_LOGIC;
		 empty1 : IN STD_LOGIC;
		 almost_full2 : IN STD_LOGIC;
		 empty2 : IN STD_LOGIC;
		 pixel_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 rd_data1 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 rd_data2 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 rd_en1 : OUT STD_LOGIC;
		 rd_en2 : OUT STD_LOGIC;
		 wr_en1 : OUT STD_LOGIC;
		 wr_en2 : OUT STD_LOGIC;
		 active_frame_o : OUT STD_LOGIC;
		 pixel_valid_o : OUT STD_LOGIC;
		 pixel_data_o : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 wr_data1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 wr_data2 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT fifo_pad
	PORT(clock : IN STD_LOGIC;
		 rdreq : IN STD_LOGIC;
		 wrreq : IN STD_LOGIC;
		 data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT fifo_hist
	PORT(clock : IN STD_LOGIC;
		 rdreq : IN STD_LOGIC;
		 wrreq : IN STD_LOGIC;
		 data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 almost_full : OUT STD_LOGIC;
		 empty : OUT STD_LOGIC;
		 q : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	active_frame :  STD_LOGIC;
SIGNAL	almost_full1 :  STD_LOGIC;
SIGNAL	almost_full2 :  STD_LOGIC;
SIGNAL	empty1 :  STD_LOGIC;
SIGNAL	empty2 :  STD_LOGIC;
SIGNAL	i_active_frame :  STD_LOGIC;
SIGNAL	i_pixel_data :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	i_pixel_valid :  STD_LOGIC;
SIGNAL	pixel_data :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	pixel_valid :  STD_LOGIC;
SIGNAL	rd_data1 :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	rd_data2 :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	rd_data_p :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	rd_en1 :  STD_LOGIC;
SIGNAL	rd_en2 :  STD_LOGIC;
SIGNAL	rd_en_p :  STD_LOGIC;
SIGNAL	wr_data1 :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	wr_data2 :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	wr_data_p :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	wr_en1 :  STD_LOGIC;
SIGNAL	wr_en2 :  STD_LOGIC;
SIGNAL	wr_en_p :  STD_LOGIC;


BEGIN 



b2v_inst : video_generator
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
		 active_frame => i_active_frame,
		 pixel_valid => i_pixel_valid,
		 pixel_data => i_pixel_data);


b2v_inst11 : video_pad
GENERIC MAP(LINE_NUMBER => 512,
			LineToFrameTime => 512,
			LineToLineTime => 100,
			PassiveFrameTime => 1620196,
			PIXEL_NUMBER => 640
			)
PORT MAP(clk => clk,
		 rstn => rstn,
		 i_active_frame => i_active_frame,
		 i_pixel_valid => i_pixel_valid,
		 i_pixel_data => i_pixel_data,
		 rd_data1 => rd_data_p,
		 rd_en1 => rd_en_p,
		 wr_en1 => wr_en_p,
		 o_active_frame => active_frame,
		 o_pixel_valid => pixel_valid,
		 o_pixel_data => pixel_data,
		 wr_data1 => wr_data_p);


b2v_inst3 : hist_process
GENERIC MAP(ActiveFrameFtime => 512,
			ActiveFrameRtime => 740,
			Line_Number => 512,
			Pixel_Number => 640
			)
PORT MAP(clk => clk,
		 rstn => rstn,
		 active_frame => active_frame,
		 pixel_valid => pixel_valid,
		 almost_full1 => almost_full1,
		 empty1 => empty1,
		 almost_full2 => almost_full2,
		 empty2 => empty2,
		 pixel_data => pixel_data,
		 rd_data1 => rd_data1,
		 rd_data2 => rd_data2,
		 rd_en1 => rd_en1,
		 rd_en2 => rd_en2,
		 wr_en1 => wr_en1,
		 wr_en2 => wr_en2,
		 active_frame_o => active_frame_o,
		 pixel_valid_o => pixel_valid_o,
		 pixel_data_o => pixel_data_o,
		 wr_data1 => wr_data1,
		 wr_data2 => wr_data2);


b2v_inst5 : fifo_pad
PORT MAP(clock => clk,
		 rdreq => rd_en_p,
		 wrreq => wr_en_p,
		 data => wr_data_p,
		 q => rd_data_p);


b2v_inst6 : fifo_hist
PORT MAP(clock => clk,
		 rdreq => rd_en1,
		 wrreq => wr_en1,
		 data => wr_data1,
		 almost_full => almost_full1,
		 empty => empty1,
		 q => rd_data1);


b2v_inst7 : fifo_hist
PORT MAP(clock => clk,
		 rdreq => rd_en2,
		 wrreq => wr_en2,
		 data => wr_data2,
		 almost_full => almost_full2,
		 empty => empty2,
		 q => rd_data2);


END bdf_type;