entity full_adder_tb is
end full_adder_tb;

architecture test of full_adder_tb is

    signal A_tb    : bit := '0';
    signal B_tb    : bit := '0';
    signal Cin_tb  : bit := '0';
    signal S_tb    : bit;
    signal Cout_tb : bit;

    component full_adder
        port(
            A    : in bit;
            B    : in bit;
            Cin  : in bit;
            S    : out bit;
            Cout : out bit
        );
    end component;

begin

    UUT: full_adder
        port map(
            A    => A_tb,
            B    => B_tb,
            Cin  => Cin_tb,
            S    => S_tb,
            Cout => Cout_tb
        );

    process
    begin

        -- all possible input combinations

        A_tb <= '0'; B_tb <= '0'; Cin_tb <= '0';
        wait for 10 ns;

        A_tb <= '0'; B_tb <= '0'; Cin_tb <= '1';
        wait for 10 ns;

        A_tb <= '0'; B_tb <= '1'; Cin_tb <= '0';
        wait for 10 ns;

        A_tb <= '0'; B_tb <= '1'; Cin_tb <= '1';
        wait for 10 ns;

        A_tb <= '1'; B_tb <= '0'; Cin_tb <= '0';
        wait for 10 ns;

        A_tb <= '1'; B_tb <= '0'; Cin_tb <= '1';
        wait for 10 ns;

        A_tb <= '1'; B_tb <= '1'; Cin_tb <= '0';
        wait for 10 ns;

        A_tb <= '1'; B_tb <= '1'; Cin_tb <= '1';
        wait for 10 ns;

        wait;

    end process;

end test;
