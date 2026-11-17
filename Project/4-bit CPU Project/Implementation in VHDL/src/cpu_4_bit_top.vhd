-- Controls:
--   SW0  = auto-run enable
--   BTNC = reset
--   BTNU = manual single-step
--
-- LED outputs:
--   LED0  to LED3   = accumulator
--   LED4  to LED7   = program counter
--   LED8  to LED11  = current instruction
--   LED12           = carry/borrow flag
--   LED13           = signed overflow flag
--   LED14           = zero flag
--   LED15           = auto-run switch status
--
-- Seven-segment display:
--   Four rightmost digits are multiplexed using the existing display pins.
--   AN0 = ACC
--   AN1 = PC
--   AN2 = instruction
--   AN3 = flags as one hex value: 0 C O Z
--------------------------------------------------------------------------------

library IEEE;                       
use IEEE.STD_LOGIC_1164.ALL;         
use IEEE.NUMERIC_STD.ALL;            -- Provides unsigned counter arithmetic for display multiplexing.

entity cpu4_top is                   
    port(                            
        clk_100mhz : in  std_logic;  -- 100 MHz board clock input.
        sw         : in  std_logic_vector(15 downto 0); -- Board switches. Only SW0 is used for auto-run.
        btnC       : in  std_logic;  -- Center push button used as reset.
        btnU       : in  std_logic;  -- Up push button used as manual step.
        led        : out std_logic_vector(15 downto 0); -- Board LEDs used for CPU debug output.
        seg        : out std_logic_vector(6 downto 0);  -- Seven-segment segment outputs, active-low.
        an         : out std_logic_vector(7 downto 0);  -- Seven-segment anode enables, active-low.
        dp         : out std_logic                      -- Decimal point output, active-low.
    );
end cpu4_top;                        

architecture rtl of cpu4_top is      

    signal reset_signal : std_logic; -- Internal reset signal connected to BTNC.
    signal slow_tick    : std_logic; -- One-cycle tick from the clock divider for auto-run mode.
    signal manual_tick  : std_logic; -- One-cycle tick from the debounced manual step button.
    signal step_signal  : std_logic; -- Final CPU step pulse: manual step OR auto-run tick.

    signal acc_value    : std_logic_vector(3 downto 0); -- CPU accumulator output.
    signal pc_value     : std_logic_vector(3 downto 0); -- CPU program counter output.
    signal instr_value  : std_logic_vector(3 downto 0); -- CPU current instruction output.
    signal ram0_value   : std_logic_vector(3 downto 0); -- CPU RAM[0] debug output.
    signal ram1_value   : std_logic_vector(3 downto 0); -- CPU RAM[1] debug output.
    signal ram2_value   : std_logic_vector(3 downto 0); -- CPU RAM[2] debug output.
    signal ram3_value   : std_logic_vector(3 downto 0); -- CPU RAM[3] debug output.

    signal carry_flag    : std_logic; -- Carry/borrow flag from CPU core.
    signal overflow_flag : std_logic; -- Signed overflow flag from CPU core.
    signal zero_flag     : std_logic; -- Zero flag from CPU core.

    signal display_counter : unsigned(18 downto 0) := (others => '0'); -- Refresh counter for display scanning.
    signal digit_select    : std_logic_vector(1 downto 0);             -- Selects which of four digits is currently active.
    signal display_value   : std_logic_vector(3 downto 0);             -- Nibble sent into the hex seven-segment decoder.
    signal flags_value     : std_logic_vector(3 downto 0);             -- Packed flag value shown on one display digit.

begin

    reset_signal <= btnC; -- BTNC is used directly as synchronous reset for all internal modules.

    -- Clock divider instance
    slow_clock_unit: entity work.clock_divider
        generic map(
            DIVISOR => 100000000 -- 100,000,000 cycles at 100 MHz gives about one tick per second.
        )
        port map(
            clk   => clk_100mhz,  -- Divider counts the real board clock.
            reset => reset_signal,-- Reset clears the divider counter.
            tick  => slow_tick    -- Tick is used for automatic CPU stepping.
        );

    -- Button pulse instance
    manual_step_unit: entity work.button_pulse
        generic map(
            DEBOUNCE_MAX => 2000000 -- About 20 ms at 100 MHz, enough for push-button debouncing.
        )
        port map(
            clk       => clk_100mhz,  -- Debouncer uses the board clock.
            reset     => reset_signal,-- Reset clears the debouncer state.
            button_in => btnU,        -- BTNU is the manual step input.
            pulse_out => manual_tick  -- One clean one-clock pulse is generated after a stable press.
        );

    step_signal <= manual_tick or (slow_tick and sw(0)); -- SW0 enables auto-run; BTNU can always single-step.

    -- CPU core instance.
    cpu_unit: entity work.cpu4_core
        port map(
            clk          => clk_100mhz,   -- CPU registers use the 100 MHz clock.
            reset        => reset_signal, -- Reset restarts the ROM demo.
            step_enable  => step_signal,  -- One pulse executes one CPU instruction.
            acc_out      => acc_value,    -- ACC is exported for LEDs/display.
            pc_out       => pc_value,     -- PC is exported for LEDs/display.
            instr_out    => instr_value,  -- Current instruction is exported for LEDs/display.
            ram0_out     => ram0_value,   -- RAM[0] is kept available for debug/documentation.
            ram1_out     => ram1_value,   -- RAM[1] is kept available for debug/documentation.
            ram2_out     => ram2_value,   -- RAM[2] is kept available for debug/documentation.
            ram3_out     => ram3_value,   -- RAM[3] is kept available for debug/documentation.
            carry_out    => carry_flag,   -- Carry/borrow flag is exported.
            overflow_out => overflow_flag,-- Overflow flag is exported.
            zero_out     => zero_flag     -- Zero flag is exported.
        );

    -- Display refresh counter.
    process(clk_100mhz)
    begin
        if rising_edge(clk_100mhz) then              -- Counter updates on real clock edges.
            if reset_signal = '1' then               -- Reset starts display scanning from a known state.
                display_counter <= (others => '0');  -- Clear counter during reset.
            else
                display_counter <= display_counter + 1; -- Free-running counter drives multiplexing speed.
            end if;
        end if;
    end process;

    digit_select <= std_logic_vector(display_counter(18 downto 17)); -- Slow upper bits select one of four digits.
    flags_value  <= '0' & carry_flag & overflow_flag & zero_flag;    -- Pack flags as binary 0COZ for hex display.

    -- Seven-segment digit selector.
    process(digit_select, acc_value, pc_value, instr_value, flags_value)
    begin
        case digit_select is
            when "00" =>
                display_value <= acc_value;  -- Rightmost digit shows ACC.
                an <= "11111110";            -- Enable AN0 only, active-low.
            when "01" =>
                display_value <= pc_value;   -- Next digit shows PC.
                an <= "11111101";            -- Enable AN1 only, active-low.
            when "10" =>
                display_value <= instr_value;-- Next digit shows current instruction opcode.
                an <= "11111011";            -- Enable AN2 only, active-low.
            when others =>
                display_value <= flags_value;-- Next digit shows flags as 0COZ.
                an <= "11110111";            -- Enable AN3 only, active-low.
        end case;
    end process;

    -- Seven-segment decoder instance.
    display_unit: entity work.sevenseg_hex
        port map(
            value => display_value, -- Current selected nibble: ACC, PC, instruction, or flags.
            seg   => seg            
        );

    led(3 downto 0)   <= acc_value;      -- LEDs 0..3 show the accumulator.
    led(7 downto 4)   <= pc_value;       -- LEDs 4..7 show the program counter.
    led(11 downto 8)  <= instr_value;    -- LEDs 8..11 show the current instruction.
    led(14)           <= carry_flag;     -- LED12 shows carry/borrow flag.
    led(13)           <= overflow_flag;  -- LED13 shows signed overflow flag.
    led(12)           <= zero_flag;      -- LED14 shows zero flag.
    led(15)           <= sw(0);          -- LED15 shows whether auto-run mode is enabled.

    dp <= '1'; -- Decimal point is turned off 

end rtl; 
