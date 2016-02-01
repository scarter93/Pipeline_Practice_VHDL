library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipeline is
port (clk : in std_logic;
      a, b, c, d, e : in integer;
      op1, op2, op3, op4, op5, final_output : out integer
  );
end pipeline;

architecture behavioral of pipeline is
--Temporary values for pipelined operations
Signal op1_t, op2_t, op3_t, op4_t, op5_t, final_output_t : integer := 0;

begin
--Assign output to temporary values
op1 <= op1_t;
op2 <= op2_t;
op3 <= op3_t;
op4 <= op4_t;
op5 <= op5_t;
final_output <= final_output_t;

-- perform computation (pipelined)
process (clk)
begin
	if rising_edge(clk) then
		op1_t <= a + b;
		op3_t <= c * d;
		op4_t <= a - e;

		op2_t <= op1_t * 42;
		op5_t <= op3_t * op4_t;

		final_output_t <= op2_t - op5_t;
	end if;
end process;

end behavioral;