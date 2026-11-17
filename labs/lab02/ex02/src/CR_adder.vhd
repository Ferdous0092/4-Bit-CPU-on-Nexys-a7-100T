entity CR_adder is
    port(
        A    : in bit_vector(3 downto 0);   -- first 4 bit number
        B    : in bit_vector(3 downto 0);   -- second 4 bit number
        Cin  : in bit;                      -- carry input
        S    : out bit_vector(3 downto 0);  -- sum output
        Cout : out bit                      -- carry output
    );
end CR_adder;

architecture structure of CR_adder is

    signal carry1 : bit;
    signal carry2 : bit;
    signal carry3 : bit;

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

    -- bit 0, lowest bit
    FA0: full_adder
        port map(
            A    => A(0),
            B    => B(0),
            Cin  => Cin,
            S    => S(0),
            Cout => carry1
        );

    -- bit 1
    FA1: full_adder
        port map(
            A    => A(1),
            B    => B(1),
            Cin  => carry1,
            S    => S(1),
            Cout => carry2
        );

    -- bit 2
    FA2: full_adder
        port map(
            A    => A(2),
            B    => B(2),
            Cin  => carry2,
            S    => S(2),
            Cout => carry3
        );

    -- bit 3, highest bit
    FA3: full_adder
        port map(
            A    => A(3),
            B    => B(3),
            Cin  => carry3,
            S    => S(3),
            Cout => Cout
        );

end structure;
