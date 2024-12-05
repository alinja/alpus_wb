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

end;