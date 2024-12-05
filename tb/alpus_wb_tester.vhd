-- alpus_wb_tester 
--
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alpus_wb32_pkg.all;

package alpus_wb_tester_pkg is
component alpus_wb_tester is
port(
	clk : in std_logic;
	rst : in std_logic;

	req : in std_logic;
	cmd : in integer range 0 to 64;
	addr : in std_logic_vector(15 downto 0);
	ack : out std_logic;

	req1 : in std_logic;
	cmd1 : in integer range 0 to 64;
	addr1 : in std_logic_vector(15 downto 0);
	ack1 : out std_logic;

	res_ok : out std_logic
);
end component;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alpus_wb32_pkg.all;
use work.alpus_wb_test_slave_pkg.all;
use work.alpus_wb_test_master_pkg.all;

entity alpus_wb_tester is
port(
	clk : in std_logic;
	rst : in std_logic;

	req : in std_logic;
	cmd : in integer range 0 to 64;
	addr : in std_logic_vector(15 downto 0);
	ack : out std_logic;

	req1 : in std_logic;
	cmd1 : in integer range 0 to 64;
	addr1 : in std_logic_vector(15 downto 0);
	ack1 : out std_logic;

	res_ok : out std_logic
);
end entity alpus_wb_tester;

architecture rtl of alpus_wb_tester is

	signal res_ok0 : std_logic;
	signal res_ok1 : std_logic;
	signal assert_fail0 : std_logic;
	signal assert_fail1 : std_logic;
	signal assert_fail2 : std_logic;
	signal assert_fail3 : std_logic;
	signal assert_fail4 : std_logic;
	signal assert_fail5 : std_logic;
	signal assert_fail : std_logic;
	
	signal master0_tos : alpus_wb32_tos_t;
	signal master0_tom : alpus_wb32_tom_t;
	signal master1_tos : alpus_wb32_tos_t;
	signal master1_tom : alpus_wb32_tom_t;
	signal master1pb_tos : alpus_wb32_tos_t;
	signal master1pb_tom : alpus_wb32_tom_t;
	signal master2_tos : alpus_wb32_tos_t;
	signal master2_tom : alpus_wb32_tom_t;
	signal master_commonpb_tos : alpus_wb32_tos_t;
	signal master_commonpb_tom : alpus_wb32_tom_t;
	signal master_common_tos : alpus_wb32_tos_t;
	signal master_common_tom : alpus_wb32_tom_t;
	signal slave0_tos : alpus_wb32_tos_t;
	signal slave0_tom : alpus_wb32_tom_t;
	signal slave1_tos : alpus_wb32_tos_t;
	signal slave1_tom : alpus_wb32_tom_t;
	signal slave2_tos : alpus_wb32_tos_t;
	signal slave2_tom : alpus_wb32_tom_t;
	signal slave2pb_tos : alpus_wb32_tos_t;
	signal slave2pb_tom : alpus_wb32_tom_t;
	signal slave3_tos : alpus_wb32_tos_t;
	signal slave3_tom : alpus_wb32_tom_t;
	signal slave3sa_tos : alpus_wb32_tos_t;
	signal slave3sa_tom : alpus_wb32_tom_t;
	signal slave4_tos : alpus_wb32_tos_t;
	signal slave4_tom : alpus_wb32_tom_t;
	signal slave5_tos : alpus_wb32_tos_t;
	signal slave5_tom : alpus_wb32_tom_t;

begin
	res_ok <= res_ok0 and res_ok1;
	assert_fail <= assert_fail0 or assert_fail1 or assert_fail2 or assert_fail3 or assert_fail4 or assert_fail5;

	master0: alpus_wb_test_master generic map (
		PIPELINED => '1'
	) port map (
		clk => clk,
		rst => rst,
		req => req,
		cmd => cmd,
		addr => addr,
		ack => ack,
		res_ok => res_ok0,
		wb_tos => master0_tos,
		wb_tom => master0_tom );

	master1: alpus_wb_test_master generic map (
		PIPELINED => '0'
	) port map (
		clk => clk,
		rst => rst,
		req => req1,
		cmd => cmd1,
		addr => addr1,
		ack => ack1,
		res_ok => res_ok1,
		wb_tos => master1pb_tos,
		wb_tom => master1pb_tom );

--	master2: alpus_wb_test_master port map (
--		clk => clk,
--		rst => rst,
--		req => req1,
--		cmd => cmd1,
--		addr => addr1,
--		ack => open,
--		res_ok => open,
--		wb_tos => master2_tos,
--		wb_tom => master2_tom );

	master1pb: alpus_wb32_pipeline_bridge generic map (
		MASTER_PIPELINED => '0',
		REG_REQUEST => '0',
		REG_STALL => '1',
		REG_RESPONSE => '1'
	) port map (
		clk => clk,
		rst => rst,
		master_side_tos => master1pb_tos,
		master_side_tom => master1pb_tom,
		slave_side_tos => master1_tos,
		slave_side_tom => master1_tom );

	master_sel: alpus_wb32_master_select generic map (
		NUM_MASTERS => 2,
		MASTER_PIPELINED => "11"
	) port map (
		clk => clk,
		rst => rst,
		master_side_tos(0) => master0_tos,
		master_side_tos(1) => master1_tos,
		--master_side_tos(2) => master2_tos,
		master_side_tom(0) => master0_tom,
		master_side_tom(1) => master1_tom,
		--master_side_tom(2) => master2_tom,
		slave_side_tos => master_commonpb_tos,
		slave_side_tom => master_commonpb_tom );

	common_pb: alpus_wb32_pipeline_bridge generic map (
		REG_REQUEST => '0',
		REG_STALL => '0',
		REG_RESPONSE => '0'
	) port map (
		clk => clk,
		rst => rst,
		master_side_tos => master_commonpb_tos,
		master_side_tom => master_commonpb_tom,
		slave_side_tos => master_common_tos,
		slave_side_tom => master_common_tom );

	-- slave select
	slave0_tos <= alpus_wb32_slave_select_tos(x"00000000", x"0000f000", master_common_tos);
	slave1_tos <= alpus_wb32_slave_select_tos(x"00001000", x"0000f000", master_common_tos);
	slave2_tos <= alpus_wb32_slave_select_tos(x"00002000", x"0000f000", master_common_tos);
	slave3_tos <= alpus_wb32_slave_select_tos(x"00003000", x"0000f000", master_common_tos);
	slave4_tos <= alpus_wb32_slave_select_tos(x"00004000", x"0000f000", master_common_tos);
	slave5_tos <= alpus_wb32_slave_select_tos(x"00005000", x"0000f000", master_common_tos);
	master_common_tom <= alpus_wb32_slave_select_tom(x"00000000", x"0000f000", master_common_tos, slave0_tom,
		           alpus_wb32_slave_select_tom(x"00001000", x"0000f000", master_common_tos, slave1_tom,
		           alpus_wb32_slave_select_tom(x"00002000", x"0000f000", master_common_tos, slave2_tom,
		           alpus_wb32_slave_select_tom(x"00003000", x"0000f000", master_common_tos, slave3_tom,
		           alpus_wb32_slave_select_tom(x"00004000", x"0000f000", master_common_tos, slave4_tom,
				   slave5_tom )))));

	-- fast low-latency slave
	slave0: alpus_wb_test_slave port map (
		clk => clk,
		rst => rst,
		wb_tos => slave0_tos,
		wb_tom => slave0_tom,
		assert_fail => assert_fail0	);

	-- stalling, long-latency slave
	slave1: alpus_wb_test_slave generic map (
		STALL_DURATION => 4,
		STALL_INVERTED => '1',
		LATENCY => 3
	) port map (
		clk => clk,
		rst => rst,
		wb_tos => slave1_tos,
		wb_tom => slave1_tom,
		assert_fail => assert_fail1	);

	-- slave behind a pipeline bridge
	slave2_pb: alpus_wb32_pipeline_bridge generic map (
		REG_REQUEST => '1',
		REG_STALL => '0',
		REG_RESPONSE => '0'
	) port map (
		clk => clk,
		rst => rst,
		master_side_tos => slave2_tos,
		master_side_tom => slave2_tom,
		slave_side_tos => slave2pb_tos,
		slave_side_tom => slave2pb_tom	);

	slave2: alpus_wb_test_slave generic map (
		STALL_DURATION => 2,
		STALL_INVERTED => '1',
		LATENCY => 2
	) port map (
		clk => clk,
		rst => rst,
		wb_tos => slave2pb_tos,
		wb_tom => slave2pb_tom,
		assert_fail => assert_fail2	);

	-- non-pipelined slave
	slave3_sa: alpus_wb32_stdmode_adapter generic map (
		SLAVE_PIPELINED => '0'
	) port map (
		clk => clk,
		rst => rst,
		master_side_tos => slave3_tos,
		master_side_tom => slave3_tom,
		slave_side_tos => slave3sa_tos,
		slave_side_tom => slave3sa_tom	);
	slave3: alpus_wb_test_slave generic map (
		PIPELINED => '0',
		LATENCY => 1
	) port map (
		clk => clk,
		rst => rst,
		wb_tos => slave3sa_tos,
		wb_tom => slave3sa_tom,
		assert_fail => assert_fail3	);

	-- shared slave
	slave4: alpus_wb_test_slave generic map (
		LATENCY => 1
	) port map (
		clk => clk,
		rst => rst,
		wb_tos => slave4_tos,
		wb_tom => slave4_tom,
		assert_fail => assert_fail4	);

	-- one more slave
	slave5: alpus_wb_test_slave generic map (
		LATENCY => 1
	) port map (
		clk => clk,
		rst => rst,
		wb_tos => slave5_tos,
		wb_tom => slave5_tom,
		assert_fail => assert_fail5	);

end;