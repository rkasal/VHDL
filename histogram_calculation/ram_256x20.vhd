LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all; --bu kütüphane bit türlerinin aritmetikleri için
ENTITY ram_256x20 IS
port (
	clk 	   : in std_logic;
	rstn 	   : in std_logic;
	
	wr_en 	: in std_logic;
	wr_add 	: in std_logic_vector(7 downto 0);
	wr_data  : in std_logic_vector(19 downto 0);
	
	rd_en 	: in std_logic;
	rd_add 	: in std_logic_vector(7 downto 0);
	rd_data  : out std_logic_vector(19 downto 0)
);
END ENTITY ram_256x20;

ARCHITECTURE arch OF ram_256x20 IS
	type ram is array (255 downto 0 ) of std_logic_vector(19 downto 0);
	signal ram_signal: ram;
BEGIN
	PROCESS (rstn,clk) 
	begin
		if rstn= '0' then--başlangıcımızda out rd_data mızı sıfırladık
			rd_data <= (others=>'0') ;
		elsif Rising_edge(clk) then          
			if wr_en = '1' then--yazma enable geldiğinde 
				ram_signal(TO_integer(unsigned(wr_add))) <= wr_data;
			end if;--yazma adresimize data mızı RAM a atadık
	
			if rd_en = '1' then --okuma enable geldiğinde
				rd_data <= ram_signal(TO_integer(unsigned(rd_add))) ;
			end if;--RAM adresimizden datamızı rd_data ya aldık
		end if;
	end process ;
END ARCHITECTURE arch;