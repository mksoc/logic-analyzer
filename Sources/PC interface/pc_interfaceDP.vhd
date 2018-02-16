--file pc_interfaceDP.vhd

library ieee;
use ieee.std_logic_1164.all;

entity pc_interfaceDP is
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
end pc_interfaceDP;

architecture strucure of pc_interfaceDP is
	--component declarations
	component reg is
		generic (N: positive := 8);
		port (R: in std_logic_vector(N-1 downto 0);
			  clock, clear, load: in std_logic;
			  Q: out std_logic_vector(N-1 downto 0));
	end component;
	
	component ENC_B_ASCII IS
	PORT(
			CAMPIONE : IN STD_LOGIC;
			GLITCH : IN STD_LOGIC;
			LF : IN STD_LOGIC;
			CR : IN STD_LOGIC;
			CODE_ASCII : OUT STD_LOGIC_VECTOR ( 7 DOWNTO 0 )
			);
	END component;
	
	component uart is 
		port (clock, reset_n: in std_logic;
			  loopback: in std_logic;
			  tx_start: in std_logic;
			  data_in: in std_logic_vector(7 downto 0);
			  rx: in std_logic;
			  data_available: buffer std_logic;
			  tx_rdy, frame_error: out std_logic;
			  data_out: buffer std_logic_vector(7 downto 0);
			  tx: out std_logic);
	end component;
	
	component ascii_dec is
		port (clock, reset_n: in std_logic;
			  data_in: in std_logic_vector(7 downto 0);
			  data_val: in std_logic;
			  command: out std_logic_vector(1 downto 0);
			  param: out std_logic_vector(7 downto 0);
			  ok, fail: out std_logic);
	end component;
	
	--signal declarations
	signal sample, glitch, ascii_char, ascii_char_selected, char_saved, rx_data: std_logic_vector(7 downto 0);
	signal channel_data, command_int: std_logic_vector(1 downto 0);
	
begin
	--component instantiations
	sample_reg: reg generic map (N => 8)
					port map (R => data_in(15 downto 8),
							  clock => clock,
							  clear => reg_sample_clr_n,
							  load => reg_sample_ld,
							  Q => sample);
							  
	glitch_reg: reg generic map (N => 8)
					port map (R => data_in(7 downto 0),
							  clock => clock,
							  clear => reg_glitch_clr_n,
							  load => reg_glitch_ld,
							  Q => glitch);
							  
	ascii_enc0: ENC_B_ASCII port map (CAMPIONE => channel_data(1),
									  GLITCH => channel_data(0),
									  LF => sendLF,
									  CR => sendCR,
									  CODE_ASCII => ascii_char);
									  
	char_reg:	reg generic map (N => 8)
					port map   (R => ascii_char_selected,
								clock => clock,
								clear => reg_char_clr_n,
								load => reg_char_ld,
								Q => char_saved);
									  
	uart0: uart port map (clock => clock,
						  reset_n => uart_reset_n,
						  loopback => '0',
						  tx_start => tx_start,
						  data_in => char_saved,
						  rx => rx,
						  data_available => uart_data_rdy,
						  tx_rdy => tx_rdy,
						  frame_error => uart_frame_error,
						  data_out => rx_data,
						  tx => tx);
						  
	ascii_dec0: ascii_dec port map (clock => clock,
									reset_n => ascii_reset_n,
									data_in => rx_data,
									data_val => ascii_data_val,
									command => command_int,
									param => param,
									ok => ascii_ok,
									fail => ascii_fail);
									
						  
	--signal assignments
	channel_data <= sample(0) & glitch(0) when mux_in_sel = "111" else
					sample(1) & glitch(1) when mux_in_sel = "110" else
					sample(2) & glitch(2) when mux_in_sel = "101" else
					sample(3) & glitch(3) when mux_in_sel = "100" else
					sample(4) & glitch(4) when mux_in_sel = "011" else
					sample(5) & glitch(5) when mux_in_sel = "010" else
					sample(6) & glitch(6) when mux_in_sel = "001" else
					sample(7) & glitch(7);
					
	ascii_char_selected <=	ascii_char when mux_char_sel = "00" else
							"01001111" when mux_char_sel = "01" else --'O' char
							"01001011"; --'K' char

	command_ctrl <= command_int;
	command <= command_int;
	
end strucure;