entity full_adder_bhv is
    port(
        A    : in bit;      -- first input
        B    : in bit;      -- second input
        CIN  : in bit;      -- carry input
        S    : out bit;     -- sum output
        COUT : out bit      -- carry output
    );
end full_adder_bhv;

architecture behavior of full_adder_bhv is
begin

    -- sum is 1 when an odd number of inputs are 1
    S <= A xor B xor CIN;

    -- carry is 1 when at least two inputs are 1
    COUT <= (A and B) or (A and CIN) or (B and CIN);

end behavior;
