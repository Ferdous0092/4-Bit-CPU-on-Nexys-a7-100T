entity full_subtractor_bhv_tb is
end full_subtractor_bhv_tb;

architecture bench of full_subtractor_bhv_tb is

    -- testbench signals
    signal A      : bit;
    signal B      : bit;
    signal BIN    : bit;
    signal D      : bit;
    signal BORROW : bit;

    -- component to be tested
    component full_subtractor_bhv
        port(
            A      : in bit;
            B      : in bit;
            BIN    : in bit;
            D      : out bit;
            BORROW : out bit
        );
    end component;

begin

    -- connect the full subtractor to the testbench signals
    fs: full_subtractor_bhv
        port map(
            A      => A,
            B      => B,
            BIN    => BIN,
            D      => D,
            BORROW => BORROW
        );

    -- apply all possible input combinations
    process
    begin

        -- 0 - 0 - 0
        A <= '0';
        B <= '0';
        BIN <= '0';
        wait for 10 ns;

        -- 0 - 0 - 1
        A <= '0';
        B <= '0';
        BIN <= '1';
        wait for 10 ns;

        -- 0 - 1 - 0
        A <= '0';
        B <= '1';
        BIN <= '0';
        wait for 10 ns;

        -- 0 - 1 - 1
        A <= '0';
        B <= '1';
        BIN <= '1';
        wait for 10 ns;

        -- 1 - 0 - 0
        A <= '1';
        B <= '0';
        BIN <= '0';
        wait for 10 ns;

        -- 1 - 0 - 1
        A <= '1';
        B <= '0';
        BIN <= '1';
        wait for 10 ns;

        -- 1 - 1 - 0
        A <= '1';
        B <= '1';
        BIN <= '0';
        wait for 10 ns;

        -- 1 - 1 - 1
        A <= '1';
        B <= '1';
        BIN <= '1';
        wait for 10 ns;

        -- stop simulation
        wait;

    end process;

end bench;
