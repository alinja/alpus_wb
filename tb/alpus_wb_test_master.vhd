-- alpus_wb_test_master
--
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alpus_wb32_pkg.all;

package alpus_wb_test_master_pkg is
component alpus_wb_test_master is
generic(
	PIPELINED : std_logic := '1';
	BLOCK_LEN : integer := 4
);
port(
	clk : in std_logic;
	rst : in std_logic;

	req : in std_logic;
	cmd : in integer range 0 to 64;
	addr : in std_logic_vector(15 downto 0);
	ack : out std_logic;
	res_ok : out std_logic;

	wb_tos : out alpus_wb32_tos_t;
	wb_tom : in alpus_wb32_tom_t
);
end component;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alpus_wb32_pkg.all;

entity alpus_wb_test_master is
generic(
	PIPELINED : std_logic := '1';
	BLOCK_LEN : integer := 4
);
port(
	clk : in std_logic;
	rst : in std_logic;

	req : in std_logic;
	cmd : in integer range 0 to 64;
	addr : in std_logic_vector(15 downto 0);
	ack : out std_logic;
	res_ok : out std_logic;

	wb_tos : out alpus_wb32_tos_t;
	wb_tom : in alpus_wb32_tom_t
);
end entity alpus_wb_test_master;

architecture rtl of alpus_wb_test_master is
	signal wb_tos_i : alpus_wb32_tos_t;
	signal wb_tom_i : alpus_wb32_tom_t;

	type master_fsm_t is (idle, classic_wr, classic_rd, classic_blockwr, classic_blockrd, dummy);
	signal master_fsm : master_fsm_t;
	signal addr_i : std_logic_vector(15 downto 0);
	signal addr_ri : std_logic_vector(15 downto 0);
	signal block_ctr : integer range 0 to 64;
	signal block_ack_ctr : integer range 0 to 64;

	signal chk_data : std_logic_vector(31 downto 0);
	signal chk_data_ref : std_logic_vector(31 downto 0);
	signal chk_en : std_logic;

	function addr_to_data(addr : std_logic_vector(15 downto 0)) return std_logic_vector is
	begin
		return std_logic_vector(unsigned(addr) + 1) & addr;
	end function;

begin
	process(clk)
	begin
		if rising_edge(clk) then
			ack <= '0';
			chk_en <= '0';
			wb_tos_i.sel <= "1111";
			case master_fsm is
			when idle =>
				--res_ok <= '1';
				if req = '1' then
					if cmd = 0 then
						wb_tos_i.adr(15 downto 0) <= addr;
						wb_tos_i.data <= addr_to_data(addr);
						wb_tos_i.we <= '1';
						wb_tos_i.cyc <= '1';
						wb_tos_i.stb <= '1';
						addr_i <= addr;
						addr_ri <= addr;
						master_fsm <= classic_wr;
					elsif cmd = 1 then
						wb_tos_i.adr(15 downto 0) <= addr;
						wb_tos_i.we <= '0';
						wb_tos_i.cyc <= '1';
						wb_tos_i.stb <= '1';
						addr_i <= addr;
						addr_ri <= addr;
						master_fsm <= classic_rd;
					elsif cmd = 2 then
						wb_tos_i.adr(15 downto 0) <= addr;
						wb_tos_i.data <= addr_to_data(addr);
						wb_tos_i.we <= '1';
						wb_tos_i.cyc <= '1';
						wb_tos_i.stb <= '1';
						addr_i <= addr;
						addr_ri <= addr;
						block_ctr <= 0;
						block_ack_ctr <= 0;
						master_fsm <= classic_blockwr;
					elsif cmd = 3 then
						wb_tos_i.adr(15 downto 0) <= addr;
						wb_tos_i.we <= '0';
						wb_tos_i.cyc <= '1';
						wb_tos_i.stb <= '1';
						addr_i <= addr;
						addr_ri <= addr;
						block_ctr <= 0;
						block_ack_ctr <= 0;
						master_fsm <= classic_blockrd;
					end if;
				end if;
			when classic_wr =>
				if PIPELINED = '1' and wb_tom_i.stall = '0' then
					wb_tos_i.stb <= '0';
				end if;
				if wb_tom_i.ack = '1' then
					wb_tos_i.stb <= '0';
					wb_tos_i.cyc <= '0';
					ack <= '1';
					master_fsm <= idle;
				end if;
			when classic_rd =>
				if PIPELINED = '1' and wb_tom_i.stall = '0' then
					wb_tos_i.stb <= '0';
				end if;
				if wb_tom_i.ack = '1' then
					wb_tos_i.stb <= '0';
					wb_tos_i.cyc <= '0';
					chk_data_ref <= addr_to_data(addr_i);
					chk_data <= wb_tom_i.data;
					chk_en <= '1';
					ack <= '1';
					master_fsm <= idle;
				end if;

			when classic_blockwr =>
				if PIPELINED = '1' and wb_tom_i.stall = '0' then
					if block_ctr >= BLOCK_LEN-1 then
						wb_tos_i.stb <= '0';
					else
						wb_tos_i.data <= addr_to_data( std_logic_vector(unsigned(addr_i) + 4) );
						addr_i <= std_logic_vector(unsigned(addr_i) + 4);
						wb_tos_i.adr(15 downto 0) <= std_logic_vector(unsigned(addr_i) + 4);
						block_ctr <= block_ctr + 1;
					end if;
				end if;
				if wb_tom_i.ack = '1' then
					if block_ack_ctr >= BLOCK_LEN-1 then
						wb_tos_i.stb <= '0';
						wb_tos_i.cyc <= '0';
						ack <= '1';
						master_fsm <= idle;
					else
						if PIPELINED = '0' then
							wb_tos_i.data <= addr_to_data( std_logic_vector(unsigned(addr_i) + 4) );
							addr_i <= std_logic_vector(unsigned(addr_i) + 4);
							wb_tos_i.adr(15 downto 0) <= std_logic_vector(unsigned(addr_i) + 4);
						end if;
						block_ack_ctr <= block_ack_ctr + 1;
					end if;
				end if;
			when classic_blockrd =>
				if PIPELINED = '1' and wb_tom_i.stall = '0' then
					if block_ctr >= BLOCK_LEN-1 then
						wb_tos_i.stb <= '0';
					else
						addr_i <= std_logic_vector(unsigned(addr_i) + 4);
						wb_tos_i.adr(15 downto 0) <= std_logic_vector(unsigned(addr_i) + 4);
						block_ctr <= block_ctr + 1;
					end if;
				end if;
				if wb_tom_i.ack = '1' then
					addr_ri <= std_logic_vector(unsigned(addr_ri) + 4);
					chk_data_ref <= addr_to_data(addr_ri);
					chk_data <= wb_tom_i.data;
					chk_en <= '1';
					if block_ack_ctr >= BLOCK_LEN-1 then
						wb_tos_i.stb <= '0';
						wb_tos_i.cyc <= '0';
						ack <= '1';
						master_fsm <= idle;
					else
						if PIPELINED = '0' then
							wb_tos_i.data <= std_logic_vector(unsigned(addr_i) + 4) & std_logic_vector(unsigned(addr_i) + 4);
							addr_i <= std_logic_vector(unsigned(addr_i) + 4);
							wb_tos_i.adr(15 downto 0) <= std_logic_vector(unsigned(addr_i) + 4);
						end if;
						block_ack_ctr <= block_ack_ctr + 1;
					end if;
				end if;
			when others =>
				master_fsm <= idle;
			end case;

			res_ok <= '1';
			if chk_en = '1' then
				if chk_data = chk_data_ref then
					res_ok <= '1';
				else
					res_ok <= '0';
				end if;
			end if;


			if rst = '1' then
				wb_tos_i <= alpus_wb32_tos_init;
				master_fsm <= idle;
				res_ok <= '0';
			end if;
		end if;
	end process;

	wb_tos <= wb_tos_i;
	wb_tom_i <= wb_tom;

end;