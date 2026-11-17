entity half_subtractor_tb is
end half_subtractor_tb;

architecture bench of half_subtractor_tb is

    -- testbench signals
    signal A      : bit;
    signal B      : bit;
    signal D      : bit;
    signal BORROW : bit;

    -- component to be tested
    component half_subtractor
        port(
            A      : in bit;
            B      : in bit;
            D      : out bit;
            BORROW : out bit
        );
    end component;

begin

    -- connect the half subtractor to the testbench signals
    hs: half_subtractor
        port map(
            A      => A,
            B      => B,
            D      => D,
            BORROW => BORROW
        );

    -- apply all possible input combinations
    process
    begin

        -- 0 - 0
        A <= '0';
        B <= '0';
        wait for 10 ns;

        -- 0 - 1
        A <= '0';
        B <= '1';
        wait for 10 ns;

        -- 1 - 0
        A <= '1';
        B <= '0';
        wait for 10 ns;

        -- 1 - 1
        A <= '1';
        B <= '1';
        wait for 10 ns;

        -- stop simulation
        wait;

    end process;

end bench;
