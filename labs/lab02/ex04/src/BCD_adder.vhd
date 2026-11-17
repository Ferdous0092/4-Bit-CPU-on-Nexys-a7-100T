entity BCD_adder is
    port(
        A     : in bit_vector(3 downto 0);   -- first BCD number
        B     : in bit_vector(3 downto 0);   -- second BCD number
        S     : out bit_vector(3 downto 0);  -- BCD result
        CARRY : out bit                      -- decimal carry
    );
end BCD_adder;

architecture structure of BCD_adder is

    signal first_sum       : bit_vector(3 downto 0);
    signal first_carry     : bit;
    signal add_six         : bit;
    signal correction      : bit_vector(3 downto 0);
    signal final_sum       : bit_vector(3 downto 0);
    signal not_used_carry  : bit;

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

    -- first normal 4 bit addition
    ADD1: CR_adder
        port map(
            A    => A,
            B    => B,
            Cin  => '0',
            S    => first_sum,
            Cout => first_carry
        );

    -- correction needed if result is bigger than 9
    add_six <= first_carry or
               (first_sum(3) and first_sum(2)) or
               (first_sum(3) and first_sum(1));

    -- correction number is 0110 when add_six is 1
    -- otherwise it is 0000
    correction(0) <= '0';
    correction(1) <= add_six;
    correction(2) <= add_six;
    correction(3) <= '0';

    -- addingg correction to first result
    ADD2: CR_adder
        port map(
            A    => first_sum,
            B    => correction,
            Cin  => '0',
            S    => final_sum,
            Cout => not_used_carry
        );

    S <= final_sum;

    -- decimal carry
    CARRY <= add_six;

end structure;
