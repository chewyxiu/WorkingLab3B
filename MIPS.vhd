----------------------------------------------------------------------------------
-- Company: NUS
-- Engineer: Rajesh Panicker
-- 
-- Create Date:   21:06:18 14/10/2014
-- Design Name: 	MIPS
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool versions: ISE 14.7
-- Description: MIPS processor
--
-- Dependencies: PC, ALU, ControlUnit, RegFile
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: DO NOT modify the interface (entity). Implementation (architecture) can be modified.
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity MIPS is -- DO NOT modify the interface (entity)
    Port ( 	
			Addr_Instr 		: out STD_LOGIC_VECTOR (31 downto 0);
			Instr 			: in STD_LOGIC_VECTOR (31 downto 0);
			Addr_Data		: out STD_LOGIC_VECTOR (31 downto 0);
			Data_In			: in STD_LOGIC_VECTOR (31 downto 0);
			Data_Out			: out  STD_LOGIC_VECTOR (31 downto 0);
			MemRead 			: out STD_LOGIC; 
			MemWrite 		: out STD_LOGIC; 
			RESET				: in STD_LOGIC;
			CLK				: in STD_LOGIC
			);
end MIPS;


architecture arch_MIPS of MIPS is

----------------------------------------------------------------
-- Program Counter
----------------------------------------------------------------
component PC is
	Port(	
			PC_in 	: in STD_LOGIC_VECTOR (31 downto 0);
			PC_out 	: out STD_LOGIC_VECTOR (31 downto 0);
			RESET		: in STD_LOGIC;
			CLK		: in STD_LOGIC);
end component;


component alu is
generic (width 	: integer);
Port (Clk			: in	STD_LOGIC;
		Control		: in	STD_LOGIC_VECTOR (5 downto 0);
		Operand1	   : in	STD_LOGIC_VECTOR (31 downto 0);
		Operand2	: in	STD_LOGIC_VECTOR (31 downto 0);
		Result1		: out	STD_LOGIC_VECTOR (31 downto 0);
		Result2		: out	STD_LOGIC_VECTOR (31 downto 0);
		Status		: out	STD_LOGIC_VECTOR (2 downto 0); -- busy (multicycle only), overflow (add and sub), zero (sub)
		ALU_zero		: out STD_LOGIC;
		ALU_greater	: out STD_LOGIC);
end component;

----------------------------------------------------------------
-- Control Unit
----------------------------------------------------------------
component ControlUnit is
    Port ( 	
			Control_Instr 		: in   STD_LOGIC_VECTOR (31 downto 0);
			ALUOp 		: out  STD_LOGIC_VECTOR (1 downto 0);
			Branch 		: out  STD_LOGIC;
			Jump	 		: out  STD_LOGIC;				
			MemRead 		: out  STD_LOGIC;	
			MemtoReg 	: out  STD_LOGIC;	
			InstrtoReg	: out  STD_LOGIC; -- true for LUI. When true, Instr(15 downto 0)&x"0000" is written to rt
			MemWrite		: out  STD_LOGIC;	
			ALUSrc 		: out  STD_LOGIC;	
			SignExtend 	: out  STD_LOGIC; -- false for ORI 
			RegWrite		: out  STD_LOGIC;	
			RegDst		: out  STD_LOGIC;
			Data_InA		: out  STD_LOGIC:= '0';
			Shift_Amt	: out  STD_LOGIC:= '0';
			Shift_Reg	: out  STD_LOGIC:= '0';
			JumptoReg	: out  STD_LOGIC:= '0';
			Hi_Reg 		: out  STD_LOGIC:= '0';
			Lo_Reg 		: out  STD_LOGIC:= '0';
			Write_HiLo	: out  STD_LOGIC:= '0';
			LinkReg     : out  STD_LOGIC);
end component;

----------------------------------------------------------------
-- Register File
----------------------------------------------------------------
component RegFile is
    Port ( 	
			ReadAddr1_Reg 	: in  STD_LOGIC_VECTOR (4 downto 0);
			ReadAddr2_Reg 	: in  STD_LOGIC_VECTOR (4 downto 0);
			ReadData1_Reg 	: out STD_LOGIC_VECTOR (31 downto 0);
			ReadData2_Reg 	: out STD_LOGIC_VECTOR (31 downto 0);				
			WriteAddr_Reg	: in  STD_LOGIC_VECTOR (4 downto 0); 
			WriteData_Reg 	: in STD_LOGIC_VECTOR (31 downto 0);
			RegWrite 		: in STD_LOGIC; 
			CLK 				: in  STD_LOGIC);
end component;

----------------------------------------------------------------
-- Sign Extend
----------------------------------------------------------------
component Sign_Extend is
    Port ( signExtendInput : in  STD_LOGIC_VECTOR (15 downto 0);
           signExtendOutput : out  STD_LOGIC_VECTOR (31 downto 0));
end component;


----------------------------------------------------------------
-- HiLo Registers
----------------------------------------------------------------
component HILO_reg is
    Port ( ReadHi_Reg : out  STD_LOGIC_VECTOR (31 downto 0);
           ReadLo_Reg : out  STD_LOGIC_VECTOR (31 downto 0);
           WriteHi_Reg : in  STD_LOGIC_VECTOR (31 downto 0);
           WriteLo_Reg : in  STD_LOGIC_VECTOR (31 downto 0);
           RegHiLoWrite : in  STD_LOGIC;
           CLK : in  STD_LOGIC);	
end component;
----------------------------------------------------------------
-- PC Signals
----------------------------------------------------------------
	signal	PC_in 		:  STD_LOGIC_VECTOR (31 downto 0);
	signal	PC_out 		:  STD_LOGIC_VECTOR (31 downto 0);

----------------------------------------------------------------
-- ALU Signals
----------------------------------------------------------------
	signal	ALU_InA 		:  STD_LOGIC_VECTOR (31 downto 0);
	signal	ALU_InB 		:  STD_LOGIC_VECTOR (31 downto 0);
	signal	Control	:  STD_LOGIC_VECTOR (5 downto 0);
--	signal   Control     :  STD_LOGIC(7 downto 0);
	signal	Result1		: STD_LOGIC_VECTOR (31 downto 0) 	:= (others=>'0');
	signal	Result2		: STD_LOGIC_VECTOR (31 downto 0) 	:= (others=>'0');
	signal	Status		: STD_LOGIC_VECTOR (2 downto 0) 			:= (others=>'0');
	signal  ALU_zero		: STD_LOGIC := '0';
   signal  ALU_greater	: STD_LOGIC := '0';
	
----------------------------------------------------------------
-- Control Unit Signals
----------------------------------------------------------------				
 	signal	opcode 		:  STD_LOGIC_VECTOR (31 downto 0);
	signal	ALUOp 		:  STD_LOGIC_VECTOR (1 downto 0);
	signal	Branch 		:  STD_LOGIC;
	signal	Jump	 		:  STD_LOGIC;	
	signal	MemtoReg 	:  STD_LOGIC;
	signal 	InstrtoReg	: 	STD_LOGIC;		
	signal	ALUSrc 		:  STD_LOGIC;	
	signal	SignExtend 	: 	STD_LOGIC;
	signal	RegWrite		: 	STD_LOGIC;	
	signal	RegDst		:  STD_LOGIC;
	signal   LinkReg     :  STD_LOGIC;
	signal	Data_InA		:  STD_LOGIC:= '0';
	signal	Shift_Amt	:  STD_LOGIC:= '0';
	signal	Shift_Reg	:  STD_LOGIC:= '0';
	signal	JumptoReg	:  STD_LOGIC:= '0';
	signal	Hi_Reg 		:  STD_LOGIC:= '0';
	signal	Lo_Reg 		:  STD_LOGIC:= '0';
	signal	Write_HiLo	:  STD_LOGIC:= '0';
----------------------------------------------------------------
-- Register File Signals
----------------------------------------------------------------
 	signal	ReadAddr1_Reg 	:  STD_LOGIC_VECTOR (4 downto 0);
	signal	ReadAddr2_Reg 	:  STD_LOGIC_VECTOR (4 downto 0);
	signal	ReadData1_Reg 	:  STD_LOGIC_VECTOR (31 downto 0);
	signal	ReadData2_Reg 	:  STD_LOGIC_VECTOR (31 downto 0);
	signal	WriteAddr_Reg	:  STD_LOGIC_VECTOR (4 downto 0); 
	signal	WriteData_Reg 	:  STD_LOGIC_VECTOR (31 downto 0);
	
----------------------------------------------------------------
-- Sign Extend
----------------------------------------------------------------
	signal	signExtendin 		:  STD_LOGIC_VECTOR (15 downto 0);
	signal	signExtendout		:  STD_LOGIC_VECTOR (31 downto 0);
	
----------------------------------------------------------------
-- HiLo register signals
----------------------------------------------------------------	
	signal ReadHi_Reg : STD_LOGIC_VECTOR (31 downto 0);
   signal ReadLo_Reg : STD_LOGIC_VECTOR (31 downto 0);
   signal WriteHi_Reg : STD_LOGIC_VECTOR (31 downto 0);
   signal WriteLo_Reg : STD_LOGIC_VECTOR (31 downto 0);
	signal RegHiLoWrite :  STD_LOGIC;
----------------------------------------------------------------
-- Other Signals
----------------------------------------------------------------
	--<any other signals used goes here>
 

----------------------------------------------------------------	
----------------------------------------------------------------
-- <MIPS architecture>
----------------------------------------------------------------
----------------------------------------------------------------
begin

----------------------------------------------------------------
-- PC port map
----------------------------------------------------------------
PC1				: PC port map
						(
						PC_in 	=> PC_in, 
						PC_out 	=> PC_out, 
						RESET 	=> RESET,
						CLK 		=> CLK
						);
						
----------------------------------------------------------------
-- ALU port map
----------------------------------------------------------------
ALU1		: ALU 
					generic map (width =>  32)
					port map
						(
						Clk => Clk,
						Operand1 	=> ALU_InA, 
						Operand2 	=> ALU_InB, 
						Control => Control, 
						Result1 => Result1,
						Result2 => Result2,
						Status => Status,
						ALU_zero => ALU_zero,
						ALU_greater => ALU_greater
						);
					
----------------------------------------------------------------
-- Control Unit port map
----------------------------------------------------------------
ControlUnit1 	: ControlUnit port map
						(
						Control_Instr 		=> opcode, 
						ALUOp 		=> ALUOp, 
						Branch 		=> Branch, 
						Jump 			=> Jump, 
						MemRead 		=> MemRead, 
						MemtoReg 	=> MemtoReg, 
						InstrtoReg 	=> InstrtoReg, 
						MemWrite 	=> MemWrite, 
						ALUSrc 		=> ALUSrc, 
						SignExtend 	=> SignExtend, 
						RegWrite 	=> RegWrite, 
						RegDst 		=> RegDst,
						Data_InA	=> Data_InA,
						Shift_Amt	=> Shift_Amt,
						Shift_Reg	=> Shift_Reg,
						JumptoReg	=> JumptoReg,
						Hi_Reg 		=> Hi_Reg,
						Lo_Reg 		=> Lo_Reg,
						Write_HiLo	=> Write_HiLo,
						LinkReg     => LinkReg
						);
						
----------------------------------------------------------------
-- Register file port map
----------------------------------------------------------------
RegFile1			: RegFile port map
						(
						ReadAddr1_Reg 	=>  ReadAddr1_Reg,
						ReadAddr2_Reg 	=>  ReadAddr2_Reg,
						ReadData1_Reg 	=>  ReadData1_Reg,
						ReadData2_Reg 	=>  ReadData2_Reg,
						WriteAddr_Reg 	=>  WriteAddr_Reg,
						WriteData_Reg 	=>  WriteData_Reg,
						RegWrite 		=> RegWrite,
						CLK 				=> CLK				
						);

----------------------------------------------------------------
-- SignExtend port map
----------------------------------------------------------------
SignExtend1 				: Sign_Extend port map
						(
						signExtendInput => signExtendin, 
						signExtendOutput => signExtendout 						
						);
						
----------------------------------------------------------------
-- HiLo Register port map
----------------------------------------------------------------						
HiLO_reg1 :		HILO_reg port map
						(
						ReadHi_Reg => ReadHi_Reg,
						ReadLo_Reg => ReadLo_Reg ,
						WriteHi_Reg => WriteHi_Reg,
						WriteLo_Reg	=> WriteLo_Reg,
						RegHiLoWrite => RegHiLoWrite,
						CLK => CLK
						);					

----------------------------------------------------------------
-- Processor logic
----------------------------------------------------------------
--<Rest of the logic goes here>

--Fetching of instructions accounted for by PC1

--Decoding instructions for Control Unit
opcode <= Instr;

--Reading register values
ReadAddr1_Reg <= Instr(25 downto 21); 
ReadAddr2_Reg <= Instr(20 downto 16);


--SignExtend for address offset
--for load and store operations
signExtendin <= Instr(15 downto 0);


Control <=  "001010" when ALUOp = "00" and Instr(31 downto 26) = "001101" else --ori
				"000010" when ALUOp = "00" else -- add when lw, sw, addi
				--Branch
				"000100" when ALUOp = "01" and Instr(31 downto 26) = "000100" else --beq
				"000011" when ALUOp = "01" and Instr(31 downto 26) = "000001" else --bgez/bgezal
				--R Type
				"000000" when ALUOp = "10" and Instr(5 downto 0) = "100100" else	-- and
				"000001" when ALUOp = "10" and Instr(5 downto 0) = "100101" else	-- or
				"001100" when ALUOp = "10" and Instr(5 downto 0) = "100111" else	-- nor
				"000100" when ALUOp = "10" and Instr(5 downto 0) = "100110" else	-- xor
				"000010" when ALUOp = "10" and Instr(5 downto 0) = "100000" else	-- add
				"000110" when ALUOp = "10" and Instr(5 downto 0) = "100010" else	-- sub
				"000111" when ALUOp = "10" and Instr(5 downto 0) = "101010" else -- slt
				"001110" when ALUOp = "10" and Instr(5 downto 0) = "101011"else	-- sltu
				"000101" when (Instr(5 downto 0) = "000000" or Instr(5 downto 0) = "000100") else	-- sll, sllv
				"001101" when (Instr(5 downto 0) = "000010" or Instr(5 downto 0) = "000110") else	-- srl, srlv
				"001001" when (Instr(5 downto 0) = "000011" or Instr(5 downto 0) = "000111") else	-- sra, srav
				"100000" when ALUOp = "10" and Instr(5 downto 0) = "011000" else	-- mult
				"100001" when ALUOp = "10" and Instr(5 downto 0) = "011001" else	-- multu
				"XXXXXX"; -- j

----Unconditional(old working code)
--ALU_InA  <= ReadData1_Reg;
--
----for R type and BEQ operations 
--ALU_InB <= ReadData2_Reg when ALUSrc = '0' else
----ALUSrc = 1 
--Instr(15 downto 0)& x"0000" when InstrtoReg = '1' else -- LUI
----x"0000" & Instr(15 downto 0) when ALUOp = "11" and InstrtoReg = '0' else --ORI
--x"0000" & Instr(15 downto 0) when SignExtend = '0' else -- ORI
--signExtendout; -- LW/SW


ALU_InA  <= ReadData2_Reg when Data_InA = '1' else --sll,sllv,sra,srl
ReadData1_Reg;

ALU_InB <= Instr when Shift_Amt = '1' else --sll, sra,srl
ReadData1_Reg when Shift_Reg = '1' else --sllv
ReadData2_Reg when ALUSrc = '0' else  --remaining r-type instructions and BEQ
x"0000" & Instr(15 downto 0) when SignExtend = '0' else -- ORI
signExtendout; -- LW/SW/SLTI/ADDI (15 downto 0)-offset

--PC
PC_in <= PC_out + (signExtendout(29 downto 0) & "00")  when Branch = '1' and ALU_zero = '1' else -- Branch (beq) 
PC_out + (signExtendout(29 downto 0) & "00")  when ((Branch = '1')and (ALU_greater = '1')) else -- Branch (bgez/bgezal)
PC_out(31 downto 28) &(Instr(25 downto 0)& "00") when Jump = '1' else --Jump(J)/ JAL
ReadData1_Reg when JumptoReg = '1' else --JR
PC_out; -- R-type / Lw/ Sw


--RegFile
WriteAddr_Reg <= "11111" when LinkReg = '1' and Jump = '1'else -- JAL
"11111" when LinkReg = '1' and ALU_greater = '1' else -- BGEZAL	
Instr(20 downto 16) when RegDst = '0' else -- choose rt or rd
Instr(15 downto 11);

WriteData_Reg <= Result1 when MemtoReg = '0' else -- choose rt or rd
Instr(15 downto 0)& x"0000" when InstrtoReg = '1' else -- LUI
(PC_out+4) when LinkReg = '1' and Jump = '1' else  -- JAL
(PC_out+4) when LinkReg = '1' and ALU_greater = '1' else -- BGEZAL												
ReadHi_Reg when Hi_Reg = '1' else --MFHI
ReadLo_Reg when Lo_Reg = '1' else --MFLO 
DATA_In; 

--HiLo 
WriteHi_Reg<= Result2; 
WriteLo_Reg<= Result1;
RegHiLoWrite<= Write_HiLo;

--Output to top file
Addr_Instr <= PC_out;
Addr_Data <= Result1;
Data_Out <= ReadData2_Reg;
 

end arch_MIPS;

----------------------------------------------------------------	
----------------------------------------------------------------
-- </MIPS architecture>
----------------------------------------------------------------
----------------------------------------------------------------	
