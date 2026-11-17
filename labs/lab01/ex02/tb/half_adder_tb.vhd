entity half_adder_tb is
end half_adder_tb;

architecture bench of half_adder_tb is

    -- testbench signals
    signal A     : bit;
    signal B     : bit;
    signal S     : bit;
    signal CARRY : bit;

    -- component to be tested
    component half_adder
        port(
            A     : in bit;
            B     : in bit;
            S     : out bit;
            CARRY : out bit
        );
    end component;

begin

    -- connect the half adder to the testbench signals
    ha: half_adder
        port map(
            A     => A,
            B     => B,
            S     => S,
            CARRY => CARRY
        );

    -- apply all possible input combinations
    process
    begin

        -- 0 + 0
        A <= '0';
        B <= '0';
        wait for 10 ns;

        -- 0 + 1
        A <= '0';
        B <= '1';
        wait for 10 ns;

        -- 1 + 0
        A <= '1';
        B <= '0';
        wait for 10 ns;

        -- 1 + 1
        A <= '1';
        B <= '1';
        wait for 10 ns;

        -- stop simulation
        wait;

    end process;

end bench;
