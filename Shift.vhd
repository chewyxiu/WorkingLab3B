----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:58:07 09/26/2014 
-- Design Name: 
-- Module Name:    Shift - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;	

entity Shift is
    Port (
			Shift_Controls :in STD_LOGIC_VECTOR(1 downto 0); --(0) is for direction, (1) is for shift type
			Operand1 : in  STD_LOGIC_VECTOR (31 downto 0);
           Operand2 : in  STD_LOGIC_VECTOR (4 downto 0);
           Result1 : out  STD_LOGIC_VECTOR (31 downto 0));
end Shift;

architecture Behavioral of Shift is

component sll_shifter is
	Port( Source : in  STD_LOGIC_VECTOR (31 downto 0);
			Command: in STD_LOGIC_VECTOR (1 downto 0);
           Shift_number : in  STD_LOGIC_VECTOR (4 downto 0);
           sll_output : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component srl_shifter is
	Port( Source : in  STD_LOGIC_VECTOR (31 downto 0);
			Command: in STD_LOGIC_VECTOR (1 downto 0);
           Shift_number : in  STD_LOGIC_VECTOR (4 downto 0);
           srl_output : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component sra_shifter is
	Port( Source : in  STD_LOGIC_VECTOR (31 downto 0);
			Command: in STD_LOGIC_VECTOR (1 downto 0);
           Shift_number : in  STD_LOGIC_VECTOR (4 downto 0);
           sra_output : out  STD_LOGIC_VECTOR (31 downto 0));
end component;


signal sll_output1 : STD_LOGIC_VECTOR(31 downto 0);
signal srl_output1 : STD_LOGIC_VECTOR(31 downto 0);
signal sra_output1 : STD_LOGIC_VECTOR(31 downto 0);

begin

--Port maps

shift_left : sll_shifter
port map ( Source => Operand1, Shift_number => Operand2, Command => Shift_controls, sll_output => sll_output1);
shift_right : srl_shifter
port map ( Source => Operand1, Shift_number => Operand2, Command => Shift_controls, srl_output => srl_output1);
shift_arith_right : sra_shifter
port map ( Source => Operand1, Shift_number => Operand2, Command => Shift_controls, sra_output => sra_output1);


Result1 <= sll_output1 when Shift_controls = "01" else
			srl_output1 when Shift_controls = "11" else
			sra_output1;
			
end Behavioral;

