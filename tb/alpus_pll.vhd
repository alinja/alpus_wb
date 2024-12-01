-- alpus_pll
--
-- Generic simple pll for simulation and architecture independent instantiation.
-- * architecture independent interface
-- * choosable architecture dependent primitive
-- * supports clock multiplying by: input divider, vco multiplier, and output dividers
-- * supports phase shifing for outputs
--
--
--
-- Select f_VCO (=f_IN/IN_DIV*IN_MUL) from supported range, output clocks will be f_VCO/OUT0_DIV etc.
--
-- ARCH => 
-- "SIMULA": simple simulation model
-- "DUMMYX": dummy clock connection with no pll functionality
-- "X7MMCM": 600 - 1600MHz (Xilinx 7 series MMCM, integer dividers only supported)
-- "X7PLLE": 800 - 1600MHz (Xilinx 7 series PLL)
-- "GWRPLL": 400 - 1200MHz (Gowin rPLL, limited outputs available)
-- "ALTPLL": 400 - 1200MHz (Altera PLL)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

package alpus_pll_pkg is
component alpus_pll is
generic(
	ARCH : string := "SIMULA";
	IN_FREQ_MHZ : real := 100.0;
	OUT0_DIV : integer := 1;
	OUT1_DIV : integer := 1;
	OUT2_DIV : integer := 1;
	OUT3_DIV : integer := 1;
	OUT0_PHASE_DELAY : integer := 0;
	OUT1_PHASE_DELAY : integer := 0;
	OUT2_PHASE_DELAY : integer := 0;
	OUT3_PHASE_DELAY : integer := 0;
	IN_DIV : integer := 1; 
	IN_MUL : integer := 1
);
port(
	in_clk : in std_logic;
	in_rst : in std_logic := '0';

	out_clk0 : out std_logic;
	out_clk1 : out std_logic;
	out_clk2 : out std_logic;
	out_clk3 : out std_logic;
	out_locked : out std_logic
);
end component;

	-- choose separate architectures automatically 
	function alpus_pll_arch_synth_or_sim(synth : string; sim : string := "SIMULA") return string;
	
end package;

package body alpus_pll_pkg is
	function alpus_pll_arch_synth_or_sim(synth : string; sim : string := "SIMULA") return string is
        variable ret : string(1 to 6);
    begin
		ret := synth;
-- synthesis translate_off
		ret := sim;
-- synthesis translate_on
        return ret;
    end function; 
end package body;




library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alpus_pll_pkg.all;

entity alpus_pll is
generic(
	ARCH : string := "SIMULA";
	IN_FREQ_MHZ : real := 100.0;
	OUT0_DIV : integer := 1;
	OUT1_DIV : integer := 1;
	OUT2_DIV : integer := 1;
	OUT3_DIV : integer := 1;
	OUT0_PHASE_DELAY : integer := 0;
	OUT1_PHASE_DELAY : integer := 0;
	OUT2_PHASE_DELAY : integer := 0;
	OUT3_PHASE_DELAY : integer := 0;
	IN_DIV : integer := 1; 
	IN_MUL : integer := 1
);
port(
	in_clk : in std_logic;
	in_rst : in std_logic := '0';

	out_clk0 : out std_logic;
	out_clk1 : out std_logic;
	out_clk2 : out std_logic;
	out_clk3 : out std_logic;
	out_locked : out std_logic
);
end entity alpus_pll;

architecture rtl of alpus_pll is
	component alpus_pll_dummy is
	generic(
		OUT0_DIV : integer := 1;
		OUT1_DIV : integer := 1;
		OUT2_DIV : integer := 1;
		OUT3_DIV : integer := 1;
		IN_DIV : integer := 1; 
		IN_MUL : integer := 1
	);
	port(
		in_clk : in std_logic;
		in_rst : in std_logic := '0';

		out_clk0 : out std_logic;
		out_clk1 : out std_logic;
		out_clk2 : out std_logic;
		out_clk3 : out std_logic;
		out_locked : out std_logic
	);
	end component;
	component alpus_pll_sim is
	generic(
		OUT0_DIV : integer := 1;
		OUT1_DIV : integer := 1;
		OUT2_DIV : integer := 1;
		OUT3_DIV : integer := 1;
		OUT0_PHASE_DELAY : integer := 0;
		OUT1_PHASE_DELAY : integer := 0;
		OUT2_PHASE_DELAY : integer := 0;
		OUT3_PHASE_DELAY : integer := 0;
		IN_DIV : integer := 1; 
		IN_MUL : integer := 1
	);
	port(
		in_clk : in std_logic;
		in_rst : in std_logic := '0';

		out_clk0 : out std_logic;
		out_clk1 : out std_logic;
		out_clk2 : out std_logic;
		out_clk3 : out std_logic;
		out_locked : out std_logic
	);
	end component;
	component alpus_pll_x7mmcm is
	generic(
		IN_FREQ_MHZ : real := 100.0;
		OUT0_DIV : integer := 1;
		OUT1_DIV : integer := 1;
		OUT2_DIV : integer := 1;
		OUT3_DIV : integer := 1;
		OUT0_PHASE_DELAY : integer := 0;
		OUT1_PHASE_DELAY : integer := 0;
		OUT2_PHASE_DELAY : integer := 0;
		OUT3_PHASE_DELAY : integer := 0;
		IN_DIV : integer := 1; 
		IN_MUL : integer := 1
	);
	port(
		in_clk : in std_logic;
		in_rst : in std_logic := '0';

		out_clk0 : out std_logic;
		out_clk1 : out std_logic;
		out_clk2 : out std_logic;
		out_clk3 : out std_logic;
		out_locked : out std_logic
	);
	end component;
	component alpus_pll_x7pll is
	generic(
		IN_FREQ_MHZ : real := 100.0;
		OUT0_DIV : integer := 1;
		OUT1_DIV : integer := 1;
		OUT2_DIV : integer := 1;
		OUT3_DIV : integer := 1;
		OUT0_PHASE_DELAY : integer := 0;
		OUT1_PHASE_DELAY : integer := 0;
		OUT2_PHASE_DELAY : integer := 0;
		OUT3_PHASE_DELAY : integer := 0;
		IN_DIV : integer := 1; 
		IN_MUL : integer := 1
	);
	port(
		in_clk : in std_logic;
		in_rst : in std_logic := '0';

		out_clk0 : out std_logic;
		out_clk1 : out std_logic;
		out_clk2 : out std_logic;
		out_clk3 : out std_logic;
		out_locked : out std_logic
	);
	end component;

	component alpus_pll_gowin_rpll is
	generic(
		IN_FREQ_MHZ : real := 100.0;
		OUT0_DIV : integer := 1;
		OUT1_DIV : integer := 1;
		OUT2_DIV : integer := 1;
		OUT3_DIV : integer := 1;
		OUT0_PHASE_DELAY : integer := 0;
		OUT1_PHASE_DELAY : integer := 0;
		OUT2_PHASE_DELAY : integer := 0;
		OUT3_PHASE_DELAY : integer := 0;
		IN_DIV : integer := 1; 
		IN_MUL : integer := 1
	);
	port(
		in_clk : in std_logic;
		in_rst : in std_logic := '0';

		out_clk0 : out std_logic;
		out_clk1 : out std_logic;
		out_clk2 : out std_logic;
		out_clk3 : out std_logic;
		out_locked : out std_logic
	);
	end component;
	component alpus_pll_altpll is
	generic(
		IN_FREQ_MHZ : real := 100.0;
		OUT0_DIV : integer := 1;
		OUT1_DIV : integer := 1;
		OUT2_DIV : integer := 1;
		OUT3_DIV : integer := 1;
		OUT0_PHASE_DELAY : integer := 0;
		OUT1_PHASE_DELAY : integer := 0;
		OUT2_PHASE_DELAY : integer := 0;
		OUT3_PHASE_DELAY : integer := 0;
		IN_DIV : integer := 1; 
		IN_MUL : integer := 1
	);
	port(
		in_clk : in std_logic;
		in_rst : in std_logic := '0';

		out_clk0 : out std_logic;
		out_clk1 : out std_logic;
		out_clk2 : out std_logic;
		out_clk3 : out std_logic;
		out_locked : out std_logic
	);
	end component;
begin
	dummy: if ARCH = "DUMMYX" generate
		a: alpus_pll_dummy generic map (
			OUT0_DIV => OUT0_DIV,
			OUT1_DIV => OUT1_DIV,
			OUT2_DIV => OUT2_DIV,
			OUT3_DIV => OUT3_DIV,
			IN_DIV => IN_DIV,
			IN_MUL => IN_MUL
		) port map (
			in_clk => in_clk,
			in_rst => in_rst,
			out_clk0 => out_clk0,
			out_clk1 => out_clk1,
			out_clk2 => out_clk2,
			out_clk3 => out_clk3,
			out_locked => out_locked
		);
	end generate;
	sim: if ARCH = "SIMULA" generate
		a: alpus_pll_sim generic map (
			OUT0_DIV => OUT0_DIV,
			OUT1_DIV => OUT1_DIV,
			OUT2_DIV => OUT2_DIV,
			OUT3_DIV => OUT3_DIV,
			OUT0_PHASE_DELAY => OUT0_PHASE_DELAY,
			OUT1_PHASE_DELAY => OUT1_PHASE_DELAY,
			OUT2_PHASE_DELAY => OUT2_PHASE_DELAY,
			OUT3_PHASE_DELAY => OUT3_PHASE_DELAY,
			IN_DIV => IN_DIV,
			IN_MUL => IN_MUL
		) port map (
			in_clk => in_clk,
			in_rst => in_rst,
			out_clk0 => out_clk0,
			out_clk1 => out_clk1,
			out_clk2 => out_clk2,
			out_clk3 => out_clk3,
			out_locked => out_locked
		);
	end generate;
	x7mmcm: if ARCH = "X7MMCM" generate
		a: alpus_pll_x7mmcm generic map (
			IN_FREQ_MHZ => IN_FREQ_MHZ,
			OUT0_DIV => OUT0_DIV,
			OUT1_DIV => OUT1_DIV,
			OUT2_DIV => OUT2_DIV,
			OUT3_DIV => OUT3_DIV,
			OUT0_PHASE_DELAY => OUT0_PHASE_DELAY,
			OUT1_PHASE_DELAY => OUT1_PHASE_DELAY,
			OUT2_PHASE_DELAY => OUT2_PHASE_DELAY,
			OUT3_PHASE_DELAY => OUT3_PHASE_DELAY,
			IN_DIV => IN_DIV,
			IN_MUL => IN_MUL
		) port map (
			in_clk => in_clk,
			in_rst => in_rst,
			out_clk0 => out_clk0,
			out_clk1 => out_clk1,
			out_clk2 => out_clk2,
			out_clk3 => out_clk3,
			out_locked => out_locked
		);
	end generate;
	x7pll: if ARCH = "X7PLLE" generate
		a: alpus_pll_x7pll generic map (
			IN_FREQ_MHZ => IN_FREQ_MHZ,
			OUT0_DIV => OUT0_DIV,
			OUT1_DIV => OUT1_DIV,
			OUT2_DIV => OUT2_DIV,
			OUT3_DIV => OUT3_DIV,
			OUT0_PHASE_DELAY => OUT0_PHASE_DELAY,
			OUT1_PHASE_DELAY => OUT1_PHASE_DELAY,
			OUT2_PHASE_DELAY => OUT2_PHASE_DELAY,
			OUT3_PHASE_DELAY => OUT3_PHASE_DELAY,
			IN_DIV => IN_DIV,
			IN_MUL => IN_MUL
		) port map (
			in_clk => in_clk,
			in_rst => in_rst,
			out_clk0 => out_clk0,
			out_clk1 => out_clk1,
			out_clk2 => out_clk2,
			out_clk3 => out_clk3,
			out_locked => out_locked
		);
	end generate;
	gwrpll: if ARCH = "GWRPLL" generate
		a: alpus_pll_gowin_rpll generic map (
			IN_FREQ_MHZ => IN_FREQ_MHZ,
			OUT0_DIV => OUT0_DIV,
			OUT1_DIV => OUT1_DIV,
			OUT2_DIV => OUT2_DIV,
			OUT3_DIV => OUT3_DIV,
			OUT0_PHASE_DELAY => OUT0_PHASE_DELAY,
			OUT1_PHASE_DELAY => OUT1_PHASE_DELAY,
			OUT2_PHASE_DELAY => OUT2_PHASE_DELAY,
			OUT3_PHASE_DELAY => OUT3_PHASE_DELAY,
			IN_DIV => IN_DIV,
			IN_MUL => IN_MUL
		) port map (
			in_clk => in_clk,
			in_rst => in_rst,
			out_clk0 => out_clk0,
			out_clk1 => out_clk1,
			out_clk2 => out_clk2,
			out_clk3 => out_clk3,
			out_locked => out_locked
		);
	end generate;
	altpll: if ARCH = "ALTPLL" generate
		a: alpus_pll_altpll generic map (
			IN_FREQ_MHZ => IN_FREQ_MHZ,
			OUT0_DIV => OUT0_DIV,
			OUT1_DIV => OUT1_DIV,
			OUT2_DIV => OUT2_DIV,
			OUT3_DIV => OUT3_DIV,
			OUT0_PHASE_DELAY => OUT0_PHASE_DELAY,
			OUT1_PHASE_DELAY => OUT1_PHASE_DELAY,
			OUT2_PHASE_DELAY => OUT2_PHASE_DELAY,
			OUT3_PHASE_DELAY => OUT3_PHASE_DELAY,
			IN_DIV => IN_DIV,
			IN_MUL => IN_MUL
		) port map (
			in_clk => in_clk,
			in_rst => in_rst,
			out_clk0 => out_clk0,
			out_clk1 => out_clk1,
			out_clk2 => out_clk2,
			out_clk3 => out_clk3,
			out_locked => out_locked
		);
	end generate;
end;









library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity alpus_pll_dummy is
generic(
	OUT0_DIV : integer := 1;
	OUT1_DIV : integer := 1;
	OUT2_DIV : integer := 1;
	OUT3_DIV : integer := 1;
	IN_DIV : integer := 1; 
	IN_MUL : integer := 1
);
port(
	in_clk : in std_logic;
	in_rst : in std_logic := '0';

	out_clk0 : out std_logic;
	out_clk1 : out std_logic;
	out_clk2 : out std_logic;
	out_clk3 : out std_logic;
	out_locked : out std_logic
);
end entity alpus_pll_dummy;

architecture rtl of alpus_pll_dummy is

begin
	out_locked <= not in_rst;
	out_clk0 <= in_clk;
	out_clk1 <= in_clk;
	out_clk2 <= in_clk;
	out_clk3 <= in_clk;
end;







library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity alpus_pll_sim is
generic(
	OUT0_DIV : integer := 1;
	OUT1_DIV : integer := 1;
	OUT2_DIV : integer := 1;
	OUT3_DIV : integer := 1;
	OUT0_PHASE_DELAY : integer := 0;
	OUT1_PHASE_DELAY : integer := 0;
	OUT2_PHASE_DELAY : integer := 0;
	OUT3_PHASE_DELAY : integer := 0;
	IN_DIV : integer := 1; 
	IN_MUL : integer := 1
);
port(
	in_clk : in std_logic;
	in_rst : in std_logic := '0';

	out_clk0 : out std_logic;
	out_clk1 : out std_logic;
	out_clk2 : out std_logic;
	out_clk3 : out std_logic;
	out_locked : out std_logic
);
end entity alpus_pll_sim;

architecture rtl of alpus_pll_sim is

	constant CLK_PERIOD_INIT : time := 10 ms;
	constant LOCKED_DELAY : integer := 14; -- must be even to align clocks

	signal prev_clk : time := now;
	signal clk_period : time := CLK_PERIOD_INIT;

	signal locked_raw : std_logic := '0';
	signal locked_ctr : integer := 0;
	signal vco_clk : std_logic := '0';

	signal out_clk0_ctr : integer := 0;
	signal out_clk1_ctr : integer := 0;
	signal out_clk2_ctr : integer := 0;
	signal out_clk3_ctr : integer := 0;
	signal out_clk0_i : std_logic := '0';
	signal out_clk1_i : std_logic := '0';
	signal out_clk2_i : std_logic := '0';
	signal out_clk3_i : std_logic := '0';

begin
-- synthesis translate_off 

	-- sample input period
	process(in_clk, in_rst)
	begin
		if in_rst = '1' then
			prev_clk <= now;
			clk_period <= CLK_PERIOD_INIT;
			locked_raw <= '0';
		elsif rising_edge(in_clk) then
				if clk_period = now - prev_clk then
					locked_raw <= '1';
				else
					locked_raw <= '0';
				end if;
				prev_clk <= now;
				clk_period <= now - prev_clk;
		end if;
	end process;

	-- generate vco
	process(in_clk, in_rst, vco_clk)
	begin
		if in_rst = '1' then
			vco_clk <= '0';
		elsif locked_raw = '1' then
			if rising_edge(in_clk) then
				vco_clk <= '1', '0' after clk_period/IN_MUL/2;
			else
				vco_clk <= not vco_clk after clk_period/IN_MUL/2;
			end if;
		end if;
	end process;

	-- generate divided output clocks
	process(vco_clk, in_rst)
		variable LOCK : std_logic := '0';
	begin
		if in_rst = '1' then
			out_clk0_ctr <= 0;
			out_clk1_ctr <= 0;
			out_clk2_ctr <= 0;
			out_clk3_ctr <= 0;
			locked_ctr <= 0;
			out_locked <= '0';
			LOCK := '0';
		elsif rising_edge(vco_clk) or falling_edge(vco_clk) then
			if locked_ctr < LOCKED_DELAY-1 then
				locked_ctr <= locked_ctr + 1;
			else
				if locked_ctr < LOCKED_DELAY and in_clk = '1' and vco_clk = '1' then
					locked_ctr <= locked_ctr + 1;
					LOCK := '1';
					out_locked <= '1';
				end if;
			end if;
		
		
			--if locked_ctr < LOCKED_DELAY then
			if LOCK = '0' then
				out_clk0_i <= vco_clk; --sync
				out_clk0_ctr <= out_clk0_ctr + 1;
			elsif out_clk0_ctr < OUT0_DIV-1 then
				out_clk0_ctr <= out_clk0_ctr + 1;
			else
				out_clk0_ctr <= 0;
				out_clk0_i <= not out_clk0_i;
			end if;
			
			--if locked_ctr < LOCKED_DELAY then
			if LOCK = '0' then
				out_clk1_i <= vco_clk; --sync
				out_clk1_ctr <= out_clk1_ctr + 1;
			elsif out_clk1_ctr < OUT1_DIV-1 then
				out_clk1_ctr <= out_clk1_ctr + 1;
			else
				out_clk1_ctr <= 0;
				out_clk1_i <= not out_clk1_i;
			end if;
			
			--if locked_ctr < LOCKED_DELAY then
			if LOCK = '0' then
				out_clk2_i <= vco_clk; --sync
				out_clk2_ctr <= out_clk2_ctr + 1;
			elsif out_clk2_ctr < OUT2_DIV-1 then
				out_clk2_ctr <= out_clk2_ctr + 1;
			else
				out_clk2_ctr <= 0;
				out_clk2_i <= not out_clk2_i;
			end if;
			
			--if locked_ctr < LOCKED_DELAY then
			if LOCK = '0' then
				out_clk3_i <= vco_clk; --sync
				out_clk3_ctr <= out_clk3_ctr + 1;
			elsif out_clk3_ctr < OUT3_DIV-1 then
				out_clk3_ctr <= out_clk3_ctr + 1;
			else
				out_clk3_ctr <= 0;
				out_clk3_i <= not out_clk3_i;
			end if;
			
		end if;
	end process;

	out_clk0 <= out_clk0_i;
	out_clk1 <= out_clk1_i;
	out_clk2 <= out_clk2_i;
	out_clk3 <= out_clk3_i;
-- synthesis translate_on
end;









--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--library work;
--
--package alpus_pll_x7mmcm_pkg is
--component alpus_pll_x7mmcm is
--generic(
--	IN_FREQ_MHZ : real := 100.0;
--	OUT0_DIV : integer := 1;
--	OUT1_DIV : integer := 1;
--	OUT2_DIV : integer := 1;
--	OUT3_DIV : integer := 1;
--	IN_DIV : integer := 1; 
--	IN_MUL : integer := 1
--);
--port(
--	in_clk : in std_logic;
--	in_rst : in std_logic := '0';
--
--	out_clk0 : out std_logic;
--	out_clk1 : out std_logic;
--	out_clk2 : out std_logic;
--	out_clk3 : out std_logic;
--	out_locked : out std_logic
--);
--end component;
--end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity alpus_pll_x7mmcm is
generic(
	IN_FREQ_MHZ : real := 100.0;
	OUT0_DIV : integer := 1;
	OUT1_DIV : integer := 1;
	OUT2_DIV : integer := 1;
	OUT3_DIV : integer := 1;
	OUT0_PHASE_DELAY : integer := 0;
	OUT1_PHASE_DELAY : integer := 0;
	OUT2_PHASE_DELAY : integer := 0;
	OUT3_PHASE_DELAY : integer := 0;
	IN_DIV : integer := 1; 
	IN_MUL : integer := 1
);
port(
	in_clk : in std_logic;
	in_rst : in std_logic := '0';

	out_clk0 : out std_logic;
	out_clk1 : out std_logic;
	out_clk2 : out std_logic;
	out_clk3 : out std_logic;
	out_locked : out std_logic
);
end entity alpus_pll_x7mmcm;

architecture rtl of alpus_pll_x7mmcm is
	component BUFG is
	port(
		i : in std_logic;
		o : out std_logic
	);
	end component;
	component MMCME2_BASE is
	generic(
		BANDWIDTH : string;
		DIVCLK_DIVIDE : integer := 1;
		CLKFBOUT_MULT_F : real;
		CLKOUT0_DIVIDE_F : real;
		CLKOUT1_DIVIDE : integer := 1;
		CLKOUT2_DIVIDE : integer := 1;
		CLKOUT3_DIVIDE : integer := 1;
		CLKOUT0_PHASE : real;
		CLKOUT1_PHASE : real;
		CLKOUT2_PHASE : real;
		CLKOUT3_PHASE : real;
		CLKIN1_PERIOD : real
	);
	port(
		CLKIN1 : in std_logic;
		RST : in std_logic;
		CLKFBOUT : out std_logic;
		CLKFBIN : in std_logic;

		CLKOUT0 : out std_logic;
		CLKOUT1 : out std_logic;
		CLKOUT2 : out std_logic;
		CLKOUT3 : out std_logic;
		PWRDWN : in std_logic := '0';

		LOCKED : out std_logic
	);
	end component;

	signal clkfbout : std_logic;
	signal clkfbout_bufg : std_logic;
	signal out_clk0_i : std_logic;
	signal out_clk1_i : std_logic;
	signal out_clk2_i : std_logic;
	signal out_clk3_i : std_logic;

begin
	pll: MMCME2_BASE generic map (
		BANDWIDTH => "OPTIMIZED",
		DIVCLK_DIVIDE => IN_DIV,
		CLKFBOUT_MULT_F => real(IN_MUL),
		CLKOUT0_DIVIDE_F => real(OUT0_DIV),
		CLKOUT1_DIVIDE => OUT1_DIV,
		CLKOUT2_DIVIDE => OUT2_DIV,
		CLKOUT3_DIVIDE => OUT3_DIV,
		CLKOUT0_PHASE => real(OUT0_PHASE_DELAY),
		CLKOUT1_PHASE => real(OUT1_PHASE_DELAY),
		CLKOUT2_PHASE => real(OUT2_PHASE_DELAY),
		CLKOUT3_PHASE => real(OUT3_PHASE_DELAY),
		CLKIN1_PERIOD => 1000.0/IN_FREQ_MHZ
	) port map (
		CLKIN1 => in_clk,
		--CLKIN2 => '0',
		RST => in_rst,
		CLKFBOUT => clkfbout,
		CLKFBIN => clkfbout_bufg,
		CLKOUT0 => out_clk0_i,
		CLKOUT1 => out_clk1_i,
		CLKOUT2 => out_clk2_i,
		CLKOUT3 => out_clk3_i,
		PWRDWN => '0',
		LOCKED => out_locked
	);
	
	feedback: BUFG port map (
		I => clkfbout,
		O => clkfbout_bufg
	);
	out0: BUFG port map (
		I => out_clk0_i,
		O => out_clk0
	);
	out1: BUFG port map (
		I => out_clk1_i,
		O => out_clk1
	);
	out2: BUFG port map (
		I => out_clk2_i,
		O => out_clk2
	);
	out3: BUFG port map (
		I => out_clk3_i,
		O => out_clk3
	);

end;









library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity alpus_pll_x7pll is
generic(
	IN_FREQ_MHZ : real := 100.0;
	OUT0_DIV : integer := 1;
	OUT1_DIV : integer := 1;
	OUT2_DIV : integer := 1;
	OUT3_DIV : integer := 1;
	OUT0_PHASE_DELAY : integer := 0;
	OUT1_PHASE_DELAY : integer := 0;
	OUT2_PHASE_DELAY : integer := 0;
	OUT3_PHASE_DELAY : integer := 0;
	IN_DIV : integer := 1; 
	IN_MUL : integer := 1
);
port(
	in_clk : in std_logic;
	in_rst : in std_logic := '0';

	out_clk0 : out std_logic;
	out_clk1 : out std_logic;
	out_clk2 : out std_logic;
	out_clk3 : out std_logic;
	out_locked : out std_logic
);
end entity alpus_pll_x7pll;

architecture rtl of alpus_pll_x7pll is
	component BUFG is
	port(
		i : in std_logic;
		o : out std_logic
	);
	end component;
	component PLLE2_BASE is
	generic(
		BANDWIDTH : string;
		DIVCLK_DIVIDE : integer := 1;
		CLKFBOUT_MULT : integer := 1;
		CLKOUT0_DIVIDE : integer := 1;
		CLKOUT1_DIVIDE : integer := 1;
		CLKOUT2_DIVIDE : integer := 1;
		CLKOUT3_DIVIDE : integer := 1;
		CLKOUT0_PHASE : real;
		CLKOUT1_PHASE : real;
		CLKOUT2_PHASE : real;
		CLKOUT3_PHASE : real;
		CLKIN1_PERIOD : real
	);
	port(
		CLKIN1 : in std_logic;
		RST : in std_logic;
		CLKFBOUT : out std_logic;
		CLKFBIN : in std_logic;

		CLKOUT0 : out std_logic;
		CLKOUT1 : out std_logic;
		CLKOUT2 : out std_logic;
		CLKOUT3 : out std_logic;
		PWRDWN : in std_logic := '0';

		LOCKED : out std_logic
	);
	end component;

	signal clkfbout : std_logic;
	signal clkfbout_bufg : std_logic;
	signal out_clk0_i : std_logic;
	signal out_clk1_i : std_logic;
	signal out_clk2_i : std_logic;
	signal out_clk3_i : std_logic;

begin
	pll: PLLE2_BASE generic map (
		BANDWIDTH => "OPTIMIZED",
		DIVCLK_DIVIDE => IN_DIV,
		CLKFBOUT_MULT => IN_MUL,
		CLKOUT0_DIVIDE => OUT0_DIV,
		CLKOUT1_DIVIDE => OUT1_DIV,
		CLKOUT2_DIVIDE => OUT2_DIV,
		CLKOUT3_DIVIDE => OUT3_DIV,
		CLKOUT0_PHASE => real(OUT0_PHASE_DELAY),
		CLKOUT1_PHASE => real(OUT1_PHASE_DELAY),
		CLKOUT2_PHASE => real(OUT2_PHASE_DELAY),
		CLKOUT3_PHASE => real(OUT3_PHASE_DELAY),
		CLKIN1_PERIOD => 1000.0/IN_FREQ_MHZ
	) port map (
		CLKIN1 => in_clk,
		RST => in_rst,
		CLKFBOUT => clkfbout,
		CLKFBIN => clkfbout_bufg,
		CLKOUT0 => out_clk0_i,
		CLKOUT1 => out_clk1_i,
		CLKOUT2 => out_clk2_i,
		CLKOUT3 => out_clk3_i,
		PWRDWN => '0',
		LOCKED => out_locked
	);
	
	feedback: BUFG port map (
		I => clkfbout,
		O => clkfbout_bufg
	);
	out0: BUFG port map (
		I => out_clk0_i,
		O => out_clk0
	);
	out1: BUFG port map (
		I => out_clk1_i,
		O => out_clk1
	);
	out2: BUFG port map (
		I => out_clk2_i,
		O => out_clk2
	);
	out3: BUFG port map (
		I => out_clk3_i,
		O => out_clk3
	);

end;

















library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity alpus_pll_gowin_rpll is
generic(
	IN_FREQ_MHZ : real := 100.0;
	OUT0_DIV : integer := 1;
	OUT1_DIV : integer := 1;
	OUT2_DIV : integer := 1;
	OUT3_DIV : integer := 1;
	OUT0_PHASE_DELAY : integer := 0;
	OUT1_PHASE_DELAY : integer := 0;
	OUT2_PHASE_DELAY : integer := 0;
	OUT3_PHASE_DELAY : integer := 0;
	IN_DIV : integer := 1; 
	IN_MUL : integer := 1
);
port(
	in_clk : in std_logic;
	in_rst : in std_logic := '0';

	out_clk0 : out std_logic;
	out_clk1 : out std_logic;
	out_clk2 : out std_logic;
	out_clk3 : out std_logic;
	out_locked : out std_logic
);
end entity alpus_pll_gowin_rpll;

architecture rtl of alpus_pll_gowin_rpll is
	component rPLL
	generic (
		FCLKIN: in string := "100.0";
		DEVICE: in string := "GW1N-4";
		DYN_IDIV_SEL: in string := "false";
		IDIV_SEL: in integer := 0;
		DYN_FBDIV_SEL: in string := "false";
		FBDIV_SEL: in integer := 0;
		DYN_ODIV_SEL: in string := "false";
		ODIV_SEL: in integer := 8;
		PSDA_SEL: in string := "0000";
		DYN_DA_EN: in string := "false";
		DUTYDA_SEL: in string := "1000";
		CLKOUT_FT_DIR: in bit := '1';
		CLKOUTP_FT_DIR: in bit := '1';
		CLKOUT_DLY_STEP: in integer := 0;
		CLKOUTP_DLY_STEP: in integer := 0;
		CLKOUTD3_SRC: in string := "CLKOUT";
		CLKFB_SEL: in string := "internal";
		CLKOUT_BYPASS: in string := "false";
		CLKOUTP_BYPASS: in string := "false";
		CLKOUTD_BYPASS: in string := "false";
		CLKOUTD_SRC: in string := "CLKOUT";
		DYN_SDIV_SEL: in integer := 2
	);
	port (
		CLKOUT: out std_logic;
		LOCK: out std_logic;
		CLKOUTP: out std_logic;
		CLKOUTD: out std_logic;
		CLKOUTD3: out std_logic;
		RESET: in std_logic;
		RESET_P: in std_logic;
		CLKIN: in std_logic;
		CLKFB: in std_logic;
		FBDSEL: in std_logic_vector(5 downto 0);
		IDSEL: in std_logic_vector(5 downto 0);
		ODSEL: in std_logic_vector(5 downto 0);
		PSDA: in std_logic_vector(3 downto 0);
		DUTYDA: in std_logic_vector(3 downto 0);
		FDLY: in std_logic_vector(3 downto 0)
	);
	end component;
	constant PHASE : std_logic_vector(3 downto 0) := std_logic_vector(to_signed(OUT2_PHASE_DELAY*16/360, 4));
begin
	-- rPLL is very limited in supporting clock modes!!

	assert IN_MUL mod OUT0_DIV = 0 report "GOWIN rPLL: IN_MUL must be multiple of OUT0_DIV" severity error;
	assert OUT1_DIV mod OUT0_DIV = 0 report "GOWIN rPLL: OUT1_DIV must be multiple of OUT0_DIV" severity error;
	assert OUT0_PHASE_DELAY = 0 report "GOWIN rPLL: only OUT2_PHASE_DELAY supported" severity error;
	assert OUT1_PHASE_DELAY = 0 report "GOWIN rPLL: only OUT2_PHASE_DELAY supported" severity error;
	assert OUT3_PHASE_DELAY = 0 report "GOWIN rPLL: only OUT2_PHASE_DELAY supported" severity error;

-- VCO frequency  = (FCLKIN*(FBDIV_SEL+1)*ODIV_SEL)/(IDIV_SEL+1)
	pll: rPLL generic map (
		FCLKIN => real'image(IN_FREQ_MHZ), --"27",
		DEVICE => "GW1NR-9C",
		DYN_IDIV_SEL => "false",
		IDIV_SEL => IN_DIV-1,
		DYN_FBDIV_SEL => "false",
		FBDIV_SEL => IN_MUL/OUT0_DIV-1,
		DYN_ODIV_SEL => "false",
		ODIV_SEL => OUT0_DIV,
		--PSDA_SEL => "1100",
		PSDA_SEL => std_logic'image(PHASE(3))(2) & std_logic'image(PHASE(2))(2) & std_logic'image(PHASE(1))(2) & std_logic'image(PHASE(0))(2),
		DYN_DA_EN => "false",
		DUTYDA_SEL => "1000",
		CLKOUT_FT_DIR => '1',
		CLKOUTP_FT_DIR => '1',
		CLKOUT_DLY_STEP => 0,
		CLKOUTP_DLY_STEP => 0,
		CLKFB_SEL => "internal",
		CLKOUT_BYPASS => "false",
		CLKOUTP_BYPASS => "false",
		CLKOUTD_BYPASS => "false",
		DYN_SDIV_SEL => OUT1_DIV/OUT0_DIV,
		CLKOUTD_SRC => "CLKOUT",
		CLKOUTD3_SRC => "CLKOUT"
	) port map (
		LOCK => out_locked,
		CLKOUT => out_clk0,
		CLKOUTD => out_clk1, --CLKOUT/N, N min 2
		CLKOUTP => out_clk2, --CLKOUT with phase shift, other outputs cannot be shifted
		CLKOUTD3 => out_clk3, --CLKOUT/3, inverted
		RESET => in_rst,
		RESET_P => '0',
		CLKIN => in_clk,
		CLKFB => '0',
		FBDSEL => "000000",
		IDSEL => "000000",
		ODSEL => "000000",
		PSDA => "0100",
		DUTYDA => "0000",
		FDLY => "1111"
	);
end;







library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity alpus_pll_altpll is
generic(
	IN_FREQ_MHZ : real := 100.0;
	OUT0_DIV : integer := 1;
	OUT1_DIV : integer := 1;
	OUT2_DIV : integer := 1;
	OUT3_DIV : integer := 1;
	OUT0_PHASE_DELAY : integer := 0;
	OUT1_PHASE_DELAY : integer := 0;
	OUT2_PHASE_DELAY : integer := 0;
	OUT3_PHASE_DELAY : integer := 0;
	IN_DIV : integer := 1; 
	IN_MUL : integer := 1
);
port(
	in_clk : in std_logic;
	in_rst : in std_logic := '0';

	out_clk0 : out std_logic;
	out_clk1 : out std_logic;
	out_clk2 : out std_logic;
	out_clk3 : out std_logic;
	out_locked : out std_logic
);
end entity alpus_pll_altpll;

architecture rtl of alpus_pll_altpll is
	component altpll
	generic (
		bandwidth_type		: string;
		clk0_divide_by		: natural;
		clk0_duty_cycle		: natural;
		clk0_multiply_by		: natural;
		clk0_phase_shift		: string;
		clk1_divide_by		: natural;
		clk1_duty_cycle		: natural;
		clk1_multiply_by		: natural;
		clk1_phase_shift		: string;
		clk2_divide_by		: natural;
		clk2_duty_cycle		: natural;
		clk2_multiply_by		: natural;
		clk2_phase_shift		: string;
		clk3_divide_by		: natural;
		clk3_duty_cycle		: natural;
		clk3_multiply_by		: natural;
		clk3_phase_shift		: string;
		compensate_clock		: string;
		inclk0_input_frequency		: natural;
		intended_device_family		: string;
		lpm_hint		: string;
		lpm_type		: string;
		operation_mode		: string;
		pll_type		: string;
		port_activeclock		: string;
		port_areset		: string;
		port_clkbad0		: string;
		port_clkbad1		: string;
		port_clkloss		: string;
		port_clkswitch		: string;
		port_configupdate		: string;
		port_fbin		: string;
		port_inclk0		: string;
		port_inclk1		: string;
		port_locked		: string;
		port_clk0		: string;
		port_clk1		: string;
		port_clk2		: string;
		port_clk3		: string;
		port_clk4		: string;
		self_reset_on_loss_lock		: string;
		width_clock		: natural
	);
	port (
		areset	: in std_logic ;
		clk	: out std_logic_vector (4 downto 0);
		inclk	: in std_logic_vector (1 downto 0);
		locked	: out std_logic 
	);
	end component;
	signal out_clk4 : std_logic;

begin
	-- ALTPLL always overrides VCO frequency and dividers to automatically chosen values

	pll : altpll generic map (
		bandwidth_type => "AUTO",
		clk0_divide_by => OUT0_DIV*IN_DIV,
		clk0_duty_cycle => 50,
		clk0_multiply_by => IN_MUL,
		clk0_phase_shift => real'image(1.0e6/(IN_FREQ_MHZ*real(IN_MUL)/real((OUT0_DIV*IN_DIV)))*real(OUT1_PHASE_DELAY)/360.0),
		clk1_divide_by => OUT1_DIV*IN_DIV,
		clk1_duty_cycle => 50,
		clk1_multiply_by => IN_MUL,
		clk1_phase_shift => real'image(1.0e6/(IN_FREQ_MHZ*real(IN_MUL)/real((OUT1_DIV*IN_DIV)))*real(OUT1_PHASE_DELAY)/360.0),
		clk2_divide_by => OUT2_DIV*IN_DIV,
		clk2_duty_cycle => 50,
		clk2_multiply_by => IN_MUL,
		clk2_phase_shift => real'image(1.0e6/(IN_FREQ_MHZ*real(IN_MUL)/real((OUT2_DIV*IN_DIV)))*real(OUT1_PHASE_DELAY)/360.0),
		clk3_divide_by => OUT3_DIV*IN_DIV,
		clk3_duty_cycle => 50,
		clk3_multiply_by => IN_MUL,
		clk3_phase_shift => real'image(1.0e6/(IN_FREQ_MHZ*real(IN_MUL)/real((OUT3_DIV*IN_DIV)))*real(OUT1_PHASE_DELAY)/360.0),
		compensate_clock => "CLK0",
		inclk0_input_frequency => integer(1000000.0/IN_FREQ_MHZ), --TODO
		intended_device_family => "Cyclone IV E",
		lpm_hint => "cbx_module_prefix=pll",
		lpm_type => "altpll",
		operation_mode => "NORMAL",
		pll_type => "AUTO",
		port_activeclock => "PORT_UNUSED",
		port_areset => "PORT_USED",
		port_clkbad0 => "PORT_UNUSED",
		port_clkbad1 => "PORT_UNUSED",
		port_clkloss => "PORT_UNUSED",
		port_clkswitch => "PORT_UNUSED",
		port_configupdate => "PORT_UNUSED",
		port_fbin => "PORT_UNUSED",
		port_inclk0 => "PORT_USED",
		port_inclk1 => "PORT_UNUSED",
		port_locked => "PORT_USED",
		port_clk0 => "PORT_USED",
		port_clk1 => "PORT_USED",
		port_clk2 => "PORT_USED",
		port_clk3 => "PORT_USED",
		port_clk4 => "PORT_USED",
		self_reset_on_loss_lock => "ON",
		width_clock => 5
	) port map (
		inclk(0) => in_clk,
		inclk(1) => '0',
		areset => in_rst,
		locked => out_locked,
		clk(0) => out_clk0,
		clk(1) => out_clk1,
		clk(2) => out_clk2,
		clk(3) => out_clk3,
		clk(4) => out_clk4
	);

end;





