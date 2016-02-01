LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

ENTITY pipeline_tb IS
END pipeline_tb;

ARCHITECTURE behaviour OF pipeline_tb IS

COMPONENT pipeline IS
port (clk : in std_logic;
      a, b, c, d, e : in integer;
      op1, op2, op3, op4, op5, final_output : out integer
  );
END COMPONENT;

--The input signals with their initial values
SIGNAL clk: STD_LOGIC := '0';
SIGNAL s_a, s_b, s_c, s_d, s_e : INTEGER := 0;
SIGNAL s_op1, s_op2, s_op3, s_op4, s_op5, s_final_output : INTEGER := 0;

CONSTANT clk_period : time := 1 ns;

BEGIN
dut: pipeline
PORT MAP(clk, s_a, s_b, s_c, s_d, s_e, s_op1, s_op2, s_op3, s_op4, s_op5, s_final_output);

 --clock process
clk_process : PROCESS
BEGIN
	clk <= '0';
	WAIT FOR clk_period/2;
	clk <= '1';
	WAIT FOR clk_period/2;
END PROCESS;
 

stim_process: PROCESS
BEGIN   
	--Stimulate the inputs for the pipelined equation ((a + b) * 42) - (c * d * (a - e)) and assert the results
	REPORT "test cases";
	--load first case
	s_a <= 1;
	s_b <= 2;
	s_c <= 3;
	s_d <= 4;
	s_e <= 5;
	
	WAIT FOR 1 * clk_period;	
	-- as pipeline fills
	ASSERT(s_op1 = 3) REPORT "OP1 failed" SEVERITY ERROR;
	ASSERT(s_op3 = 12) REPORT "OP3 failed" SEVERITY ERROR;
	ASSERT(s_op4 = -4) REPORT "OP4 failed" SEVERITY ERROR;
	--load next case after checking output of first pipeline stage
	s_a <= 6;
	s_b <= 2;
	s_c <= 3;
	s_d <= 4;
	s_e <= 5;
	
	WAIT FOR 1 * clk_period;	
	--as pipeline fills
	ASSERT(s_op1 = 8) REPORT "OP1 failed" SEVERITY ERROR;
	ASSERT(s_op3 = 12) REPORT "OP3 failed" SEVERITY ERROR;
	ASSERT(s_op4 = 1) REPORT "OP4 failed" SEVERITY ERROR;

	ASSERT(s_op2 = 126) REPORT "OP2 failed" SEVERITY ERROR;
	ASSERT(s_op5 = -48) REPORT "OP5 failed" SEVERITY ERROR;
	--load next case, after checking previous values
	s_a <= 1;
	s_b <= 2;
	s_c <= 3;
	s_d <= 4;
	s_e <= 5;
	
	WAIT FOR 1 * clk_period;	
	--full pipeline
	ASSERT(s_op1 = 3) REPORT "OP1 failed" SEVERITY ERROR;
	ASSERT(s_op3 = 12) REPORT "OP3 failed" SEVERITY ERROR;
	ASSERT(s_op4 = -4) REPORT "OP4 failed" SEVERITY ERROR;

	ASSERT(s_op2 = 336) REPORT "OP2 failed" SEVERITY ERROR;
	ASSERT(s_op5 = 12) REPORT "OP5 failed" SEVERITY ERROR;

	ASSERT(s_final_output = 174) REPORT "final_output failed" SEVERITY ERROR;
	--load next case, after checking previous pipeline values
	s_a <= 4;
	s_b <= 1;
	s_c <= 6;
	s_d <= 8;
	s_e <= -1;

	WAIT FOR 1 * clk_period;
	--full pipeline
	ASSERT(s_op1 = 5) REPORT "OP1 failed" SEVERITY ERROR;
	ASSERT(s_op3 = 48) REPORT "OP3 failed" SEVERITY ERROR;
	ASSERT(s_op4 = 5) REPORT "OP4 failed" SEVERITY ERROR;

	ASSERT(s_op2 = 126) REPORT "OP2 failed" SEVERITY ERROR;
	ASSERT(s_op5 = -48) REPORT "OP5 failed" SEVERITY ERROR;

	ASSERT(s_final_output = 324) REPORT "final_output failed" SEVERITY ERROR;
	-- load final case after checking the values from earlier
	s_a <= -1;
	s_b <= -2;
	s_c <= 7;
	s_d <= -4;
	s_e <= 5;

	WAIT FOR 1 * clk_period;
	-- assert values to ensure effective pipelining (full pipeline)
	ASSERT(s_op1 = -3) REPORT "OP1 failed" SEVERITY ERROR;
	ASSERT(s_op3 = -28) REPORT "OP3 failed" SEVERITY ERROR;
	ASSERT(s_op4 = -6) REPORT "OP4 failed" SEVERITY ERROR;

	ASSERT(s_op2 = 210) REPORT "OP2 failed" SEVERITY ERROR;
	ASSERT(s_op5 = 240) REPORT "OP5 failed" SEVERITY ERROR;

	ASSERT(s_final_output = 174) REPORT "final_output failed" SEVERITY ERROR;

	WAIT FOR 1 * clk_period;
	-- assert values to ensure effective pipelining
	-- pipeline draining
	ASSERT(s_op2 = -126) REPORT "OP2 failed" SEVERITY ERROR;
	ASSERT(s_op5 = 168) REPORT "OP5 failed" SEVERITY ERROR;

	ASSERT(s_final_output = -30) REPORT "final_output failed" SEVERITY ERROR;

	WAIT FOR 1 * clk_period;
	-- assert values finalvalue to ensure last operation completed successfully
	-- pipeline drained
	ASSERT(s_final_output = -294) REPORT "final_output failed" SEVERITY ERROR;

	WAIT;
END PROCESS stim_process;
END;
