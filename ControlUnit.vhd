----------------------------------------------------------------------------------
-- Company: NUS
-- Engineer: Rajesh Panicker
-- 
-- Create Date:   21:06:18 14/10/2014
-- Design Name: 	ControlUnit
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool versions: ISE 14.7
-- Description: Control Unit for the basic MIPS processor
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: The interface (entity) as well as implementation (architecture) can be modified
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity ControlUnit is
    Port ( 	opcode 		: in  STD_LOGIC_VECTOR (5 downto 0);
				ALUOp 		: out  STD_LOGIC_VECTOR (1 downto 0);
				Branch 		: out  STD_LOGIC := '0';		
				Jump	 		: out  STD_LOGIC := '0';	
				MemRead 		: out  STD_LOGIC := '0';
				MemtoReg 	: out  STD_LOGIC := '0';	
				InstrtoReg	: out STD_LOGIC := '0';
				MemWrite		: out  STD_LOGIC := '0';	
				ALUSrc 		: out  STD_LOGIC := '0';
				SignExtend 	: out  STD_LOGIC := '0';
				RegWrite		: out  STD_LOGIC := '0';	
				RegDst		: out  STD_LOGIC:= '0';
				LinkReg     : out  STD_LOGIC := '0');
				
end ControlUnit;


architecture arch_ControlUnit of ControlUnit is  
begin  

process(opcode) 
begin 

	case opcode is 
	
	--lw(i type)
	when "100011" =>
		ALUOp <= "00";
		Branch <= '0';
		Jump <= '0';
		MemRead <= '1';
		MemToReg <= '1';
		InstrtoReg <= '0';
		MemWrite <= '0';
		ALUSrc <= '1';
		SignExtend <= '1';
		RegWrite <= '1';
		RegDst <= '0';
		LinkReg <= '0';
		
		
	--sw(i type)
	when "101011" => 
	
		ALUOp <= "00";
		Branch <= '0';
		Jump <= '0';
		MemRead <= '0';
		MemToReg <= 'X';
		InstrtoReg <= '0';
		MemWrite <= '1';
		ALUSrc <= '1';
		SignExtend <= '1';
		RegWrite <= '0';
		RegDst <= 'X';	
		LinkReg <= '0';

	--lui (upper immediate bits) (i type)
	when "001111" => 
		ALUOp <= "00";
		Branch <= '0';
		Jump <= '0';
		MemRead <= '0';
		MemToReg <= '0';
		InstrtoReg <= '1'; --only for lui
		MemWrite <= '0';
		ALUSrc <= '1';
		SignExtend <= '0';
		RegWrite <= '1';
		RegDst <= '0';
		LinkReg <= '0';		

	--ori (i type)
	when "001101" => 
		ALUOp <= "00";
		Branch <= '0';
		Jump <= '0';
		MemRead <= '0';
		MemToReg <= '0';
		InstrtoReg <= '0';
		MemWrite <= '0';
		ALUSrc <= '1';
		SignExtend <= '0';
		RegWrite <= '1';
		RegDst <= '0';
		LinkReg <= '0';
		
		
	-- addi(i type)
	when "001000" => 
		ALUOp <= "00";
		Branch <= '0';
		Jump <= '0';
		MemRead <= '0';
		MemToReg <= '0';
		InstrtoReg <= '0';
		MemWrite <= '0';
		ALUSrc <= '1';
		SignExtend <= '1';
		RegWrite <= '1';
		RegDst <= '0';
		LinkReg <= '0';

	--ADD,SUB, OR, NOR, SLT, SLTU,  MULT, MULTU, MFHI, MFLO ,
	--AND, NOR, OR, ORI, SLL, SRA, SRL, SLLV, JR(R-type)
	when "000000" =>
		ALUOp <= "10";
		Branch <= '0';
		Jump <= '0';
		MemRead <= '0';
		MemToReg <= '0';
		InstrtoReg <= '0';
		MemWrite <= '0';
		ALUSrc <= '0';
		SignExtend <= '0';
		RegWrite <= '1';
		RegDst <= '1';
		LinkReg <= '0';
	
	--beq
	when "000100" =>
		ALUOp <= "01";
		Branch <= '1';
		Jump <= '0';
		MemRead <= '0';
		MemToReg <= 'X';
		InstrtoReg <= '0';
		MemWrite <= '0';
		ALUSrc <= '0';
		SignExtend <= '1';
		RegWrite <= '0';
		RegDst <= 'X';
		LinkReg <= '0';
		
	-- bgez or bgezal
	when "000001" => 
		ALUOp <= "01";
		Branch <= '1';
		Jump <= '0';
		MemRead <= '0';
		MemToReg <= 'X';
		InstrtoReg <= '0';
		MemWrite <= '0';
		ALUSrc <= '0';
		SignExtend <= '1';
		RegWrite <= '0';
		RegDst <= 'X';
		LinkReg <= '1';
	
	--j
	when "000010" =>
		ALUOp <= "XX";
		Branch <= '0';
		Jump <= '1';
		MemRead <= '0';
		MemToReg <= 'X';
		InstrtoReg <= '0';
		MemWrite <= '0';
		ALUSrc <= 'X';
		SignExtend <= '0';
		RegWrite <= '0';
		RegDst <= 'X';
		LinkReg <= '0';
		
	--jal
	when "000011" =>
		ALUOp <= "XX";
		Branch <= '0';
		Jump <= '1';
		MemRead <= '0';
		MemToReg <= 'X';
		InstrtoReg <= '0';
		MemWrite <= '0';
		ALUSrc <= 'X';
		SignExtend <= '0';
		RegWrite <= '0';
		RegDst <= 'X';	
		LinkReg <= '1';

	when others =>
		ALUOp <= "XX";
		Branch <= '0';
		Jump <= '0';
		MemRead <= '0';
		MemToReg <= 'X';
		InstrtoReg <= '0';
		MemWrite <= '0';
		ALUSrc <= 'X';
		SignExtend <= '0';
		RegWrite <= '0';
		RegDst <= 'X';


	end case;
end process;
end arch_ControlUnit;

