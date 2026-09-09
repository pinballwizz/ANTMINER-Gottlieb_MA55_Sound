---------------------------------------------------------------------------------
--                      Gottlieb MA55 Sound Board - ANTMINER S9
--                             Code from James Sweet
--
--                           Modified for ANTMINER S9 
--                               by pinballwiz
--                                 08/09/2026
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------
entity ma55_antminer is
port(
	clock_50    : in std_logic;
   	I_RESET     : in std_logic;
	O_AUDIO_L 	: out std_logic;
	O_AUDIO_R 	: out std_logic;
   	ps2_clk     : inout std_logic;
	ps2_dat     : inout std_logic;
	led         : out std_logic_vector(7 downto 0);
	aled        : out std_logic_vector(3 downto 0)
);
end ma55_antminer;
--------------------------------------------------------------------------------
architecture struct of ma55_antminer is
 
 signal	clock_48    : std_logic;
 signal	clock_24    : std_logic;
 signal	clock_14    : std_logic;
 signal clock_3p58	: std_logic;
 signal clkdiv		: std_logic_vector(5 downto 0);
 --
 signal snd_crtl    : std_logic_vector(3 downto 0);
 signal reset	    : std_logic;
 signal Test	    : std_logic;
 --
 signal audio	    : std_logic;
 --
 signal codeReady	: std_logic;
 signal scanCode	: std_logic_vector(9 downto 0);
 --
 constant CLOCK_FREQ    : integer := 27E6;
 signal counter_clk     : std_logic_vector(25 downto 0);
 signal clock_4hz       : std_logic;
 signal AD              : std_logic_vector(11 downto 0);
------------------------------------------------------------------------------
component ma55_clocks
port(
  clk_out1          : out    std_logic;
  clk_out2          : out    std_logic;
  clk_in1           : in     std_logic
 );
end component;
------------------------------------------------------------------------------
begin

 reset <= not I_RESET;
 aled(3 downto 0) <= "1111"; -- turn unused onboard leds off
------------------------------------------------------------------------------
Clocks: ma55_clocks
    port map (
        clk_in1   => clock_50,
        clk_out1  => clock_48,
        clk_out2  => clock_14
    );
------------------------------------------------------------------------------
-- Clocks Divide

process (clock_48)
begin
 if rising_edge(clock_48) then
	clock_24  <= not clock_24;
 end if;
end process;
--
process (clock_14)
begin
 if rising_edge(clock_14) then
	clkdiv <= clkdiv + 1;
	clock_3p58 <= clkdiv(1);
 end if;
end process;
------------------------------------------------------------------------------
-- Main

MA55: entity work.MA_55
port map(
	clk_358    => clock_3p58,
	dac_clk    => Clock_48,
	reset_l    => I_RESET,
	S1         => snd_crtl(0),
	S2         => snd_crtl(1),
	S4         => snd_crtl(2),
	S8         => snd_crtl(3),
	Spare      => '0',
	Test       => Test,
	Attract    => '0', -- 0 to enable
	Sound_Tones => '1', -- default = 1
	Audio_O    => audio,
	AD         => AD
	);
---------------------------------------------------------------------
-- Audio Out

O_AUDIO_L <= audio;
O_AUDIO_R <= audio;
---------------------------------------------------------------------
-- Keyboard

keyboard: entity work.Keyboard
port map(
		Reset     => reset,
		Clock     => clock_48,
		PS2Clock  => ps2_clk,
		PS2Data   => ps2_dat,
		CodeReady => codeready,
		ScanCode  => scancode
		);	
----------------------------------------------------------------------
-- Connect PS2 scancodes to sound control inputs, 15 possible inputs decoded to specific keys
-- Q W E R T Y U I O P A S D F G

scan_decode : process(scancode)
   begin
		if scancode(8) = '0' then
			case scancode(7 downto 0) is
			when x"15" =>
				--snd_crtl <= "0001";
				Test <= '0';
			when x"1D" =>
				snd_crtl <= "0010";
			when x"24" =>
				snd_crtl <= "0001";
			when x"2D" =>
				snd_crtl <= "0100";
			when x"2C" =>
				snd_crtl <= "0101";
			when x"35" =>
				snd_crtl <= "0110";
			when x"3C" =>
				snd_crtl <= "0111";
			when x"43" =>
				snd_crtl <= "1000";
			when x"44" =>
				snd_crtl <= "1001";
			when x"4D" =>
				snd_crtl <= "1010";
			when x"1C" =>
				snd_crtl <= "1011";
			when x"1B" =>
				snd_crtl <= "1100";
			when x"23" => 
				snd_crtl <= "1101";
			when x"2B" =>
				snd_crtl <= "1110";
			when x"34" =>
				snd_crtl <= "0000";
			when others =>
				snd_crtl <= "1111";
			end case;
		else snd_crtl <= "1111";
		end if;
   end process;
------------------------------------------------------------------------------
-- debug

process(reset, clock_24)
begin
  if reset = '1' then
   clock_4hz <= '0';
   counter_clk <= (others => '0');
  else
    if rising_edge(clock_24) then
      if counter_clk = CLOCK_FREQ/8 then
        counter_clk <= (others => '0');
        clock_4hz <= not clock_4hz;
        led(7 downto 0) <= not AD(11 downto 4);
      else
        counter_clk <= counter_clk + 1;
      end if;
    end if;
  end if;
end process;	
----------------------------------------------------------------------------
end struct;