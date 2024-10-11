-- MUX2_32
entity mux2_32 is 
port ( a: in std_logic_vector(31 downto 0);
        b: in std_logic_vector(31 downto 0);
        sel: in std_logic;
        o: out std_logic_vector(31 downto 0)
        );
end mux2_32; 

architecture beh of mux2_32 is

begin

    o <= a when sel = '0' else b;

end beh;



-- MUX2_5
entity mux2_5 is 
port ( a: in std_logic_vector(4 downto 0);
        b: in std_logic_vector(4 downto 0);
        sel: in std_logic;
        o: out std_logic_vector(4 downto 0)
        );
end mux2_5;

architecture beh of mux2_5 is

begin

    o <= a when sel = '0' else b;

end beh;



-- Signal_Extend
entity Signal_Extend is
port ( inm: in std_logic_vector(15 downto 0);
	   o: out std_logic_vector(31 downto 0)
       );
end component;

architecture beh of Signal_Extend is

begin

	o <= "1111111111111111" & inm when inm(15) = '1' else "0000000000000000" & inm;

    --if inm(15) = '1' then
    --	o <= "1111111111111111" & inm;
    --else
    --	o <= "0000000000000000" & inm;
    --end if;

end beh;



-- Shift_Left_2
entity Shift_Left_2 is
port ( inst: in std_logic_vector(31 downto 0);
	   o: out std_logic_vector(31 downto 0)
       );
end Shift_Left_2;

architecture beh of Shift_Left_2 is

begin

	o <= inst(29 downto 0) & "00";

end beh;



-- Adder_PC
entity Adder_PC is
port ( inst: in std_logic_vector(31 downto 0);
	   clk: in std_logic;
	   o: out std_logic_vector(31 downto 0)
       );
end Adder_PC;

architecture beh of Adder_PC is
signal inst_int : unsigned(inst); -- Señal intermedia de tipo unsigned
signal o_int : unsigned(31 downto 0); -- Señal intermedia de tipo unsigned
begin

	o_int <= inst_int + 4 when (clk' event and clk = '1');

	--if (clk' event and clk = '1') then
	--	o_int <= inst_int + 4; -- PC + 4
    --end if;
    
    o <= std_logic_vector(o_int);

end beh;



--Adder
entity Adder is
port ( inst_a: in std_logic_vector(31 downto 0);
	   inst_b: in std_logic_vector(31 downto 0);
       clk: in std_logic;
       o: out std_logic_vector(31 downto 0)
       );
end Adder;

architecture beh of Adder is
signal inst_a_int : unsigned(inst_a); -- Señal intermedia de tipo unsigned
signal inst_b_int : unsigned(inst_b); -- Señal intermedia de tipo unsigned
signal o_int : unsigned(31 downto 0); -- Señal intermedia de tipo unsigned
begin

	o_int <= inst_a_int + inst_b_int when (clk' event and clk = '1');
    
    o <= std_logic_vector(o_int);

end Adder;