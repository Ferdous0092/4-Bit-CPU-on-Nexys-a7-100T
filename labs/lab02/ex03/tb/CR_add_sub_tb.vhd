entity CR_add_sub_tb is
end CR_add_sub_tb;

architecture test of CR_add_sub_tb is

    signal A_tb    : bit_vector(3 downto 0) := "0000";
    signal B_tb    : bit_vector(3 downto 0) := "0000";
    signal SUB_tb  : bit := '0';
    signal S_tb    : bit_vector(3 downto 0);
    signal Cout_tb : bit;

    component CR_add_sub
        port(
            A    : in bit_vector(3 downto 0);
            B    : in bit_vector(3 downto 0);
            SUB  : in bit;
            S    : out bit_vector(3 downto 0);
            Cout : out bit
        );
    end component;

begin

    UUT: CR_add_sub
        port map(
            A    => A_tb,
            B    => B_tb,
            SUB  => SUB_tb,
            S    => S_tb,
            Cout => Cout_tb
        );

    process
    begin

        -- addition: 3 + 2 = 5
        A_tb <= "0011";
        B_tb <= "0010";
        SUB_tb <= '0';
        wait for 10 ns;

        -- addition: 7 + 1 = 8
        A_tb <= "0111";
        B_tb <= "0001";
        SUB_tb <= '0';
        wait for 10 ns;

        -- addition: 15 + 1 = 16
        -- result is 0000 and carry is 1
        A_tb <= "1111";
        B_tb <= "0001";
        SUB_tb <= '0';
        wait for 10 ns;

        -- subtraction: 5 - 2 = 3
        A_tb <= "0101";
        B_tb <= "0010";
        SUB_tb <= '1';
        wait for 10 ns;

        -- subtraction: 9 - 4 = 5
        A_tb <= "1001";
        B_tb <= "0100";
        SUB_tb <= '1';
        wait for 10 ns;

        -- subtraction: 8 - 8 = 0
        A_tb <= "1000";
        B_tb <= "1000";
        SUB_tb <= '1';
        wait for 10 ns;

        -- subtraction: 2 - 5 gives negative result in 4 bit form
        A_tb <= "0010";
        B_tb <= "0101";
        SUB_tb <= '1';
        wait for 10 ns;

        wait;

    end process;

end test;
