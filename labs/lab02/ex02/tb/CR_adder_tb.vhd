entity CR_adder_tb is
end CR_adder_tb;

architecture test of CR_adder_tb is

    signal A_tb    : bit_vector(3 downto 0) := "0000";
    signal B_tb    : bit_vector(3 downto 0) := "0000";
    signal Cin_tb  : bit := '0';
    signal S_tb    : bit_vector(3 downto 0);
    signal Cout_tb : bit;

    component CR_adder
        port(
            A    : in bit_vector(3 downto 0);
            B    : in bit_vector(3 downto 0);
            Cin  : in bit;
            S    : out bit_vector(3 downto 0);
            Cout : out bit
        );
    end component;

begin

    UUT: CR_adder
        port map(
            A    => A_tb,
            B    => B_tb,
            Cin  => Cin_tb,
            S    => S_tb,
            Cout => Cout_tb
        );

    process
    begin

        -- 0 + 0 = 0
        A_tb <= "0000";
        B_tb <= "0000";
        Cin_tb <= '0';
        wait for 10 ns;

        -- 1 + 1 = 2
        A_tb <= "0001";
        B_tb <= "0001";
        Cin_tb <= '0';
        wait for 10 ns;

        -- 3 + 4 = 7
        A_tb <= "0011";
        B_tb <= "0100";
        Cin_tb <= '0';
        wait for 10 ns;

        -- 7 + 1 = 8
        A_tb <= "0111";
        B_tb <= "0001";
        Cin_tb <= '0';
        wait for 10 ns;

        -- 8 + 7 = 15
        A_tb <= "1000";
        B_tb <= "0111";
        Cin_tb <= '0';
        wait for 10 ns;

        -- 15 + 1 = 16, sum is 0000 and carry is 1
        A_tb <= "1111";
        B_tb <= "0001";
        Cin_tb <= '0';
        wait for 10 ns;

        -- 15 + 15 = 30, sum is 1110 and carry is 1
        A_tb <= "1111";
        B_tb <= "1111";
        Cin_tb <= '0';
        wait for 10 ns;

        -- 5 + 5 + carry input = 11
        A_tb <= "0101";
        B_tb <= "0101";
        Cin_tb <= '1';
        wait for 10 ns;

        wait;

    end process;

end test;
