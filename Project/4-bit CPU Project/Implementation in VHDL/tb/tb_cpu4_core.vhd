--------------------------------------------------------------------------------
-- File: tb_cpu4_core.vhd
-- Purpose:
--   Testbench for the 4-bit CPU core. It proves that the ROM program, RAM,
--   accumulator, program counter, instruction register, and the three flags work
--   as expected before the design is loaded onto the FPGA board.
--------------------------------------------------------------------------------

library IEEE;                       
use IEEE.STD_LOGIC_1164.ALL;          

entity tb_cpu4_core is               
end tb_cpu4_core;                     

architecture sim of tb_cpu4_core is  

    signal clk         : std_logic := '0'; -- Simulated clock signal.
    signal reset       : std_logic := '0'; -- Simulated reset signal.
    signal step_enable : std_logic := '0'; -- Simulated CPU step pulse.

    signal acc_out      : std_logic_vector(3 downto 0); -- Observed accumulator from DUT.
    signal pc_out       : std_logic_vector(3 downto 0); -- Observed program counter from DUT.
    signal instr_out    : std_logic_vector(3 downto 0); -- Observed instruction register from DUT.
    signal ram0_out     : std_logic_vector(3 downto 0); -- Observed RAM[0] from DUT.
    signal ram1_out     : std_logic_vector(3 downto 0); -- Observed RAM[1] from DUT.
    signal ram2_out     : std_logic_vector(3 downto 0); -- Observed RAM[2] from DUT.
    signal ram3_out     : std_logic_vector(3 downto 0); -- Observed RAM[3] from DUT.
    signal carry_out    : std_logic;                    -- Observed carry/borrow flag from DUT.
    signal overflow_out : std_logic;                    -- Observed signed overflow flag from DUT.
    signal zero_out     : std_logic;                    -- Observed zero flag from DUT.

    constant CLK_PERIOD : time := 10 ns; -- 10 ns period represents a 100 MHz board clock.

    -- Procedure used to execute exactly one CPU instruction in simulation.
    procedure do_step(signal step_signal : out std_logic) is
    begin
        step_signal <= '1';             -- Make step_enable high so the CPU executes on next rising clock edge.
        wait for CLK_PERIOD;            -- Keep it high for one full clock period.
        step_signal <= '0';             -- Return step_enable low to prevent extra instruction execution.
        wait for CLK_PERIOD;            -- Wait one extra period so outputs are stable before assertions.
    end procedure;

begin

    clk <= not clk after CLK_PERIOD / 2; -- Clock generator toggles every half period to make a full clock.

    -- Device Under Test.
    dut: entity work.cpu4_core
        port map(
            clk          => clk,          -- Testbench clock drives CPU core.
            reset        => reset,        -- Testbench reset restarts CPU core.
            step_enable  => step_enable,  -- Testbench step pulse executes instructions.
            acc_out      => acc_out,      -- Observe accumulator.
            pc_out       => pc_out,       -- Observe program counter.
            instr_out    => instr_out,    -- Observe instruction register.
            ram0_out     => ram0_out,     -- Observe RAM[0].
            ram1_out     => ram1_out,     -- Observe RAM[1].
            ram2_out     => ram2_out,     -- Observe RAM[2].
            ram3_out     => ram3_out,     -- Observe RAM[3].
            carry_out    => carry_out,    -- Observe carry/borrow flag.
            overflow_out => overflow_out, -- Observe signed overflow flag.
            zero_out     => zero_out      -- Observe zero flag.
        );

    stimulus: process                     -- Main simulation sequence.
    begin
        reset <= '1';                      -- Put CPU into reset state.
        wait for 3 * CLK_PERIOD;           -- Hold reset long enough for several clock edges.
        reset <= '0';                      -- Release reset so CPU can execute.
        wait for CLK_PERIOD;               -- Wait for outputs to settle after reset.

        -- Initial state checks.
        assert acc_out = "0000" report "Reset failed: ACC should start at 0" severity error;
        assert pc_out = "0000" report "Reset failed: PC should start at 0" severity error;
        assert carry_out = '0' report "Reset failed: carry should start at 0" severity error;
        assert overflow_out = '0' report "Reset failed: overflow should start at 0" severity error;
        assert zero_out = '1' report "Reset failed: zero should start at 1 because ACC is 0" severity error;
        assert ram0_out = "0111" report "RAM0 should start with 7" severity error;
        assert ram1_out = "0001" report "RAM1 should start with 1" severity error;
        assert ram2_out = "1000" report "RAM2 should start with 8" severity error;
        assert ram3_out = "1111" report "RAM3 should start with F" severity error;

        -- 1) LOAD RAM[0] -> ACC = 7.
        do_step(step_enable);
        assert instr_out = "0000" report "Step 1 failed: instruction should be LOAD RAM0" severity error;
        assert acc_out = "0111" report "Step 1 failed: ACC should be 7" severity error;
        assert pc_out = "0001" report "PC after step 1 should be 1" severity error;
        assert carry_out = '0' report "Step 1 failed: LOAD should clear carry" severity error;
        assert overflow_out = '0' report "Step 1 failed: LOAD should clear overflow" severity error;
        assert zero_out = '0' report "Step 1 failed: ACC is not zero" severity error;

        -- 2) ADD RAM[1] -> 7 + 1 = 8. In signed 4-bit arithmetic this overflows.
        do_step(step_enable);
        assert instr_out = "0001" report "Step 2 failed: instruction should be ADD RAM1" severity error;
        assert acc_out = "1000" report "Step 2 failed: ACC should be 8" severity error;
        assert pc_out = "0010" report "PC after step 2 should be 2" severity error;
        assert carry_out = '0' report "Step 2 failed: 7 + 1 has no unsigned carry" severity error;
        assert overflow_out = '1' report "Step 2 failed: 7 + 1 should set signed overflow" severity error;
        assert zero_out = '0' report "Step 2 failed: ACC is not zero" severity error;

        -- 3) SUB RAM[2] -> 8 - 8 = 0. This demonstrates the zero flag.
        do_step(step_enable);
        assert instr_out = "0010" report "Step 3 failed: instruction should be SUB RAM2" severity error;
        assert acc_out = "0000" report "Step 3 failed: ACC should be 0" severity error;
        assert pc_out = "0011" report "PC after step 3 should be 3" severity error;
        assert carry_out = '0' report "Step 3 failed: 8 - 8 should not need borrow" severity error;
        assert overflow_out = '0' report "Step 3 failed: 8 - 8 should not overflow" severity error;
        assert zero_out = '1' report "Step 3 failed: zero flag should be 1" severity error;

        -- 4) INVERT -> ACC = F.
        do_step(step_enable);
        assert instr_out = "0100" report "Step 4 failed: instruction should be INVERT" severity error;
        assert acc_out = "1111" report "Step 4 failed: ACC should be F" severity error;
        assert pc_out = "0100" report "PC after step 4 should be 4" severity error;
        assert carry_out = '0' report "Step 4 failed: INVERT should clear carry" severity error;
        assert overflow_out = '0' report "Step 4 failed: INVERT should clear overflow" severity error;
        assert zero_out = '0' report "Step 4 failed: ACC is not zero" severity error;

        -- 5) ADD RAM[1] -> F + 1 = 0 with carry. This demonstrates carry and zero together.
        do_step(step_enable);
        assert instr_out = "0001" report "Step 5 failed: instruction should be ADD RAM1" severity error;
        assert acc_out = "0000" report "Step 5 failed: ACC should wrap to 0" severity error;
        assert pc_out = "0101" report "PC after step 5 should be 5" severity error;
        assert carry_out = '1' report "Step 5 failed: F + 1 should set carry" severity error;
        assert overflow_out = '0' report "Step 5 failed: F + 1 should not set signed overflow" severity error;
        assert zero_out = '1' report "Step 5 failed: zero flag should be 1" severity error;

        -- 6) LOAD RAM[0] -> ACC = 7 again.
        do_step(step_enable);
        assert instr_out = "0000" report "Step 6 failed: instruction should be LOAD RAM0" severity error;
        assert acc_out = "0111" report "Step 6 failed: ACC should be 7" severity error;
        assert pc_out = "0110" report "PC after step 6 should be 6" severity error;
        assert carry_out = '0' report "Step 6 failed: LOAD should clear carry" severity error;
        assert overflow_out = '0' report "Step 6 failed: LOAD should clear overflow" severity error;
        assert zero_out = '0' report "Step 6 failed: ACC is not zero" severity error;

        -- 7) AND RAM[3] -> 7 AND F = 7.
        do_step(step_enable);
        assert instr_out = "0011" report "Step 7 failed: instruction should be AND RAM3" severity error;
        assert acc_out = "0111" report "Step 7 failed: ACC should stay 7" severity error;
        assert pc_out = "0111" report "PC after step 7 should be 7" severity error;
        assert carry_out = '0' report "Step 7 failed: AND should clear carry" severity error;
        assert overflow_out = '0' report "Step 7 failed: AND should clear overflow" severity error;
        assert zero_out = '0' report "Step 7 failed: ACC is not zero" severity error;

        -- 8) STORE RAM[0] -> RAM0 remains 7, ACC remains 7.
        do_step(step_enable);
        assert instr_out = "0111" report "Step 8 failed: instruction should be STORE RAM0" severity error;
        assert acc_out = "0111" report "Step 8 failed: STORE should not change ACC" severity error;
        assert ram0_out = "0111" report "Step 8 failed: RAM0 should contain 7" severity error;
        assert pc_out = "1000" report "PC after step 8 should be 8" severity error;

        -- 9) SHIFT LEFT -> 7 becomes E.
        do_step(step_enable);
        assert instr_out = "0101" report "Step 9 failed: instruction should be SHIFT LEFT" severity error;
        assert acc_out = "1110" report "Step 9 failed: ACC should be E" severity error;
        assert pc_out = "1001" report "PC after step 9 should be 9" severity error;
        assert carry_out = '0' report "Step 9 failed: shifting 7 left should shift out 0" severity error;
        assert overflow_out = '0' report "Step 9 failed: shift clears overflow" severity error;
        assert zero_out = '0' report "Step 9 failed: ACC is not zero" severity error;

        -- 10) SHIFT RIGHT -> E becomes 7.
        do_step(step_enable);
        assert instr_out = "0110" report "Step 10 failed: instruction should be SHIFT RIGHT" severity error;
        assert acc_out = "0111" report "Step 10 failed: ACC should be 7" severity error;
        assert pc_out = "1010" report "PC after step 10 should be A" severity error;
        assert carry_out = '0' report "Step 10 failed: shifting E right should shift out 0" severity error;
        assert overflow_out = '0' report "Step 10 failed: shift clears overflow" severity error;
        assert zero_out = '0' report "Step 10 failed: ACC is not zero" severity error;

        -- 11) JUMP START -> PC returns to 0. ACC remains 7.
        do_step(step_enable);
        assert instr_out = "1000" report "Step 11 failed: instruction should be JUMP" severity error;
        assert acc_out = "0111" report "Step 11 failed: JUMP should not change ACC" severity error;
        assert pc_out = "0000" report "Step 11 failed: PC should jump to 0" severity error;

        -- Repeat check: the first instruction should run again correctly.
        do_step(step_enable);
        assert instr_out = "0000" report "Repeat failed: instruction should be LOAD RAM0" severity error;
        assert acc_out = "0111" report "Repeat failed: ACC should load RAM0 again" severity error;
        assert pc_out = "0001" report "Repeat failed: PC should be 1" severity error;

        report "Simulation finished successfully. CPU ROM, RAM, ALU, flags, PC, and IR work." severity note;
        wait; -- Stop stimulus process while simulator keeps final waveform available.
    end process;

end sim; 
