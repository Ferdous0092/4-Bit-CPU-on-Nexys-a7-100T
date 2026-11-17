entity half_subtractor is
    port(
        A      : in bit;      -- first input
        B      : in bit;      -- second input
        D      : out bit;     -- difference output
        BORROW : out bit      -- borrow output
    );
end half_subtractor;

architecture behavior of half_subtractor is
begin

    -- difference is 1 when the two inputs are different
    D <= A xor B;

    -- borrow is 1 when A is 0 and B is 1
    BORROW <= (not A) and B;

end behavior;
