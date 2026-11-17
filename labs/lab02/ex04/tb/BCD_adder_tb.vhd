entity BCD_adder_tb is
end BCD_adder_tb;

architecture test of BCD_adder_tb is

    signal A_tb     : bit_vector(3 downto 0) := "0000";
    signal B_tb     : bit_vector(3 downto 0) := "0000";
    signal S_tb     : bit_vector(3 downto 0);
    signal CARRY_tb : bit;

    component BCD_adder
        port(
            A     : in bit_vector(3 downto 0);
            B     : in bit_vector(3 downto 0);
            S     : out bit_vector(3 downto 0);
            CARRY : out bit
        );
    end component;

begin

    UUT: BCD_adder
        port map(
            A     => A_tb,
            B     => B_tb,
            S     => S_tb,
            CARRY => CARRY_tb
        );

    process
    begin

        -- 0 + 0 = 0
        A_tb <= "0000";
        B_tb <= "0000";
        wait for 10 ns;

        -- 1 + 2 = 3
        A_tb <= "0001";
        B_tb <= "0010";
        wait for 10 ns;

        -- 4 + 5 = 9
        A_tb <= "0100";
        B_tb <= "0101";
        wait for 10 ns;

        -- 5 + 5 = 10
        -- result is 0000 and carry is 1
        A_tb <= "0101";
        B_tb <= "0101";
        wait for 10 ns;

        -- 6 + 7 = 13
        -- result is 0011 and carry is 1
        A_tb <= "0110";
        B_tb <= "0111";
        wait for 10 ns;

        -- 9 + 9 = 18
        -- result is 1000 and carry is 1
        A_tb <= "1001";
        B_tb <= "1001";
        wait for 10 ns;

        wait;

    end process;

end test;
