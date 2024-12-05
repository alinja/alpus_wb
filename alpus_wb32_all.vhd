-- alpus_wb32_all.vhd is generated by build.sh from individual files

-- alpus_wb32_pkg - package for 32-bit Wishbone bus signalling
--
-- slave select functions for easy slave selection, DOES NOT support addressing multiple slaves within one cycle
--

library ieee;
use ieee.std_logic_1164.all;

package alpus_wb32_pkg is
	constant alpus_wb_awid : integer := 32;

	-- Wishbone signals to slave direction
	type alpus_wb32_tos_t is record
		cyc    : std_logic; -- bus cycle
		we     : std_logic; -- wr cycle (rd_n)
		stb    : std_logic; -- transfer cycle, slave select
		adr    : std_logic_vector(alpus_wb_awid-1 downto 0); -- BYTE address
		data   : std_logic_vector(31 downto 0);
		sel    : std_logic_vector(3 downto 0); -- write enable
		--tgd    : std_logic;
		--tga    : std_logic;
		--tgc    : std_logic;
		--lock    : std_logic;
	end record alpus_wb32_tos_t;  
  
	-- Wishbone signals to master direction
	type alpus_wb32_tom_t is record
		data  : std_logic_vector(31 downto 0);
		stall : std_logic;
		ack    : std_logic; -- bus cycle ack
		--tgd    : std_logic;
		--err    : std_logic; -- bus cycle nack
		--rty    : std_logic; -- bus cycle ->retry
	end record alpus_wb32_tom_t;  

	type alpus_wb32_tos_array_t is array (integer range <>) of alpus_wb32_tos_t;
	type alpus_wb32_tom_array_t is array (integer range <>) of alpus_wb32_tom_t;
	
	-- Initial/idle values
	constant alpus_wb32_tos_init : alpus_wb32_tos_t := ('0', '0', '0', (others => '0'), (others => '0'), (others => '0'));
	constant alpus_wb32_tom_init : alpus_wb32_tom_t := ((others => '0'), '0', '0');

	-- Select slave by address and mask
	function alpus_wb32_slave_select_tos(
		adr  : std_logic_vector(alpus_wb_awid-1 downto 0);
		mask : std_logic_vector(alpus_wb_awid-1 downto 0);
		m : alpus_wb32_tos_t
	) return alpus_wb32_tos_t;

	function alpus_wb32_slave_select_tom(
		adr  : std_logic_vector(alpus_wb_awid-1 downto 0); --addr for A
		mask : std_logic_vector(alpus_wb_awid-1 downto 0);
		m : alpus_wb32_tos_t;
		a : alpus_wb32_tom_t;
		b : alpus_wb32_tom_t
	) return alpus_wb32_tom_t;

	component alpus_wb32_master_select is
	generic(
		NUM_MASTERS : integer := 2;
		MASTER_PIPELINED : std_logic_vector := "11"
	);
	port(
		clk : in std_logic;
		rst : in std_logic;
		master_side_tos : in alpus_wb32_tos_array_t(0 to NUM_MASTERS-1);
		master_side_tom : out alpus_wb32_tom_array_t(0 to NUM_MASTERS-1);
		slave_side_tos : out alpus_wb32_tos_t;
		slave_side_tom : in alpus_wb32_tom_t
	);
	end component;

	-- NOTE: Stall is often the critical path, but registering it causes wait states.
	-- NOTE: REG_STALL delays master side stb by one clk. Set also REG_REQUEST or REG_RESPONSE, or
	--       make otherwise sure that ack latency doesn't become negative.
	component alpus_wb32_pipeline_bridge is
	generic(
		MASTER_PIPELINED : std_logic := '1';
		SLAVE_PIPELINED : std_logic := '1';
		REG_REQUEST : std_logic := '0';
		REG_STALL : std_logic := '0';
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
	end component;

	-- Interface to standard mode (non-pipelined) components
	component alpus_wb32_stdmode_adapter is
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
	end component;

end package;

package body alpus_wb32_pkg is

	function alpus_wb32_slave_select_tos(
		adr  : std_logic_vector(alpus_wb_awid-1 downto 0);
		mask : std_logic_vector(alpus_wb_awid-1 downto 0);
		m : alpus_wb32_tos_t
	) return alpus_wb32_tos_t is
		variable RET : alpus_wb32_tos_t;
	begin
		if (adr and mask) = (m.adr and mask) then
			return m;
		else
			RET := m;
			RET.cyc := '0';
			RET.we := '0'; --not needed but prettier in simulation
			RET.stb := '0';
			return RET;
		end if;
	end function;

	function alpus_wb32_slave_select_tom(
		adr  : std_logic_vector(alpus_wb_awid-1 downto 0);
		mask : std_logic_vector(alpus_wb_awid-1 downto 0);
		m : alpus_wb32_tos_t;
		a : alpus_wb32_tom_t;
		b : alpus_wb32_tom_t
	) return alpus_wb32_tom_t is
	begin
		if (adr and mask) = (m.adr and mask) then
			return a;
		else
			return b;
		end if;
	end function;

end;
-- alpus_wb_master_select 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alpus_wb32_pkg.all;

entity alpus_wb32_master_select is
generic(
	NUM_MASTERS : integer := 2;
	MASTER_PIPELINED : std_logic_vector := "11"
);
port(
	clk : in std_logic;
	rst : in std_logic;

	master_side_tos : in alpus_wb32_tos_array_t(0 to NUM_MASTERS-1);
	master_side_tom : out alpus_wb32_tom_array_t(0 to NUM_MASTERS-1);
	slave_side_tos : out alpus_wb32_tos_t;
	slave_side_tom : in alpus_wb32_tom_t
);
end entity alpus_wb32_master_select;

architecture rtl of alpus_wb32_master_select is
	constant MASTER_PIPELINED_I : std_logic_vector(NUM_MASTERS-1 downto 0)
	                            := not std_logic_vector(resize(unsigned(not MASTER_PIPELINED), NUM_MASTERS));

	signal master_side_tos_i : alpus_wb32_tos_array_t(0 to NUM_MASTERS-1);
	signal master_side_tom_i : alpus_wb32_tom_array_t(0 to NUM_MASTERS-1);
	signal arbit_request : std_logic;
	signal arbit_candidate : integer range 0 to NUM_MASTERS-1;
	
	type arbit_fsm_t is (wait_for_request, wait_for_request_ending);
	signal arbit_fsm : arbit_fsm_t;
	signal arbit_request_held : std_logic;
	signal arbit_chosen : integer range 0 to NUM_MASTERS-1;

begin
	mag: for i in 0 to NUM_MASTERS-1 generate
		ma: alpus_wb32_stdmode_adapter generic map (
			MASTER_PIPELINED => MASTER_PIPELINED_I(i)
		) port map (
			clk => clk,
			rst => rst,
			master_side_tos => master_side_tos(i),
			master_side_tom => master_side_tom(i),
			slave_side_tos => master_side_tos_i(i),
			slave_side_tom => master_side_tom_i(i)	);
	end generate;

	process(master_side_tos_i)
	begin
		arbit_request <= '0';
		arbit_candidate <= 0;
		-- priority arbiter TODO sequential round-robin
		for i in NUM_MASTERS-1 downto 0 loop
			if master_side_tos_i(i).cyc = '1' then
				arbit_request <= '1';
				arbit_candidate <= i;
			end if;
		end loop;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
		
			case arbit_fsm is
			when wait_for_request =>
				if arbit_request = '1' then
					arbit_chosen <= arbit_candidate;
					arbit_fsm <= wait_for_request_ending;
				end if;
			when others =>
				if master_side_tos_i(arbit_chosen).cyc = '0' then
					arbit_fsm <= wait_for_request;
				end if;
			end case;
			
			if rst = '1' then
				arbit_fsm <= wait_for_request;
			end if;
		end if;
	end process;
	
	process(master_side_tos_i, slave_side_tom, arbit_candidate, arbit_chosen, arbit_fsm)
		variable arbit_chosen_v : integer range 0 to NUM_MASTERS-1;
	begin
		
		if arbit_fsm = wait_for_request_ending then
			arbit_chosen_v := arbit_chosen;
		else
			arbit_chosen_v := arbit_candidate;
		end if;

		slave_side_tos <= master_side_tos_i(arbit_chosen_v);
		if arbit_fsm = wait_for_request_ending and master_side_tos_i(arbit_chosen_v).cyc = '0' then
			slave_side_tos.cyc <= '0';
		end if;

		for i in 0 to NUM_MASTERS-1 loop
			if i = arbit_chosen_v then
				master_side_tom_i(i) <= slave_side_tom;
			else
				master_side_tom_i(i) <= alpus_wb32_tom_init;
				master_side_tom_i(i).stall <= '1';
			end if;
			master_side_tom_i(i).data <= slave_side_tom.data; -- save logic: no clear data
		end loop;

	end process;

end;-- alpus_wb_pipeline_bridge - Unbuffered pipeline bridge
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