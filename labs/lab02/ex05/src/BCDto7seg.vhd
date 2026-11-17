entity BCDto7seg is
    port(
        BCD : in bit_vector(3 downto 0);
        SEG : out bit_vector(6 downto 0)
    );
end BCDto7seg;

architecture behavior of BCDto7seg is
begin

    process(BCD)
    begin

        if BCD = "0000" then
            -- 0
            SEG <= "0000001";

        elsif BCD = "0001" then
            -- 1
            SEG <= "1001111";

        elsif BCD = "0010" then
            -- 2
            SEG <= "0010010";

        elsif BCD = "0011" then
            -- 3
            SEG <= "0000110";

        elsif BCD = "0100" then
            -- 4
            SEG <= "1001100";

        elsif BCD = "0101" then
            -- 5
            SEG <= "0100100";

        elsif BCD = "0110" then
            -- 6
            SEG <= "0100000";

        elsif BCD = "0111" then
            -- 7
            SEG <= "0001111";

        elsif BCD = "1000" then
            -- 8
            SEG <= "0000000";

        elsif BCD = "1001" then
            -- 9
            SEG <= "0000100";

        else
            -- invalid BCD input, display is off
            SEG <= "1111111";

        end if;

    end process;

end behavior;
