entity BCDto7seg_tb is
end BCDto7seg_tb;

architecture test of BCDto7seg_tb is

    signal BCD_tb : bit_vector(3 downto 0) := "0000";
    signal SEG_tb : bit_vector(6 downto 0);

    component BCDto7seg
        port(
            BCD : in bit_vector(3 downto 0);
            SEG : out bit_vector(6 downto 0)
        );
    end component;

begin

    UUT: BCDto7seg
        port map(
            BCD => BCD_tb,
            SEG => SEG_tb
        );

    process
    begin

        BCD_tb <= "0000";
        wait for 10 ns;

        BCD_tb <= "0001";
        wait for 10 ns;

        BCD_tb <= "0010";
        wait for 10 ns;

        BCD_tb <= "0011";
        wait for 10 ns;

        BCD_tb <= "0100";
        wait for 10 ns;

        BCD_tb <= "0101";
        wait for 10 ns;

        BCD_tb <= "0110";
        wait for 10 ns;

        BCD_tb <= "0111";
        wait for 10 ns;

        BCD_tb <= "1000";
        wait for 10 ns;

        BCD_tb <= "1001";
        wait for 10 ns;

        -- invalid BCD input
        BCD_tb <= "1010";
        wait for 10 ns;

        -- invalid BCD input
        BCD_tb <= "1111";
        wait for 10 ns;

        wait;

    end process;

end test;
