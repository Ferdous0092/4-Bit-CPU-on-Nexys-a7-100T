--------------------------------------------------------------------------------
-- File: clock_divider.vhd
--------------------------------------------------------------------------------

library IEEE;                         
use IEEE.STD_LOGIC_1164.ALL;          
use IEEE.NUMERIC_STD.ALL;            

entity clock_divider is               
    generic(                         
        DIVISOR : natural := 100000000 -- Default gives about 1 Hz from a 100 MHz clock.
    );
    port(                             
        clk   : in  std_logic;        -- Input clock, normally 100 MHz on Nexys A7.
        reset : in  std_logic;        -- Reset clears the internal counter.
        tick  : out std_logic         -- Output pulse that is high for exactly one clock cycle.
    );
end clock_divider;                    

architecture rtl of clock_divider is  
    signal counter : natural range 0 to DIVISOR - 1 := 0; -- Counter stores how many clock cycles passed.
begin

    process(clk)                      -- Sequential process because the counter is made from flip-flops.
    begin
        if rising_edge(clk) then      -- Counter changes only on rising clock edges.
            if reset = '1' then       -- Reset gives a known starting state.
                counter <= 0;         -- Restart counting from zero.
                tick <= '0';          -- Prevent a false step tick during reset.
            else
                if counter = DIVISOR - 1 then -- Divider period is complete.
                    counter <= 0;             -- Restart the counter for the next period.
                    tick <= '1';              -- Generate one visible CPU auto-step pulse.
                else
                    counter <= counter + 1;   -- Continue counting clock cycles.
                    tick <= '0';              
                end if;
            end if;
        end if;
    end process;

end rtl;                             
