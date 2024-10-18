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
end Signal_Extend;

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

end beh;


--ALU Control
entity ALU_Control is
port (inst: in std_logic_vector(5 downto 0);
      enable: in std_logic_vector(1 downto 0);
	  o: out std_logic_vector(2 downto 0)
      );
end ALU_Control;

architecture beh of ALU_Control is
begin

	o <= "000" when enable = "10" and inst = '100100'; --and
    o <= "001" when enable = "10" and inst = '100101'; --or
    o <= "010" when enable = "10" and inst = '100000'; --suma
    o <= "110" when enable = "10" and inst = '100010'; --resta
    o <= "111" when enable = "10" and inst = '101010'; -- a < b
    --o <= "100" when enable = "10" and inst = 'algo'; --tenemos dudas de la operacion
    
    --el "10" es para instr tipo R
    --el "00" es para instr tipo I
    --el "01" es para instr tipo Beq

end beh;


--Unidad de Control
entity Unidad_Control is
port (inst: in std_logic_vector(5 downto 0);
	  RegDest: out std_logic;
      Branch: out std_logic;
      MemRead: out std_logic;
      MemToReg: out std_logic;
      AluOp: out std_logic_vector(1 downto 0);
      MemWrite: out std_logic;
      AluSrc: out std_logic;
      RegWrite: out std_logic
	);
end Unidad_Control;

architecture beh of Unidad_Control is
begin

	--tipo R
    RegDest <= '1' when "000000";
    Branch <= '0' when "000000";
    MemRead <= '0' when "000000";
    MemToReg <= '0' when "000000";
    AluOp <= "10" when "000000";
    MemWrite <= '0' when "000000";
    AluSrc <= '0' when "000000";
    RegWrite <= '1' when "000000";
    
    --tipo LW
    RegDest <= '0' when "100011";
    Branch <= '0' when "100011";
    MemRead <= '1' when "100011";
    MemToReg <= '1' when "100011";
    AluOp <= "00" when "100011";
    MemWrite <= '0' when "100011";
    AluSrc <= '1' when "100011";
    RegWrite <= '1' when "100011";
    
    --tipo SW
    RegDest <= '0' when "101011";
    Branch <= '0' when "101011";
    MemRead <= '0' when "101011";
    MemToReg <= '0' when "101011";
    AluOp <= "00" when "101011";
    MemWrite <= '1' when "101011";
    AluSrc <= '1' when "101011";
    RegWrite <= '0' when "101011";
    
    --tipo Beq
    RegDest <= '0' when "000100";
    Branch <= '1' when "000100";
    MemRead <= '0' when "000100";
    MemToReg <= '0' when "000100";
    AluOp <= "01" when "000100";
    MemWrite <= '0' when "000100";
    AluSrc <= '0' when "000100";
    RegWrite <= '0' when "000100";
    
    --tipo Jump
    RegDest <= '0' when "000010";
    Branch <= '1' when "000010";
    MemRead <= '0' when "000010";
    MemToReg <= '0' when "000010";
    AluOp <= "00" when "000010";
    MemWrite <= '0' when "000010";
    AluSrc <= '0' when "000010";
    RegWrite <= '0' when "000010";

end beh;


--PC