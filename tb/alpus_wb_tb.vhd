-- alpus_wb_tb tesbench

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alpus_wb32_pkg.all;
use work.alpus_wb_tester_pkg.all;
--use work.alpus_wb_test_slave_pkg.all;
--use work.alpus_wb_test_master_pkg.all;
--use work.alpus_wb_pipeline_bridge_pkg.all;
--use work.alpus_wb_master_select_pkg.all;

entity alpus_wb_tb is
end entity alpus_wb_tb;

architecture tb of alpus_wb_tb is

	constant CLK_PERIOD : time := 10.0 ns;
	
	signal clk : std_logic := '0';
	signal rst : std_logic := '1';

	signal req : std_logic := '1';
	signal addr_ctr : std_logic_vector(15 downto 0) := x"0000";
	signal addr : std_logic_vector(15 downto 0);
	signal ack : std_logic := '1';
	signal cmd : integer;

	signal req1 : std_logic := '1';
	signal addr_ctr1 : std_logic_vector(15 downto 0) := x"0000";
	signal addr1 : std_logic_vector(15 downto 0);
	signal ack1 : std_logic := '1';
	signal cmd1 : integer;
	
	signal master0_tos : alpus_wb32_tos_t;
	signal master0_tom : alpus_wb32_tom_t;
	signal master1_tos : alpus_wb32_tos_t;
	signal master1_tom : alpus_wb32_tom_t;
	signal master_common_tos : alpus_wb32_tos_t;
	signal master_common_tom : alpus_wb32_tom_t;
	signal slave0_tos : alpus_wb32_tos_t;
	signal slave0_tom : alpus_wb32_tom_t;
	signal slave1_tos : alpus_wb32_tos_t;
	signal slave1_tom : alpus_wb32_tom_t;
	signal slave2_tos : alpus_wb32_tos_t;
	signal slave2_tom : alpus_wb32_tom_t;
	signal slave2pbx_tos : alpus_wb32_tos_t;
	signal slave2pbx_tom : alpus_wb32_tom_t;
	signal slave2pb_tos : alpus_wb32_tos_t;
	signal slave2pb_tom : alpus_wb32_tom_t;
	signal slave3_tos : alpus_wb32_tos_t;
	signal slave3_tom : alpus_wb32_tom_t;

begin

	clk <= not clk after CLK_PERIOD /2;
	rst <= '0' after 500 ns;

	process is
		procedure tester(cmd_p : integer; addr_p : std_logic_vector(15 downto 0)) is
		begin
			wait until rising_edge(clk);
			wait until rising_edge(clk);
			req <= '1';	cmd <= cmd_p; addr <= addr_p or addr_ctr;
			wait until rising_edge(clk);
			req <= '0';
			wait until ack = '1';
		end procedure;
	begin
		req <= '0';	cmd <= 0; addr <= x"0000";
		wait until rising_edge(clk) and rst = '0';
			
		tester(0, x"0000");
		tester(0, x"0004");
		tester(1, x"0000");
		tester(1, x"0004");
		tester(2, x"0000");
		tester(3, x"0000");

		tester(0, x"2000");
		tester(0, x"2004");
		tester(1, x"2000");
		tester(1, x"2004");
		tester(2, x"2000");
		tester(3, x"2000");

		tester(0, x"4000");
		tester(0, x"4004");
		tester(1, x"4000");
		tester(1, x"4004");

		req <= '0';	cmd <= 0; addr <= x"0000";
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		addr_ctr <= std_logic_vector(unsigned(addr_ctr) + 16) and x"0ff0";
	end process;

	process is
		procedure tester(cmd_p : integer; addr_p : std_logic_vector(15 downto 0)) is
		begin
			req1 <= '1'; cmd1 <= cmd_p; addr1 <= addr_p or addr_ctr1;
			wait until rising_edge(clk);
			req1 <= '0';
			wait until ack1 = '1';
		end procedure;
	begin
		req1 <= '0'; cmd1 <= 0; addr1 <= x"0000";
		wait until rising_edge(clk) and rst = '0';
			
		tester(0, x"1000");
		tester(0, x"1004");
		tester(1, x"1000");
		tester(1, x"1004");
		tester(2, x"1000");
		tester(3, x"1000");

		tester(0, x"3000");
		tester(0, x"3004");
		tester(1, x"3000");
		tester(1, x"3004");
		tester(2, x"3000");
		tester(3, x"3000");

		tester(0, x"4008");
		tester(0, x"400c");
		tester(1, x"4008");
		tester(1, x"400c");

		req1 <= '0'; cmd1 <= 0; addr1 <= x"0000";
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		addr_ctr1 <= std_logic_vector(unsigned(addr_ctr1) + 16) and x"0ff0";
	end process;


	tester: alpus_wb_tester port map (
		clk => clk,
		rst => rst,

		req => req,
		cmd => cmd,
		addr => addr,
		ack => ack,

		req1 => req1,
		cmd1 => cmd1,
		addr1 => addr1,
		ack1 => ack1,

		res_ok => open);

end;