-- alpus_wb32_stdmode_adapter 
--
-- Connects standard (non-pipelined) Wishbone components to pipelined Wishbone
--








library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alpus_wb32_pkg.all;

entity alpus_wb32_stdmode_adapter is
generic(
	MASTER_PIPELINED : std_logic := '1';
	SLAVE_PIPELINED : std_logic := '1'
);
port(
	clk : in std_logic;
	rst : in std_logic;
	master_side_tos : in alpus_wb32_tos_t;
	master_side_tom : out alpus_wb32_tom_t;
	slave_side_tos : out alpus_wb32_tos_t;
	slave_side_tom : in alpus_wb32_tom_t
);
end entity alpus_wb32_stdmode_adapter;

architecture rtl of alpus_wb32_stdmode_adapter is

	type request_fsm_t is (idle, request);
	signal request_fsm : request_fsm_t;

begin
	process(clk, master_side_tos, slave_side_tom, request_fsm)
	begin
		if MASTER_PIPELINED = SLAVE_PIPELINED then
			--
			-- Same modes can be connected directly
			--
			slave_side_tos <= master_side_tos;
			master_side_tom <= slave_side_tom;

		elsif MASTER_PIPELINED = '0' then
			--
			-- Std mode master
			--
			-- 1. Idle: pass request thru and wait for slave stall=0 for start of transfer
			-- 2. Request: pass request but force stb=0 until ack=1
			--             ___________________      _____________________________   
			-- m.stb    __/ 0    0    0    0  \____/ 1    1    2    3    3    3  \__
			--                            ____           _________           ____   
			-- m.ack    _________________/ 0  \_________/ 1    2  \_________/ 3  \__
			--
			--             _________                ____      _________               
			-- s.stb    __/ 0    0  \______________/ 1  \____/ 2    3  \____________
			--             ____                                                     
			-- s.stall  XX/    \____/XXXXXXXXXXXXXX\____/XXXX\_________/XXXXXXXXXXXX
			--                            ____           _________           ____   
			-- s.ack    _________________/ 0  \_________/ 1    2  \_________/ 3  \__

			if rising_edge(clk) then
				case request_fsm is
				when idle =>
					if master_side_tos.stb = '1' and slave_side_tom.stall = '0' and slave_side_tom.ack = '0' then 
						request_fsm <= request;
					end if;
				when others =>
					if slave_side_tom.ack = '1' then
						request_fsm <= idle;
					end if;
				end case;
				if rst = '1' then
					request_fsm <= idle;
				end if;
			end if;

			slave_side_tos <= master_side_tos;
			if request_fsm = idle then
				slave_side_tos.stb <= master_side_tos.stb;
			else
				slave_side_tos.stb <= '0';
			end if;
			master_side_tom <= slave_side_tom;

		elsif SLAVE_PIPELINED = '0' then
			--
			-- Std mode slave
			--
			-- Keep master stalled until ack=1. NOTE: ack latency is always 0.
			--
			--             ___________________      ______________   
			-- m.stb    __/ 0    0    0    0  \____/ 1    2    2  \__
			--             ______________                ____        
			-- m.stall  __/              \______________/    \_______
			--                            ____      ____      ____   
			-- m.ack    _________________/ 0  \____/ 1  \____/ 2  \__
			--
			--             ___________________      ______________               
			-- s.stb    __/ 0    0    0    0  \____/ 1    2    2  \__
			--                            ____      ____      ____   
			-- s.ack    _________________/ 0  \____/ 1  \____/ 2  \__

			slave_side_tos <= master_side_tos;
			master_side_tom <= slave_side_tom;
			if master_side_tos.cyc = '0' then --needed?
				master_side_tom.stall <= '0';
			else
				master_side_tom.stall <= not slave_side_tom.ack;
			end if;
			
		end if;
	end process;
end;