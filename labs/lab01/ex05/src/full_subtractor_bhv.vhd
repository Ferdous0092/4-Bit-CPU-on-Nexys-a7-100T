entity full_subtractor_bhv is
    port(
        A      : in bit;      -- first input
        B      : in bit;      -- second input
        BIN    : in bit;      -- borrow input
        D      : out bit;     -- difference output
        BORROW : out bit      -- borrow output
    );
end full_subtractor_bhv;

architecture behavior of full_subtractor_bhv is
begin

    -- difference is 1 when there is an odd number of 1s
    D <= A xor B xor BIN;

    -- borrow is 1 when subtraction needs a borrow
    BORROW <= ((not A) and B) or ((not A) and BIN) or (B and BIN);

end behavior;
