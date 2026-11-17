entity full_adder is
    port(
        A    : in bit;      -- first input
        B    : in bit;      -- second input
        Cin  : in bit;      -- carry input
        S    : out bit;     -- sum output
        Cout : out bit      -- carry output
    );
end full_adder;

architecture structure of full_adder is

    signal first_sum    : bit;
    signal first_carry  : bit;
    signal second_carry : bit;

    component half_adder
        port(
            A     : in bit;
            B     : in bit;
            S     : out bit;
            CARRY : out bit
        );
    end component;

begin

    -- first half adder adds A and B
    HA1: half_adder
        port map(
            A     => A,
            B     => B,
            S     => first_sum,
            CARRY => first_carry
        );

    -- second half adder adds first_sum and Cin
    HA2: half_adder
        port map(
            A     => first_sum,
            B     => Cin,
            S     => S,
            CARRY => second_carry
        );

    -- final carry
    Cout <= first_carry or second_carry;

end structure;
