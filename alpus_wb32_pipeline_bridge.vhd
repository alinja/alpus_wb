-- alpus_wb_pipeline_bridge 
--
-- Unbuffered pipeline bridge. Stall is often the critical path, but registering it causes wait states.
-- 1. Keep master stalled by default
-- 2. Whenever master has stb, give unregistered stb to slave
-- 3. If slave was not stalled on clock edge, give registered stall='0' tp master
-- 4. Master can give another stb
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alpus_wb32_pkg.all;

entity alpus_wb32_pipeline_bridge is
generic(
	REG_REQUEST : std_logic := '0';
	REG_STALL : std_logic := '1';
	REG_RESPONSE : std_logic := '0'
);
port(
	clk : in std_logic;
	rst : in std_logic;

	master_side_tos : in alpus_wb32_tos_t;
	master_side_tom : out alpus_wb32_tom_t;
	slave_side_tos : out alpus_wb32_tos_t;
	slave_side_tom : in alpus_wb32_tom_t
);
end entity alpus_wb32_pipeline_bridge;

architecture rtl of alpus_wb32_pipeline_bridge is
	
	signal slave_side_tos_i : alpus_wb32_tos_t;
	signal master_side_tom_i : alpus_wb32_tom_t;

	type request_fsm_t is (idle, request);
	signal request_fsm : request_fsm_t;

	type stall_fsm_t is (stall_master, unstall_master, request);
	signal stall_fsm : stall_fsm_t;

begin
	-- TODO: either REG_REQUEST or REG_RESPONSE should be active when REG_STALL = '1' to avoid zero or less ack latency

	--
	-- Request direction registering
	--
	process(clk, master_side_tos, master_side_tom_i, request_fsm)
	begin
		if REG_REQUEST = '0' then
			slave_side_tos_i <= master_side_tos;
		end if;		

		if rising_edge(clk) then
			if REG_REQUEST = '1' then
				case request_fsm is
				when idle =>
					if master_side_tos.cyc = '1' then -- and stb?
						slave_side_tos_i <= master_side_tos;
						request_fsm <= request;
					else
						slave_side_tos_i <= alpus_wb32_tos_init;
					end if;
				when others =>
					if master_side_tos.cyc = '1' then
						if master_side_tom_i.stall = '0' then
							slave_side_tos_i <= master_side_tos;
						end if;
					else
						slave_side_tos_i <= alpus_wb32_tos_init;
						request_fsm <= idle;
					end if;
				end case;
			end if;

			if rst = '1' then
				request_fsm <= idle;
			end if;
		end if; -- clk

		master_side_tom <= master_side_tom_i;
		if REG_REQUEST = '1' then
			if request_fsm = idle then
				master_side_tom.stall <= '0';
			else
				master_side_tom.stall <= master_side_tom_i.stall;
			end if;
		else
			master_side_tom.stall <= master_side_tom_i.stall;
		end if;
	end process;

	--
	-- Response/Stall direction registering
	--
	process(clk, slave_side_tos_i, slave_side_tom, stall_fsm)
	begin
		if REG_STALL = '1' then
			slave_side_tos <= slave_side_tos_i;
			if stall_fsm = unstall_master then
				slave_side_tos.stb <= '0';
			end if;
		else
			slave_side_tos <= slave_side_tos_i;
		end if;

		if rising_edge(clk) then
			if REG_STALL = '1' then
				case stall_fsm is
				when stall_master =>
					if slave_side_tos_i.cyc = '1' and slave_side_tos_i.stb = '1' and slave_side_tom.stall = '0' then
						master_side_tom_i.stall <= '0';
						stall_fsm <= unstall_master;
					else
						master_side_tom_i.stall <= '1';
					end if;
				when others =>
					master_side_tom_i.stall <= '1';
					stall_fsm <= stall_master;
				end case;
			end if;

			if REG_RESPONSE = '1' then
				master_side_tom_i.data <= slave_side_tom.data;
				master_side_tom_i.ack <= slave_side_tom.ack;
			end if;

			if rst = '1' then
				stall_fsm <= stall_master;
			end if;
		end if; -- clk

		if REG_RESPONSE = '0' then
			master_side_tom_i.data <= slave_side_tom.data;
			master_side_tom_i.ack <= slave_side_tom.ack;
		end if;
		if REG_STALL = '0' then
			master_side_tom_i.stall <= slave_side_tom.stall;
		end if;
	end process;
end;