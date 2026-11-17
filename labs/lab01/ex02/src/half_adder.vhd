entity half_adder is
    port(
        A     : in bit;      -- first input
        B     : in bit;      -- second input
        S     : out bit;     -- sum output
        CARRY : out bit      -- carry output
    );
end half_adder;

architecture behavior of half_adder is
begin

    -- sum is 1 when the two inputs are different
    S <= A xor B;

    -- carry is 1 when both inputs are 1
    CARRY <= A and B;

end behavior;
