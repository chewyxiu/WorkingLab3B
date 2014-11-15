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
    Port ( 	Control_Instr 		: in  STD_LOGIC_VECTOR (31 downto 0);
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
				Data_InA		: out  STD_LOGIC:= '0';
				Shift_Amt	: out  STD_LOGIC:= '0';
				Shift_Reg	: out  STD_LOGIC:= '0';
				JumptoReg	: out  STD_LOGIC:= '0';
				Hi_Reg 		: out  STD_LOGIC:= '0';
				Lo_Reg 		: out  STD_LOGIC:= '0';
				Write_HiLo	: out  STD_LOGIC:= '0';
				LinkReg     : out  STD_LOGIC := '0');
				
end ControlUnit;


architecture arch_ControlUnit of ControlUnit is  
begin  

process(Control_Instr) 
begin 

	case Control_Instr(31 downto 26) is 
	
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
		Data_InA <= '0';
		Shift_Amt <= '0';
		Shift_Reg <= '0';
		JumptoReg <= '0';
		Hi_Reg <= '0';
		Lo_Reg <= '0';
		Write_HiLo <= '0';
		
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
		Data_InA	<= '0';
		Shift_Amt <= '0';
		Shift_Reg <= '0';
		JumptoReg <= '0';
		Hi_Reg <= '0';
		Lo_Reg <= '0';
		Write_HiLo <= '0';
	
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
		Data_InA	<= '0';		
		Shift_Amt <= '0';
		Shift_Reg <= '0';
		JumptoReg <= '0';
		Hi_Reg <= '0';
		Lo_Reg <= '0';
		Write_HiLo <= '0';
	
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
		Data_InA	<= '0';		
		Shift_Amt <= '0';
		Shift_Reg <= '0';
		JumptoReg <= '0';
		Hi_Reg <= '0';
		Lo_Reg <= '0';
		Write_HiLo <= '0';
	
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
		Data_InA	<= '0';		
		Shift_Amt <= '0';
		Shift_Reg <= '0';
		JumptoReg <= '0';
		Hi_Reg <= '0';
		Lo_Reg <= '0';
		Write_HiLo <= '0';
	
	--ADD,SUB, OR, NOR, SLT, SLTU,  MULT, MULTU,
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
		
		if Control_Instr(5 downto 3) ="000" then --sll,sllv,sra,srl 
		Data_InA <= '1'; --Read Data2
		else
		Data_InA <= '0';
		end if;
		
		if Control_Instr(5 downto 2)= "0000" then ----sll, sra,srl
		Shift_Amt <= '1';
		Shift_Reg <= '0';
		elsif Control_Instr(5 downto 0) = "000100" then --sllv
		Shift_Amt <= '0';
		Shift_Reg <= '1';
		else
		Shift_Amt <= '0';
		Shift_Reg <= '0';
		end if;
		
		if Control_Instr(5 downto 0) = "001000" then --JR
		JumptoReg <= '1';
		else
		JumptoReg <= '0';
		end if;
		
		if Control_Instr(5 downto 0) = "010000" then --mfhi
		Hi_Reg <= '1';
		Lo_Reg <= '0';
		else
		Hi_Reg <= '0';
		Lo_Reg <= '0';
		end if; 
		
		if Control_Instr(5 downto 0) = "010010" then --mflo
		Hi_Reg <= '0';
		Lo_Reg <= '1';
		else
		Hi_Reg <= '0';
		Lo_Reg <= '0';
		end if; 
		
		if Control_Instr(5 downto 0) = "011000" or Control_Instr(5 downto 0) = "011001" then --MULT/MULTU
		Write_HiLo <= '1';
		else
		Write_HiLo <= '0';
		end if;
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
		Data_InA <= '0';
		Shift_Amt <= '0';
		Shift_Reg <= '0';
		JumptoReg <= '0';
		Hi_Reg <= '0';
		Lo_Reg <= '0';
		Write_HiLo <= '0';
	
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
		Data_InA <= '0';
		Shift_Amt <= '0';
		Shift_Reg <= '0';
		JumptoReg <= '0';
		Hi_Reg <= '0';
		Lo_Reg <= '0';
		Write_HiLo <= '0';
	
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
		Data_InA <= '0';
		Shift_Amt <= '0';
		Shift_Reg <= '0';
		JumptoReg <= '0';
		Hi_Reg <= '0';
		Lo_Reg <= '0';
		Write_HiLo <= '0';
	
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
		Data_InA <= '0';
		Shift_Amt <= '0';
		Shift_Reg <= '0';
		JumptoReg <= '0';
		Hi_Reg <= '0';
		Lo_Reg <= '0';
		Write_HiLo <= '0';
	
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
		LinkReg <= '0';
		Data_InA <= '0';
		Shift_Amt <= '0';
		Shift_Reg <= '0';
		JumptoReg <= '0';
		Hi_Reg <= '0';
		Lo_Reg <= '0';
		Write_HiLo <= '0';
	end case;

end process;
end arch_ControlUnit;

