-- alpus_wb_pipeline_bridge - Unbuffered pipeline bridge
--
--
-- Request registering:
-- 1. Idle: take new request to slave side (master always unstalled)
-- 2. Request: hold slave side request until unstall (current slave side transfer and next master side transfer are stalled)
--  a. If no new request (stb) -> back to Idle state
--  b. If new request (stb) take new request to slave side and continue in Request state
--              ____                 __________________
-- m.stb    ___/ 0  \_______________/ 1   2    3    3  \_______
--                   ____                     ____
-- m.stall  ________/    \___________________/    \____________
--
--                   _________           ___________________
-- s.stb    ________/ 0    0  \_________/ 1    2    2    3  \__
--                   ____                     ____
-- s.stall  XXXXXXXX/    \____/XXXXXXXXX\____/    \_________/XX
--
--
-- Stall registering: Stall is often on the critical path, but registering it causes wait states.
-- 1. Stall_master: keep master stalled by default
--    a. Whenever master has a request active (stb), unregistered request (stb/d/a) flows thru to slave
--    b. After slave transfer happens (stall='0'), give registered stall='0' to master and stall slave
-- 2. Stall_slave: master is released from stall state, Slave is stalled (stb='0') for one cycle. Return to Stall_master state
-- 3. Master can start new request on next clock cycle
--              ______________      _______________________________________
-- m.stb    ___/ 0    0    0  \____/ 1    1    2    2    3    3    3    3  \__
--          _____________           ____      ____      ______________      __
-- m.stall            W  \_________/ W  \____/ W  \____/           W  \____/
--
--              _________           ____      ____      ______________
-- s.stb    ___/ 0    0  \_W_______/ 1  \_W__/ 2  \_W__/ 3    3    3  \_W_____
--              ____                                    _________
-- s.stall  XXX/    \____/XXXXXXXXX\____/XXXX\____/XXXX/         \____/XXXXXXX
--
--
-- Response registering is a simple pipeline stage.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alpus_wb32_pkg.all;

entity alpus_wb32_pipeline_bridge is
generic(
	MASTER_PIPELINED : std_logic := '1';
	SLAVE_PIPELINED : std_logic := '1';
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
	
	signal master_side_tos_i : alpus_wb32_tos_t;
	signal master_side_tom_i : alpus_wb32_tom_t;

	signal middle_tos_i : alpus_wb32_tos_t;
	signal middle_tom_i : alpus_wb32_tom_t;

	type request_fsm_t is (idle, request);
	signal request_fsm : request_fsm_t;

	type stall_fsm_t is (stall_master, stall_slave);
	signal stall_fsm : stall_fsm_t;

	signal slave_side_tos_i : alpus_wb32_tos_t;
	signal slave_side_tom_i : alpus_wb32_tom_t;

begin
	--
	-- Provide option for std mode master
	--
	msta: alpus_wb32_stdmode_adapter generic map (
		MASTER_PIPELINED => MASTER_PIPELINED
	) port map (
		clk => clk,
		rst => rst,
		master_side_tos => master_side_tos,
		master_side_tom => master_side_tom,
		slave_side_tos => master_side_tos_i,
		slave_side_tom => master_side_tom_i	);

	--
	-- Request direction registering
	--
	process(clk, master_side_tos_i, middle_tom_i, request_fsm)
	begin
		if REG_REQUEST = '0' then
			middle_tos_i <= master_side_tos_i;
		end if;		

		if rising_edge(clk) then
			if REG_REQUEST = '1' then
				case request_fsm is
				when idle =>
					middle_tos_i <= master_side_tos_i;
					if master_side_tos_i.cyc = '1' and master_side_tos_i.stb = '1' then
						request_fsm <= request;
					end if;
				when others =>
					if middle_tom_i.stall = '0' then
						middle_tos_i <= master_side_tos_i;
						if master_side_tos_i.cyc = '1' and master_side_tos_i.stb = '1' then
							-- nothing
						else
							request_fsm <= idle;
						end if;
					end if;
				end case;
			end if;

			if rst = '1' then
				request_fsm <= idle;
			end if;
		end if; -- clk

		master_side_tom_i <= middle_tom_i;
		if REG_REQUEST = '1' then
			if request_fsm = idle then
				master_side_tom_i.stall <= '0';
			else
				master_side_tom_i.stall <= middle_tom_i.stall;
			end if;
		else
			master_side_tom_i.stall <= middle_tom_i.stall;
		end if;
	end process;

	--
	-- Response/Stall direction registering
	--
	process(clk, middle_tos_i, slave_side_tom_i, stall_fsm)
	begin
		if REG_STALL = '1' then
			slave_side_tos_i <= middle_tos_i;
			if stall_fsm = stall_slave then
				slave_side_tos_i.stb <= '0';
			end if;
		else
			slave_side_tos_i <= middle_tos_i;
		end if;

		if rising_edge(clk) then
			if REG_STALL = '1' then
				case stall_fsm is
				when stall_master =>
					if middle_tos_i.cyc = '1' and middle_tos_i.stb = '1' and slave_side_tom_i.stall = '0' then
						middle_tom_i.stall <= '0';
						stall_fsm <= stall_slave;
					else
						middle_tom_i.stall <= '1';
					end if;
				when others =>
					middle_tom_i.stall <= '1';
					stall_fsm <= stall_master;
				end case;
			end if;

			if REG_RESPONSE = '1' then
				middle_tom_i.data <= slave_side_tom_i.data;
				middle_tom_i.ack <= slave_side_tom_i.ack;
			end if;

			if rst = '1' then
				stall_fsm <= stall_master;
			end if;
		end if; -- clk

		if REG_RESPONSE = '0' then
			middle_tom_i.data <= slave_side_tom_i.data;
			middle_tom_i.ack <= slave_side_tom_i.ack;
		end if;
		if REG_STALL = '0' then
			middle_tom_i.stall <= slave_side_tom_i.stall;
		end if;
	end process;

	--
	-- Provide option for std mode slave
	--
	slva: alpus_wb32_stdmode_adapter generic map (
		SLAVE_PIPELINED => SLAVE_PIPELINED
	) port map (
		clk => clk,
		rst => rst,
		master_side_tos => slave_side_tos_i,
		master_side_tom => slave_side_tom_i,
		slave_side_tos => slave_side_tos,
		slave_side_tom => slave_side_tom );
end;
