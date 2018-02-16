--file pc_interface.vhd

library ieee;
use ieee.std_logic_1164.all;

entity pc_interface is
	port (clock, reset_n: in std_logic;
		  --input data
		  data_in: in std_logic_vector(15 downto 0);
		  rx: in std_logic;
		  --input controls
		  data_in_val: in std_logic;
		  end_of_buffer: in std_logic;
		  --output data
		  command: out std_logic_vector(1 downto 0);
		  param: out std_logic_vector(7 downto 0);
		  tx: out std_logic;
		  --output controls
		  read_req: out std_logic;
		  command_val: out std_logic);
end pc_interface;

architecture structure of pc_interface is
	--component declarations
	component pc_interfaceDP is
		port (clock: in std_logic;
		  --input data signals
		  data_in: in std_logic_vector(15 downto 0);
		  rx: in std_logic;
		  --input control signals
		  mux_in_sel: in std_logic_vector(2 downto 0);
		  mux_char_sel: in std_logic_vector(1 downto 0);
		  reg_sample_clr_n, reg_sample_ld, reg_glitch_clr_n, reg_glitch_ld, reg_char_clr_n, reg_char_ld, sendLF, sendCR,
			uart_reset_n, tx_start, ascii_reset_n, ascii_data_val: in std_logic; --controls from FSM
		  --output control signals
		  command_ctrl: out std_logic_vector(1 downto 0);
		  uart_data_rdy, uart_frame_error, tx_rdy, 
			ascii_ok, ascii_fail: out std_logic; --status to FSM
		  --output data signals
		  tx: out std_logic;
		  command: out std_logic_vector(1 downto 0);
		  param: out std_logic_vector(7 downto 0));
	end component;
	
	component pc_interfaceCU is
		port (clock, reset_n: in std_logic;
		  --input control signals
		  data_in_val: in std_logic;
		  command_ctrl: in std_logic_vector(1 downto 0);
		  end_of_buffer, uart_data_rdy, uart_frame_error, tx_rdy, 
			ascii_ok, ascii_fail: in std_logic; --status from DP
		  --output control signals
		  mux_in_sel: out std_logic_vector(2 downto 0);
		  mux_char_sel: out std_logic_vector(1 downto 0);
		  reg_sample_clr_n, reg_sample_ld, reg_glitch_clr_n, reg_glitch_ld, reg_char_clr_n, reg_char_ld, sendLF, sendCR,
			uart_reset_n, tx_start, ascii_reset_n, ascii_data_val: out std_logic; --controls to DP
		  read_req: out std_logic);
	end component;
	
	--signal declarations
	signal mux_in_sel: std_logic_vector(2 downto 0);
	signal mux_char_sel: std_logic_vector(1 downto 0);
	signal reg_sample_clr_n, reg_sample_ld, reg_glitch_clr_n, reg_glitch_ld, reg_char_clr_n, reg_char_ld, sendLF, sendCR, 
				uart_reset_n, tx_start, ascii_reset_n, ascii_data_val: std_logic;
	signal command_ctrl: std_logic_vector(1 downto 0);			
	signal uart_data_rdy, uart_frame_error, tx_rdy, 
				ascii_ok, ascii_fail: std_logic;
	
begin
	--component instantiations
	DP: pc_interfaceDP port map    (clock => clock,
									data_in => data_in,
									rx => rx,
									reg_sample_clr_n => reg_sample_clr_n,
									reg_sample_ld => reg_sample_ld,
									reg_glitch_clr_n => reg_glitch_clr_n,
									reg_glitch_ld => reg_glitch_ld,
									reg_char_clr_n => reg_char_clr_n,
									reg_char_ld => reg_char_ld,
									mux_in_sel => mux_in_sel,
									sendLF => sendLF,
									sendCR => sendCR,
									mux_char_sel => mux_char_sel,
									uart_reset_n => uart_reset_n,
									tx_start => tx_start,
									ascii_reset_n => ascii_reset_n,
									ascii_data_val => ascii_data_val,
									uart_data_rdy => uart_data_rdy,
									uart_frame_error => uart_frame_error,
									tx_rdy => tx_rdy,
									ascii_ok => ascii_ok,
									ascii_fail => ascii_fail,
									command_ctrl => command_ctrl,
									tx => tx,
									command => command,
									param => param);
									
	CU: pc_interfaceCU port map    (clock => clock,
									reset_n => reset_n,
									data_in_val => data_in_val,
									end_of_buffer => end_of_buffer,
									uart_data_rdy => uart_data_rdy,
									uart_frame_error => uart_frame_error,
									tx_rdy => tx_rdy,
									ascii_ok => ascii_ok,
									ascii_fail => ascii_fail,
									command_ctrl => command_ctrl,
									reg_sample_clr_n => reg_sample_clr_n,
									reg_sample_ld => reg_sample_ld,
									reg_glitch_clr_n => reg_glitch_clr_n,
									reg_glitch_ld => reg_glitch_ld,
									reg_char_clr_n => reg_char_clr_n,
									reg_char_ld => reg_char_ld,
									mux_in_sel => mux_in_sel,
									sendLF => sendLF,
									sendCR => sendCR,
									mux_char_sel => mux_char_sel,
									uart_reset_n => uart_reset_n,
									tx_start => tx_start,
									ascii_reset_n => ascii_reset_n,
									ascii_data_val => ascii_data_val,
									read_req => read_req);
									
	--signal assignment
	command_val <= ascii_ok;
end structure;