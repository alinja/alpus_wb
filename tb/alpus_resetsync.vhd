-- alpus_resetsync
--
-- Reset synchronizer
-- * Supports multiple unrelated clocks
-- * Async reset and pll locked signals
-- * Reset stretching to guarantee reset for all clocks
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

package alpus_resetsync_pkg is
component alpus_resetsync is
generic(
	NUM_CLOCKS : integer := 1;
	ARST_ACTIVE : std_logic := '1';
	RST_COUNTER_WID : integer := 4
);
port(
	slow_clk : in std_logic;         -- use slowest clock
	arst     : in std_logic := '0';
	locked   : in std_logic := '1';

	clk : in std_logic_vector(NUM_CLOCKS-1 downto 0);
	rst : out std_logic_vector(NUM_CLOCKS-1 downto 0)
);
end component;
end package;

package body alpus_resetsync_pkg is
end package body;




library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity alpus_resetsync is
generic(
	NUM_CLOCKS : integer := 1;
	ARST_ACTIVE : std_logic := '1';
	RST_COUNTER_WID : integer := 4
);
port(
	slow_clk : in std_logic;         -- use slowest clock
	arst     : in std_logic := '0';
	locked   : in std_logic := '1';

	clk : in std_logic_vector(NUM_CLOCKS-1 downto 0);
	rst : out std_logic_vector(NUM_CLOCKS-1 downto 0)
);
end entity alpus_resetsync;

architecture rtl of alpus_resetsync is

	signal arst_combined :  std_logic;
	signal rst_ctr : unsigned(RST_COUNTER_WID-1 downto 0) := (others => '0');
	signal rst_i :  std_logic;

	signal rst_sample      : std_logic_vector(NUM_CLOCKS-1 downto 0);
	signal rst_sample_meta : std_logic_vector(NUM_CLOCKS-1 downto 0);
begin

	arst_combined <= (arst or not locked) when ARST_ACTIVE = '1' else (not arst or not locked);

	-- make a single stretched registered reset signal
	process(slow_clk, arst_combined)
	begin
		if arst_combined = '1' then
			rst_ctr <= (others => '0');
			rst_i <= '1';
		elsif rising_edge(slow_clk) then
			-- handles also possible metastabilites from asynchronous path from reset
			if rst_ctr < 2**RST_COUNTER_WID-1 then
				rst_ctr <= rst_ctr + 1;
				rst_i <= '1';
			else
				rst_i <= '0';
			end if;
		end if;
	end process;

	g0: for i in 0 to NUM_CLOCKS-1 generate
		process(clk(i))
		begin
			if rising_edge(clk(i)) then
				rst_sample(i) <= rst_i;
				rst_sample_meta(i) <= rst_sample(i);
				rst(i) <= rst_sample_meta(i);
			end if;
		end process;
	end generate;
end;



