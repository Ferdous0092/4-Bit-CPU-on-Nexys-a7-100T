entity CR_add_sub is
    port(
        A    : in bit_vector(3 downto 0);   -- first number
        B    : in bit_vector(3 downto 0);   -- second number
        SUB  : in bit;                      -- 0 = add, 1 = subtract
        S    : out bit_vector(3 downto 0);  -- result
        Cout : out bit                      -- carry output
    );
end CR_add_sub;

architecture structure of CR_add_sub is

    signal changed_B : bit_vector(3 downto 0);

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

    -- when SUB is 0, B stays normal (no innversion)
    -- when SUB is 1, B is inverted
    changed_B(0) <= B(0) xor SUB;
    changed_B(1) <= B(1) xor SUB;
    changed_B(2) <= B(2) xor SUB;
    changed_B(3) <= B(3) xor SUB;

    -- for subtraction, Cin is 1
    -- this makes A + not B + 1
    ADDER1: CR_adder
        port map(
            A    => A,
            B    => changed_B,
            Cin  => SUB,
            S    => S,
            Cout => Cout
        );

end structure;
