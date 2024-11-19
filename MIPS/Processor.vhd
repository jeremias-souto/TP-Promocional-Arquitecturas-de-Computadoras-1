-- ======================
-- ====    Autor Mart n V zquez 
-- ====    arquitectura de Computadoras  - 2024
--
-- ====== MIPS uniciclo
-- ======================

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_SIGNED.all;

entity Processor is
port(
	Clk         : in  std_logic;
	Reset       : in  std_logic;
	-- Instruction memory
	I_Addr      : out std_logic_vector(31 downto 0);
	I_RdStb     : out std_logic;
	I_WrStb     : out std_logic;
	I_DataOut   : out std_logic_vector(31 downto 0);
	I_DataIn    : in  std_logic_vector(31 downto 0);
	-- Data memory
	D_Addr      : out std_logic_vector(31 downto 0);
	D_RdStb     : out std_logic;
	D_WrStb     : out std_logic;
	D_DataOut   : out std_logic_vector(31 downto 0);
	D_DataIn    : in  std_logic_vector(31 downto 0)
);
end Processor;

architecture processor_arch of Processor is 

    -- declaraci n de componentes ALU
    component ALU 
        port  (a : in std_logic_vector(31 downto 0);
               b : in std_logic_vector(31 downto 0);
               control : in std_logic_vector(2 downto 0);
               zero : out std_logic;
               result : out std_logic_vector(31 downto 0)); 
    end component;
    
    -- declaraci n de componente Registers
    component Registers 
        port  (clk : in std_logic;
               reset : std_logic;
               wr : in std_logic;
               reg1_rd : in std_logic_vector(4 downto 0);
               reg2_rd : in std_logic_vector(4 downto 0);
               reg_wr : in std_logic_vector(4 downto 0);
               data_wr : in std_logic_vector(31 downto 0);
               data1_rd : out std_logic_vector(31 downto 0);
               data2_rd : out std_logic_vector(31 downto 0));
    end component;

    -- se ales de control 
    signal RegWrite, RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, Jump: std_logic;
    signal ALUOp: std_logic_vector(1 downto 0); 

-- declarci n de otras se ales 
    signal r_wr: std_logic; -- habilitaci n de escritura en el banco de registros
    signal reg_wr: std_logic_vector(4 downto 0); -- direcci n del registro de escritura
    signal data1_reg, data2_reg: std_logic_vector(31 downto 0); -- registros le dos desde el banco de registro
    signal data_w_reg: std_logic_vector(31 downto 0); -- dato a escribir en el banco de registros
    
    signal pc_4: std_logic_vector(31 downto 0); -- para incremento de PC
    signal pc_branch: std_logic_vector(31 downto 0); -- salto por beq
    signal pc_jump: std_logic_vector(31 downto 0); -- para salto incondicional
    signal reg_pc, next_reg_pc: std_logic_vector(31 downto 0); -- correspondientes al registro del program counter
 
    signal ALU_oper_b : std_logic_vector(31 downto 0); -- corrspondiente al segundo operando de ALU
    signal ALU_control: std_logic_vector(2 downto 0); -- se ales de control de la ALU
    signal ALU_zero: std_logic; -- flag zero de la ALU
    signal ALU_result: std_logic_vector(31 downto 0); -- resultado de la ALU  

    signal inm_extended: std_logic_vector(31 downto 0); -- describe el operando inmediato de la instrucci n extendido a 32 bits

begin 	

-- Interfaz con memoria de Instrucciones
    I_Addr <= reg_pc; -- el PC
    I_RdStb <= '1';
    I_WrStb <= '0';
    I_DataOut <= (others => '0'); -- dato que nunca se carga en memoria de programa

    
-- Instanciaci n de banco de registros
    E_Regs:  Registers 
	   Port map (
			clk => clk, 
			reset => reset, 
			wr => RegWrite,
			reg1_rd => I_DataIn(25 downto 21), 
			reg2_rd => I_DataIn(20 downto 16), 
			reg_wr => reg_wr,
			data_wr => data_w_reg, 
			data1_rd => data1_reg,
			data2_rd => data2_reg); 
			
			
-- mux de para destino de escritura en banco de registros (mux entre progamMemory y Reg)
	reg_wr <= I_DataIn(15 downto 11) when RegDst = '1' else I_DataIn(20 downto 16);
    
    
-- extensi n de signo del operando inmediato de la instrucci n
	inm_extended <= "1111111111111111" & I_DataIn(15 downto 0) when (I_DataIn(15) = '1') else "0000000000000000" & I_DataIn(15 downto 0);
  
    
-- mux correspondiente a segundo operando de ALU
	ALU_oper_b <= inm_extended when ALUSrc = '1' else data2_reg;
        
-- Instanciaci n de ALU
    E_ALU: ALU port map(
            a => data1_reg, 
            b => ALU_oper_b, 
            control => ALU_control,
            zero => ALU_zero, 
            result => ALU_result);

-- Control de la ALU

	ALU_control <= "000" when (ALUOp = "10" and I_DataIn(5 downto 0) = "100100") else --and
    "001" when (ALUOp = "10" and I_DataIn(5 downto 0) = "100101") else --or
    "010" when (ALUOp = "10" and I_DataIn(5 downto 0) = "100000") else --suma
    "110" when (ALUOp = "10" and I_DataIn(5 downto 0) = "100010") else --resta
    "111" when (ALUOp = "10" and I_DataIn(5 downto 0) = "101010") else -- a < b
    "110" when ALUOp = "01" else --beq
    "010" when ALUOp = "00" else --lw y sw
    "011"; --caso instruccion inexistente
    
    -- incremento de PC
    pc_4 <= std_logic_vector(reg_pc + 4);
    
    -- determina salto condicional por iguales
    pc_branch <= std_logic_vector(pc_4 + (inm_extended(29 downto 0) & "00"));
    
    -- determina salto incondicional
    pc_jump <= pc_4(31 downto 28) & (reg_pc(25 downto 0) & "00");

    
    -- mux que maneja carga de PC (mux de inst jump o beq)
    next_reg_pc <= pc_jump when Jump = '1' else pc_branch when (Branch = '1' and ALU_zero = '1') else pc_4;
    
    
   
-- Contador de programa
	process(Clk, Reset)
    begin
    
    	if(Reset = '1') then
        	reg_pc <= (others => '0');
        elsif (rising_edge(Clk)) then
        	reg_pc <= next_reg_pc;
        end if;
    
    end process;


 
-- Unidad de Control

    RegDst <= '1' when (I_DataIn(31 downto 26) = "000000") else '0';
    Branch <= '0' when (I_DataIn(31 downto 26) = "000000") or (I_DataIn(31 downto 26) = "100011") or (I_DataIn(31 downto 26) = "101011") else '1';
    MemRead <= '1' when (I_DataIn(31 downto 26) = "100011") else '0';
    MemToReg <= '1' when (I_DataIn(31 downto 26) = "100011") else '0';
    ALUOp <= "10" when (I_DataIn(31 downto 26) = "000000") else "01" when (I_DataIn(31 downto 26) = "000100") else "00";
    MemWrite <= '1' when (I_DataIn(31 downto 26) = "101011") else '0';
    AluSrc <= '1' when (I_DataIn(31 downto 26) = "100011") or (I_DataIn(31 downto 26) = "101011") else '0';
    RegWrite <= '1' when (I_DataIn(31 downto 26) = "000000") or (I_DataIn(31 downto 26) = "100011") else '0';
    Jump <= '1' when (I_DataIn(31 downto 26) = "000010") else '0';
  
    -- mux que maneja escritura en banco de registros (ultimo mux, despues de la memoria de datos)
    data_w_reg <= ALU_result when MemtoReg = '0' else D_DataIn;
 

    -- Manejo de memorias de Datos
    D_Addr <= ALU_result;
    D_RdStb <= MemRead;
    D_WrStb <= MemWrite;
    D_DataOut <= data2_reg;

end processor_arch;