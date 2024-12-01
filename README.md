# Alpus - VHDL implementation of Pipelined Wishbone B4 interconnect

Easy to use, high-performance and flexible VHDL implementation of Pipelined Wishbone B4 bus interconnect. 
Intended to provide similar easyness and funcionality to generation based tools, but without generating.

### Easy to use:
- No code generation needed, just add file ```alpus_wb32_all.vhd``` and ```use work.alpus_wb32_pkg.all```
- No learning curve or installation just to get started
- LGPL license for free usage in projects

### High performance:
- Low-latency by default
- High clock achievable using pipeline bridges
- Pipelined Wishbone supports 1 clock per transfer during block cycles

### Flexible:
- Compatible with most existing components using adapters
- Shared bus or fully parallel interconnect can be achieved by placing components accordingly

```
             _____________       ________       ____________
[master0]<->|             |     |pipeline|     |            |<->[slave0]
            |master_select| <-> |_bridge | <-> |slave_select|<->[slave1]
[master1]<->|_____________|     |________|     |____________|<->[std_slave_adapter]<->[slave2] 
```

Currently a subset of Wishbone B4 specification is supported, covering most needs. 
- **Classic cycles** only for simplicity (registered feedback burst modes not supported).
- **Pipelined** (not Standard) mode: one clock per transfer during bursts.
- **32-bit data** and address bus. Trivially modifiable for other data widths.
- **Byte addresses** for readibility. Address signal is always downto 0 and 2 LSBs are zero.
- Interconnect is so far **transparent** regarding **endianness**.

- Pipelined wishbone differentiates stall/ack for reques/resposne handskake. => word per clock transfer bursts (master addressed)


Supports a most commonly used subset of Wishbone bus: classic, block accesses. Supports accessing only one slave during a bus cycle.

Alpus Pipelined Wishbone consists of parts:

## Bus signal as VHDL record

Record types ```alpus_wb32_tos_t``` and ```alpus_wb32_tom_t``` are named according to **signal direction** 
to master (**tom**) or to slave (**tos**), simplifying signal naming. Signals are always 32 bits wide, but 
slaves can decode only the bits that are really used.

Example:
```
	use work.alpus_wb32_pkg.all;

	signal mybus_tos : alpus_wb32_tos_t;
	signal mybus_tom : alpus_wb32_tom_t;

	master0: my_master port map (
		clk => clk,
		rst => rst,
		wb_tos => mybus_tos,
		wb_tom => mybus_tom );
	slave0: alpus_wb_test_slave port map (
		clk => clk,
		rst => rst,
		wb_tos => mybus_tos,
		wb_tom => mybus_tom );
```
## Bus interconnect de/multiplexing

- **Master select** component (**alpus_wb_master_select**) is used to connect multiple masters to one slave. Implemented 
as combinatorial VHDL entity (registers only for arbitration state).

- Simple **Slave select** functions (**alpus_wb32_slave_select_tos**, **alpus_wb32_slave_select_tom**) used to connect multiple slaves 
to one master. This is a combinatorial VHDL function selecting a slave based on address and 
mask. Use alpus_wb32_slave_select_tom to select between two slaves. It can be nested, but you may need to balance it manually.
NOTE: this doesn't support addressing multiple slaves in one bus cycle. 

- Full **Slave select** component TBD

- **Address translation** can be implemented by trivial VHDL expressions.

A complete interconnect is built from these blocks. You can connect all masters to a single shared bus and then connect the shared bus
to slaves. Or you can have one slave_select for each master and one master_select for each slave, enabling full parallel accesses.

Example connecting two masters to a shared bus, and the bus to three slaves:
```
	-- Connect the masters to shared master_common_tos/tom bus
	master_sel: alpus_wb_master_select generic map (
		NUM_MASTERS => 2
	) port map (
		clk => clk,
		rst => rst,
		master_side_tos(0) => master0_tos,
		master_side_tos(1) => master1_tos,
		master_side_tom(0) => master0_tom,
		master_side_tom(1) => master1_tom,
		slave_side_tos => master_common_tos,
		slave_side_tom => master_common_tom );

	-- Connect the slaves to the shared bus, mapping each slave to their addresses with mask
	slave0_tos <= alpus_wb32_slave_select_tos(x"00000000", x"0000f000", master_common_tos);
	slave1_tos <= alpus_wb32_slave_select_tos(x"00001000", x"0000f000", master_common_tos);
	slave2_tos <= alpus_wb32_slave_select_tos(x"00002000", x"0000f000", master_common_tos);
	master_common_tom <= alpus_wb32_slave_select_tom(x"00000000", x"0000f000", master_common_tos, slave0_tom,
		                 alpus_wb32_slave_select_tom(x"00001000", x"0000f000", master_common_tos, slave1_tom, slave2_tom) );
```
## Pipeline bridges and adapters

- **Pipeline bridges** (alpus_wb_pipeline_bridge) can be added anywhere to break long combinatorial paths. They add latency but
increase clock frequency. Which path to pipeline is set by generics. Note that registering the stall line adds wait states!

```
	bridge: alpus_wb_pipeline_bridge generic map (
		REG_REQUEST => '0',
		REG_STALL => '1',
		REG_RESPONSE => '0'
	) port map (
		clk => clk,
		rst => rst,
		master_side_tos => master_tos,
		master_side_tom => master_tom,
		slave_side_tos => slave_tos,
		slave_side_tom => slave_tom );
```
- Adapter for std/pipelined (alpus_wb_std_slave_adapter, alpus_wb_std_master_adapter) (TODO)
- CDC bridge (alpus_wb_cdc_bridge) (TODO) for clock domain crossing
- Adapter for bus width (TODO)
- Adapter for avalon/axi etc buses (TODO)

## Pipelined Wishbone in nutshell:

- Cyc is high for whole full burst access from first stb to last ack. Needs to go down between cycles for multi-mastered buses.
- Transfer request happens when stb is high and stall low (addr/data/we)
  => master may delay transfers by deasserting stb and slave by asserting stall
- Response for both read an write happens when ack is active
- Block or RMW transfers: multiple stb accesses (R-R/R-W/W-R) under one cyc are atomic 
- "Registered feedback" cycle is needed for pre-known bursts
- Classic vs Pipelined mode: classic mode leaves stb high until ack, in pipelined mode new stb cycles would start 
another pipelined access even if ack has not yet arrived
- Specification available at https://cdn.opencores.org/downloads/wbspec_b4.pdf

## Example design

TBD