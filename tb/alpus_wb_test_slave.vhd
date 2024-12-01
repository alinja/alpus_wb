-- alpus_wb_test_slave 
--
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alpus_wb32_pkg.all;

package alpus_wb_test_slave_pkg is
component alpus_wb_test_slave is
generic(
	PIPELINED : std_logic := '1';
	STALL_DURATION : integer := 0;
	STALL_INVERTED : std_logic := '0';
	LATENCY : integer := 1
);
port(
	clk : in std_logic;
	rst : in std_logic;

	wb_tos : in alpus_wb32_tos_t;
	wb_tom : out alpus_wb32_tom_t;
	
	assert_fail : out std_logic
);
end component;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alpus_wb32_pkg.all;

entity alpus_wb_test_slave is
generic(
	PIPELINED : std_logic := '1';
	STALL_DURATION : integer := 0;
	STALL_INVERTED : std_logic := '0';
	LATENCY : integer := 1
);
port(
	clk : in std_logic;
	rst : in std_logic;

	wb_tos : in alpus_wb32_tos_t;
	wb_tom : out alpus_wb32_tom_t;
	
	assert_fail : out std_logic
);
end entity alpus_wb_test_slave;

architecture rtl of alpus_wb_test_slave is
	procedure sel_write(signal dest : inout std_logic_vector(31 downto 0); src : alpus_wb32_tos_t) is
	begin
		for byte in 0 to 3 loop
			if src.sel(byte) = '1' then
				dest(7+byte*8 downto byte*8) <= src.data(7+byte*8 downto byte*8);
			end if;
		end loop;
	end procedure;

	signal nonpipeline_waitstate : std_logic;
	
	signal stall : std_logic;
	signal stall_ctr : integer range 0 to 64;
	signal addr : std_logic_vector(7 downto 0);
	
	signal reg0 : std_logic_vector(31 downto 0);
	signal reg1 : std_logic_vector(31 downto 0);
	signal reg2 : std_logic_vector(31 downto 0);
	signal reg3 : std_logic_vector(31 downto 0);

	type data_pipeline_t is array (integer range 0 to LATENCY) of std_logic_vector(31 downto 0);
	signal data_pipeline : data_pipeline_t;
	signal ack_i : std_logic_vector(LATENCY downto 0);

begin
	addr <= "0000" & wb_tos.adr(3 downto 2) & "00";

	process(clk)
		variable STALL_V : std_logic;
	begin
		if rising_edge(clk) then

			if stall_ctr = 0 then
				stall_ctr <= STALL_DURATION;
				stall <= STALL_INVERTED;
			else
				stall_ctr <= stall_ctr-1;
				stall <= not STALL_INVERTED;
			end if;
			if STALL_DURATION = 0 then
				stall <= '0';
			end if;
			
			ack_i(0) <= '0';
			data_pipeline(0) <= (others => 'U');
			assert_fail <= '0';
			if wb_tos.cyc = '1' and wb_tos.stb = '1' and wb_tos.we = '1' and stall = '0' and nonpipeline_waitstate = '0' then
				--todo we
				case addr is
				when x"00" =>
					sel_write(reg0, wb_tos);
				when x"04" =>
					sel_write(reg1, wb_tos);
				when x"08" =>
					sel_write(reg2, wb_tos);
				when x"0c" =>
					sel_write(reg3, wb_tos);
				when others =>
					assert_fail <= '1';
				end case;
				
				ack_i(0) <= '1';
			end if;
			if wb_tos.cyc = '1' and wb_tos.stb = '1' and wb_tos.we = '0' and stall = '0' and nonpipeline_waitstate = '0' then
				case addr is
				when x"00" =>
					data_pipeline(0) <= reg0;
				when x"04" =>
					data_pipeline(0) <= reg1;
				when x"08" =>
					data_pipeline(0) <= reg2;
				when x"0c" =>
					data_pipeline(0) <= reg3;
				when others =>
					assert_fail <= '1';
				end case;
				ack_i(0) <= '1';
			end if;
			ack_i(ack_i'high downto 1) <= ack_i(ack_i'high-1 downto 0);
			data_pipeline(1 to LATENCY) <= data_pipeline(0 to LATENCY-1);
			
			if PIPELINED = '0' then
				if ack_i(LATENCY-1) = '1' then
					nonpipeline_waitstate <= '0';
				elsif wb_tos.cyc = '1' and wb_tos.stb = '1' then
					nonpipeline_waitstate <= '1';
				end if;
			end if;
			
			if rst = '1' then
				stall_ctr <= 0;
				stall <= '0';
				nonpipeline_waitstate <= '0';
				assert_fail <= '0';
				ack_i <= (others => '0');
				reg0 <= (others => '0');
				reg1 <= (others => '0');
				reg2 <= (others => '0');
				reg3 <= (others => '0');
			end if;
		end if;
	end process;
	wb_tom.ack <= ack_i(LATENCY-1);
	wb_tom.data <= data_pipeline(LATENCY-1);
	wb_tom.stall <= '0' when stall = '0' else '1';
end;