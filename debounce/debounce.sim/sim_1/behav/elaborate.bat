@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.1\\bin
call %xv_path%/xelab  -wto 722874d7003e41ec904cc372642b2375 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot tb_debounce_behav xil_defaultlib.tb_debounce -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
