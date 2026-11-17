--------------------------------------------------------------------------------
-- File: button_pulse.vhd
-- Purpose:
--   A mechanical push button does not switch cleanly. 
--------------------------------------------------------------------------------

library IEEE;                         
use IEEE.STD_LOGIC_1164.ALL;          
use IEEE.NUMERIC_STD.ALL;             

entity button_pulse is                
    generic(                         
        DEBOUNCE_MAX : natural := 2000000 -- About 20 ms at 100 MHz.
    );
    port(                             -- Port list defines the block connections.
        clk       : in  std_logic;    -- System clock used for synchronization and debounce timing.
        reset     : in  std_logic;    -- Reset clears synchronizer, debounce state, and output pulse.
        button_in : in  std_logic;    -- Raw push-button signal from the board.
        pulse_out : out std_logic     -- Clean one-cycle pulse after a stable button press.
    );
end button_pulse;                     

architecture rtl of button_pulse is   
    signal sync_1       : std_logic := '0';                 -- First synchronizer flip-flop.
    signal sync_2       : std_logic := '0';                 -- Second synchronizer flip-flop, safer for FPGA clock domain.
    signal stable_state : std_logic := '0';                 -- Last accepted stable button value.
    signal last_state   : std_logic := '0';                 -- Previous stable value, used for edge detection.
    signal counter      : natural range 0 to DEBOUNCE_MAX := 0; -- Counts how long the input stayed different.
begin

    process(clk)                                             
    begin
        if rising_edge(clk) then                             -- All internal states update on clock edges.
            if reset = '1' then                              -- Reset returns the button logic to idle.
                sync_1       <= '0';                         -- Clear first synchronizer stage.
                sync_2       <= '0';                         -- Clear second synchronizer stage.
                stable_state <= '0';                         -- Treat button as released after reset.
                last_state   <= '0';                         -- Clear previous state for edge detection.
                counter      <= 0;                           -- Restart debounce counter.
                pulse_out    <= '0';                         -- No pulse during reset.
            else
                pulse_out <= '0';                            -- Default output is low; pulse lasts one clock only.

                sync_1 <= button_in;                         -- First flip-flop samples the raw button.
                sync_2 <= sync_1;                             -- Second flip-flop reduces metastability risk.

                if sync_2 = stable_state then                -- If input matches accepted state, it is not changing.
                    counter <= 0;                             -- No debounce timing is needed.
                else
                    if counter = DEBOUNCE_MAX then            -- Input stayed different long enough to be accepted.
                        stable_state <= sync_2;               -- Accept the new stable button value.
                        counter <= 0;                         -- Restart counter after accepting the change.
                    else
                        counter <= counter + 1;               -- Keep waiting until bouncing is over.
                    end if;
                end if;

                if stable_state = '1' and last_state = '0' then -- Detect a stable rising edge: released to pressed.
                    pulse_out <= '1';                            -- Create exactly one CPU step pulse.
                end if;

                last_state <= stable_state;                   -- Save current stable state for next edge detection.
            end if;
        end if;
    end process;

end rtl;                                        
