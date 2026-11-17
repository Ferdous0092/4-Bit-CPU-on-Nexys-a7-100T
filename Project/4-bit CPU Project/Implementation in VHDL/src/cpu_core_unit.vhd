--------------------------------------------------------------------------------
-- File: cpu4_core_unit.vhd
-- CPU structure kept simple on purpose:
--   1. Program Counter  : selects the next instruction address in ROM.
--   2. ROM              : stores the preprogrammed demonstration program.
--   3. Instruction Reg. : shows the instruction that was fetched.
--   4. Accumulator      : main 4-bit working register of the CPU.
--   5. RAM              : small 4 x 4-bit data memory.
--   6. ALU              : performs add, subtract, AND, invert, shift left/right.
--   7. Flags            : carry/borrow, signed overflow, and zero.
-- Updated demo program:
--   RAM[0] = 0111 = 7
--   RAM[1] = 0001 = 1
--   RAM[2] = 1000 = 8
--   RAM[3] = 1111 = F
--
--   Address  Instruction   Result / teaching purpose
--   0        LOAD RAM[0]   ACC = 7
--   1        ADD  RAM[1]   ACC = 8, signed overflow flag becomes 1
--   2        SUB  RAM[2]   ACC = 0, zero flag becomes 1
--   3        INVERT        ACC = F
--   4        ADD  RAM[1]   ACC = 0, carry flag and zero flag become 1
--   5        LOAD RAM[0]   ACC = 7 again
--   6        AND  RAM[3]   ACC stays 7 because RAM[3] is F
--   7        STORE RAM[0]  Stores ACC back to RAM[0] without changing it
--   8        SHIFT LEFT    ACC = E
--   9        SHIFT RIGHT   ACC = 7
--   A        JUMP START    PC returns to address 0
--------------------------------------------------------------------------------

library IEEE;                         
use IEEE.STD_LOGIC_1164.ALL;          
use IEEE.NUMERIC_STD.ALL;             

entity cpu4_core is                   
    port(                           
        clk          : in  std_logic; -- System clock. CPU registers update on the rising edge.
        reset        : in  std_logic; -- Synchronous reset. It returns PC, ACC, flags, and RAM to demo start values.
        step_enable  : in  std_logic; -- One-cycle enable. When high, the CPU executes one instruction.

        acc_out      : out std_logic_vector(3 downto 0); -- Shows the accumulator on the top level.
        pc_out       : out std_logic_vector(3 downto 0); -- Shows the program counter on the top level.
        instr_out    : out std_logic_vector(3 downto 0); -- Shows the currently fetched instruction.
        ram0_out     : out std_logic_vector(3 downto 0); -- Debug output for RAM location 0.
        ram1_out     : out std_logic_vector(3 downto 0); -- Debug output for RAM location 1.
        ram2_out     : out std_logic_vector(3 downto 0); -- Debug output for RAM location 2.
        ram3_out     : out std_logic_vector(3 downto 0); -- Debug output for RAM location 3.
        carry_out    : out std_logic;                    -- Carry/borrow flag output for LEDs/display.
        overflow_out : out std_logic;                    -- Signed overflow flag output for LEDs/display.
        zero_out     : out std_logic                     -- Zero flag output for LEDs/display.
    );
end cpu4_core;                       

architecture rtl of cpu4_core is      

    subtype word4 is std_logic_vector(3 downto 0); 

    constant INS_LOAD_R0  : word4 := "0000"; -- Load RAM[0] into the accumulator.
    constant INS_ADD_R1   : word4 := "0001"; -- Add RAM[1] to the accumulator.
    constant INS_SUB_R2   : word4 := "0010"; -- Subtract RAM[2] from the accumulator.
    constant INS_AND_R3   : word4 := "0011"; -- AND accumulator with RAM[3].
    constant INS_INVERT   : word4 := "0100"; -- Invert all accumulator bits.
    constant INS_SHL      : word4 := "0101"; -- Shift accumulator left by one bit.
    constant INS_SHR      : word4 := "0110"; -- Shift accumulator right by one bit.
    constant INS_STORE_R0 : word4 := "0111"; -- Store accumulator into RAM[0].
    constant INS_JUMP     : word4 := "1000"; -- Jump back to ROM address 0.

    type ram_type is array (0 to 3) of word4; -- RAM has four addresses, each storing one 4-bit word.

    signal pc_reg       : word4 := (others => '0'); -- Program counter register holds the next ROM address.
    signal instr_reg    : word4 := (others => '0'); -- Instruction register holds the instruction just fetched.
    signal acc_reg      : word4 := (others => '0'); -- Accumulator register is the main CPU working register.
    signal carry_reg    : std_logic := '0';         -- Carry/borrow flag register.
    signal overflow_reg : std_logic := '0';         -- Signed overflow flag register.
    signal zero_reg     : std_logic := '1';         -- Zero flag is 1 after reset because ACC starts at 0000.

    signal ram_reg : ram_type := (                  -- Internal RAM values used by the demo program.
        0 => "0111",                                -- RAM[0] stores 7 for LOAD and STORE demonstration.
        1 => "0001",                                -- RAM[1] stores 1 to trigger overflow/carry examples.
        2 => "1000",                                -- RAM[2] stores 8 so 8 - 8 produces zero.
        3 => "1111"                                 -- RAM[3] stores F so AND keeps the accumulator unchanged.
    );

    -- ROM read function.
    function rom_read(address : word4) return word4 is
    begin
        case address is
            when "0000" => return INS_LOAD_R0;  -- Program address 0: load the first demo value.
            when "0001" => return INS_ADD_R1;   -- Program address 1: show signed overflow with 7 + 1.
            when "0010" => return INS_SUB_R2;   -- Program address 2: show zero with 8 - 8.
            when "0011" => return INS_INVERT;   -- Program address 3: create F from 0.
            when "0100" => return INS_ADD_R1;   -- Program address 4: show carry with F + 1.
            when "0101" => return INS_LOAD_R0;  -- Program address 5: restore ACC to 7 for later demo steps.
            when "0110" => return INS_AND_R3;   -- Program address 6: demonstrate logical AND.
            when "0111" => return INS_STORE_R0; -- Program address 7: demonstrate RAM write.
            when "1000" => return INS_SHL;      -- Program address 8: demonstrate shift left.
            when "1001" => return INS_SHR;      -- Program address 9: demonstrate shift right.
            when "1010" => return INS_JUMP;     -- Program address A: repeat the ROM program.
            when others => return INS_JUMP;      -- Any unused ROM address safely jumps back to start.
        end case;
    end function;

begin

    -- Main CPU sequential process.
    process(clk)
        variable current_instr : word4;                 -- Local copy of the fetched ROM instruction.
        variable next_acc      : word4;                 -- Local next accumulator value before writing to acc_reg.
        variable add_result    : unsigned(4 downto 0);  -- 5-bit ADD result keeps the carry bit.
        variable borrow_bit    : std_logic;             -- Local borrow information for subtraction.
        variable next_carry    : std_logic;             -- Local next carry flag value.
        variable next_overflow : std_logic;             -- Local next overflow flag value.
        variable next_zero     : std_logic;             -- Local next zero flag value.
    begin
        if rising_edge(clk) then                        -- Rising edge gives real flip-flop behavior in FPGA.
            if reset = '1' then                         -- Reset brings the CPU back to a known demo start state.
                pc_reg       <= (others => '0');        -- Start execution from ROM address 0.
                instr_reg    <= (others => '0');        -- Clear the visible instruction register.
                acc_reg      <= (others => '0');        -- Clear accumulator to 0000.
                carry_reg    <= '0';                    -- No carry after reset.
                overflow_reg <= '0';                    -- No overflow after reset.
                zero_reg     <= '1';                    -- ACC is zero after reset, so zero flag is active.

                ram_reg(0) <= "0111";                   -- Reload RAM[0] with 7 for the ROM demo.
                ram_reg(1) <= "0001";                   -- Reload RAM[1] with 1 for ADD tests.
                ram_reg(2) <= "1000";                   -- Reload RAM[2] with 8 for SUB-to-zero test.
                ram_reg(3) <= "1111";                   -- Reload RAM[3] with F for AND test.

            elsif step_enable = '1' then                -- Execute exactly one instruction when a step pulse arrives.
                current_instr := rom_read(pc_reg);       -- FETCH: read instruction from ROM using current PC.
                instr_reg <= current_instr;              -- Store fetched instruction for LEDs/debug display.

                next_acc      := acc_reg;                -- Default: keep accumulator unchanged unless instruction changes it.
                next_carry    := carry_reg;              -- Default: keep carry unchanged for memory/control instructions.
                next_overflow := overflow_reg;           -- Default: keep overflow unchanged for memory/control instructions.
                next_zero     := zero_reg;               -- Default: keep zero unchanged for memory/control instructions.
                borrow_bit    := '0';                    -- Default: no subtraction borrow.

                -- DECODE + EXECUTE:
                case current_instr is
                    when INS_LOAD_R0 =>
                        next_acc      := ram_reg(0);     -- LOAD copies RAM[0] into the accumulator.
                        next_carry    := '0';            -- LOAD is not arithmetic, so carry is cleared.
                        next_overflow := '0';            -- LOAD cannot create signed overflow.

                    when INS_ADD_R1 =>
                        add_result := resize(unsigned(acc_reg), 5) + resize(unsigned(ram_reg(1)), 5); -- 5-bit sum keeps carry-out.
                        next_acc   := std_logic_vector(add_result(3 downto 0));                 -- Lower 4 bits become new ACC.
                        next_carry := add_result(4);                                             -- Bit 4 is the carry flag.
                        if (acc_reg(3) = ram_reg(1)(3)) and (next_acc(3) /= acc_reg(3)) then     -- Signed overflow test for ADD.
                            next_overflow := '1';
                        else
                            next_overflow := '0';
                        end if;

                    when INS_SUB_R2 =>
                        if unsigned(acc_reg) < unsigned(ram_reg(2)) then -- If ACC is smaller, subtraction needs a borrow.
                            borrow_bit := '1';
                        else
                            borrow_bit := '0';
                        end if;
                        next_acc   := std_logic_vector(unsigned(acc_reg) - unsigned(ram_reg(2))); -- 4-bit subtraction wraps naturally.
                        next_carry := borrow_bit;                                                 -- In this CPU, carry LED also shows SUB borrow.
                        if (acc_reg(3) /= ram_reg(2)(3)) and (next_acc(3) /= acc_reg(3)) then     -- Signed overflow test for SUB.
                            next_overflow := '1';
                        else
                            next_overflow := '0';
                        end if;

                    when INS_AND_R3 =>
                        next_acc      := acc_reg and ram_reg(3); -- AND is a logical ALU operation.
                        next_carry    := '0';                    -- Logical operation does not create carry.
                        next_overflow := '0';                    -- Logical operation does not create signed overflow.

                    when INS_INVERT =>
                        next_acc      := not acc_reg; -- INVERT flips every accumulator bit.
                        next_carry    := '0';         -- Bitwise operation does not create carry.
                        next_overflow := '0';         -- Bitwise operation does not create signed overflow.

                    when INS_SHL =>
                        next_acc      := acc_reg(2 downto 0) & '0'; -- Shift left inserts 0 at the right side.
                        next_carry    := acc_reg(3);                -- Old MSB is the bit shifted out.
                        next_overflow := '0';                       -- Shift operation keeps overflow simple and cleared.

                    when INS_SHR =>
                        next_acc      := '0' & acc_reg(3 downto 1); -- Shift right inserts 0 at the left side.
                        next_carry    := acc_reg(0);                -- Old LSB is the bit shifted out.
                        next_overflow := '0';                       -- Shift operation keeps overflow simple and cleared.

                    when INS_STORE_R0 =>
                        ram_reg(0) <= acc_reg; -- STORE writes the accumulator into RAM[0]. Flags stay unchanged.

                    when INS_JUMP =>
                        null; -- JUMP only changes the PC below. ACC, RAM, and flags stay unchanged.

                    when others =>
                        null; -- Safety case; unused instruction does nothing.
                end case;

               
                if (current_instr /= INS_STORE_R0) and (current_instr /= INS_JUMP) then -- Memory instructions keep the old zero flag.
                    if next_acc = "0000" then       -- Zero flag is based on the value that will be written to ACC.
                        next_zero := '1';
                    else
                        next_zero := '0';            -- ACC-changing instruction produced a nonzero result.
                    end if;
                end if;

                acc_reg      <= next_acc;        -- Store the final ALU/load result in ACC.
                carry_reg    <= next_carry;      -- Store the carry/borrow flag.
                overflow_reg <= next_overflow;   -- Store the signed overflow flag.
                zero_reg     <= next_zero;       -- Store the zero flag.

                if current_instr = INS_JUMP then -- PC control: JUMP restarts the ROM demo.
                    pc_reg <= "0000";            -- Jump target is address 0.
                else
                    pc_reg <= std_logic_vector(unsigned(pc_reg) + 1); -- Normal instruction flow: PC = PC + 1.
                end if;
            end if;
        end if;
    end process;

    acc_out      <= acc_reg;      -- Connect internal ACC to output port.
    pc_out       <= pc_reg;       -- Connect internal PC to output port.
    instr_out    <= instr_reg;    -- Connect internal instruction register to output port.
    ram0_out     <= ram_reg(0);   -- Connect RAM[0] to output port for debugging.
    ram1_out     <= ram_reg(1);   -- Connect RAM[1] to output port for debugging.
    ram2_out     <= ram_reg(2);   -- Connect RAM[2] to output port for debugging.
    ram3_out     <= ram_reg(3);   -- Connect RAM[3] to output port for debugging.
    carry_out    <= carry_reg;    -- Connect carry flag to output port.
    overflow_out <= overflow_reg; -- Connect overflow flag to output port.
    zero_out     <= zero_reg;     -- Connect zero flag to output port.

end rtl;                       
