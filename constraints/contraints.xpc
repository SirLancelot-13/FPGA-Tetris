## EDGE Artix 7 FPGA Development Board - Master XDC (rev 2.1)
## Invent Logics / allaboutfpga.com
##
## Valid for all three board variants. They share one PCB and one pinout:
##   XC7A35T-1FTG256C  (Vivado part xc7a35tftg256-1)
##   XC7A50T-1FTG256C  (Vivado part xc7a50tftg256-1)
##   XC7A100T-1FTG256C (Vivado part xc7a100tftg256-1)
##
## To use it in a project:
##  - comment out the lines for pins your design does not use
##  - rename the ports (after get_ports) to match your top-level signal names
##
## Pin assignments checked against schematic ARTIX7_V3.
 
## Configuration bank voltage (removes the CFGBVS DRC warning)
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
 
## Optional: faster boot from the Quad SPI flash and a smaller .bin file.
## If you enable these, program the flash with the "-x1_x2_x4" memory part in Vivado.
#set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
#set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
#set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
 
## 50 MHz clock (oscillator Y2)
set_property -dict { PACKAGE_PIN N11 IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -period 20.000 -name sys_clk_pin -waveform {0.000 10.000} [get_ports { clk }];
 
## Slide switches (10 k series resistor to each pin). sw[0] is the rightmost switch, sw[15] the leftmost.
## Board labels run SW3-SW18 from right to left, except SW14-SW17, which sit in the
## order SW15, SW17, SW14, SW16 (PCB Rev 5.2 placement).
set_property -dict { PACKAGE_PIN L5  IOSTANDARD LVCMOS33 } [get_ports { sw[0] }];  # SW3  (LSB)
set_property -dict { PACKAGE_PIN L4  IOSTANDARD LVCMOS33 } [get_ports { sw[1] }];  # SW4
set_property -dict { PACKAGE_PIN M4  IOSTANDARD LVCMOS33 } [get_ports { sw[2] }];  # SW5
set_property -dict { PACKAGE_PIN M2  IOSTANDARD LVCMOS33 } [get_ports { sw[3] }];  # SW6
set_property -dict { PACKAGE_PIN M1  IOSTANDARD LVCMOS33 } [get_ports { sw[4] }];  # SW7
set_property -dict { PACKAGE_PIN N3  IOSTANDARD LVCMOS33 } [get_ports { sw[5] }];  # SW8
set_property -dict { PACKAGE_PIN N2  IOSTANDARD LVCMOS33 } [get_ports { sw[6] }];  # SW9
set_property -dict { PACKAGE_PIN N1  IOSTANDARD LVCMOS33 } [get_ports { sw[7] }];  # SW10
set_property -dict { PACKAGE_PIN P1  IOSTANDARD LVCMOS33 } [get_ports { sw[8] }];  # SW11
set_property -dict { PACKAGE_PIN P4  IOSTANDARD LVCMOS33 } [get_ports { sw[9] }];  # SW12
set_property -dict { PACKAGE_PIN T8  IOSTANDARD LVCMOS33 } [get_ports { sw[10] }]; # SW13
set_property -dict { PACKAGE_PIN R8  IOSTANDARD LVCMOS33 } [get_ports { sw[11] }]; # SW15
set_property -dict { PACKAGE_PIN N6  IOSTANDARD LVCMOS33 } [get_ports { sw[12] }]; # SW17
set_property -dict { PACKAGE_PIN T7  IOSTANDARD LVCMOS33 } [get_ports { sw[13] }]; # SW14
set_property -dict { PACKAGE_PIN P8  IOSTANDARD LVCMOS33 } [get_ports { sw[14] }]; # SW16
set_property -dict { PACKAGE_PIN M6  IOSTANDARD LVCMOS33 } [get_ports { sw[15] }]; # SW18 (MSB)
 
## LEDs (1 = on). Board labels D3-D19 (D7 is the Bluetooth status LED).
set_property -dict { PACKAGE_PIN J3  IOSTANDARD LVCMOS33 } [get_ports { led[0] }];  # D3  (LSB)
set_property -dict { PACKAGE_PIN H3  IOSTANDARD LVCMOS33 } [get_ports { led[1] }];  # D4
set_property -dict { PACKAGE_PIN J1  IOSTANDARD LVCMOS33 } [get_ports { led[2] }];  # D5
set_property -dict { PACKAGE_PIN K1  IOSTANDARD LVCMOS33 } [get_ports { led[3] }];  # D6
set_property -dict { PACKAGE_PIN L3  IOSTANDARD LVCMOS33 } [get_ports { led[4] }];  # D8
set_property -dict { PACKAGE_PIN L2  IOSTANDARD LVCMOS33 } [get_ports { led[5] }];  # D9
set_property -dict { PACKAGE_PIN K3  IOSTANDARD LVCMOS33 } [get_ports { led[6] }];  # D10
set_property -dict { PACKAGE_PIN K2  IOSTANDARD LVCMOS33 } [get_ports { led[7] }];  # D11
set_property -dict { PACKAGE_PIN K5  IOSTANDARD LVCMOS33 } [get_ports { led[8] }];  # D12
set_property -dict { PACKAGE_PIN P6  IOSTANDARD LVCMOS33 } [get_ports { led[9] }];  # D13
set_property -dict { PACKAGE_PIN R7  IOSTANDARD LVCMOS33 } [get_ports { led[10] }]; # D14
set_property -dict { PACKAGE_PIN R6  IOSTANDARD LVCMOS33 } [get_ports { led[11] }]; # D15
set_property -dict { PACKAGE_PIN T5  IOSTANDARD LVCMOS33 } [get_ports { led[12] }]; # D16
set_property -dict { PACKAGE_PIN R5  IOSTANDARD LVCMOS33 } [get_ports { led[13] }]; # D17
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports { led[14] }]; # D18
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports { led[15] }]; # D19 (MSB)
 
## Push buttons (pressed = 1; each has a 10 k pull-down on the board)
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { pb[0] }]; # SW21 top
set_property -dict { PACKAGE_PIN L14 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { pb[1] }]; # SW23 bottom
set_property -dict { PACKAGE_PIN M12 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { pb[2] }]; # SW19 left
set_property -dict { PACKAGE_PIN L13 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { pb[3] }]; # SW20 right
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { pb[4] }]; # SW22 centre (CPU reset in MicroBlaze designs)
 
## 4-digit 7-segment display, common anode
## digit[3:0]: 1 = digit on (each anode is switched by an NPN transistor)
## Seven_Seg[7:0]: 0 = segment on
## NOTE: the eight segment pins are shared with SDRAM address lines A5-A12.
##       In SDRAM designs drive digit[3:0] low to keep the display dark.
set_property -dict { PACKAGE_PIN F2  IOSTANDARD LVCMOS33 } [get_ports { digit[0] }]; # DISP1 (left)
set_property -dict { PACKAGE_PIN E1  IOSTANDARD LVCMOS33 } [get_ports { digit[1] }]; # DISP2
set_property -dict { PACKAGE_PIN G5  IOSTANDARD LVCMOS33 } [get_ports { digit[2] }]; # DISP3
set_property -dict { PACKAGE_PIN G4  IOSTANDARD LVCMOS33 } [get_ports { digit[3] }]; # DISP4 (right)
 
set_property -dict { PACKAGE_PIN G2  IOSTANDARD LVCMOS33 } [get_ports { Seven_Seg[0] }]; # A  (= SDRAM A5)
set_property -dict { PACKAGE_PIN G1  IOSTANDARD LVCMOS33 } [get_ports { Seven_Seg[1] }]; # B  (= SDRAM A6)
set_property -dict { PACKAGE_PIN H5  IOSTANDARD LVCMOS33 } [get_ports { Seven_Seg[2] }]; # C  (= SDRAM A12)
set_property -dict { PACKAGE_PIN H4  IOSTANDARD LVCMOS33 } [get_ports { Seven_Seg[3] }]; # D  (= SDRAM A11)
set_property -dict { PACKAGE_PIN J5  IOSTANDARD LVCMOS33 } [get_ports { Seven_Seg[4] }]; # E  (= SDRAM A8)
set_property -dict { PACKAGE_PIN J4  IOSTANDARD LVCMOS33 } [get_ports { Seven_Seg[5] }]; # F  (= SDRAM A10)
set_property -dict { PACKAGE_PIN H2  IOSTANDARD LVCMOS33 } [get_ports { Seven_Seg[6] }]; # G  (= SDRAM A9)
set_property -dict { PACKAGE_PIN H1  IOSTANDARD LVCMOS33 } [get_ports { Seven_Seg[7] }]; # DP (= SDRAM A7)
 
## USB UART (FT2232H), also available on header J9 (pin 1 = D4 line, pin 2 = C4 line, pin 3 = GND).
## Port names are from the FPGA's point of view.
set_property -dict { PACKAGE_PIN C4  IOSTANDARD LVCMOS33 } [get_ports { usb_uart_txd }]; # FPGA -> PC
set_property -dict { PACKAGE_PIN D4  IOSTANDARD LVCMOS33 } [get_ports { usb_uart_rxd }]; # PC -> FPGA
 
## WiFi, ESP8266-12F (power jumper J3). Port names are from the FPGA's point of view.
set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports { wifi_txd }]; # FPGA -> module RXD
set_property -dict { PACKAGE_PIN G16 IOSTANDARD LVCMOS33 } [get_ports { wifi_rxd }]; # module TXD -> FPGA
 
## Bluetooth, HM-10 BLE (power jumper J4). Port names are from the FPGA's point of view.
set_property -dict { PACKAGE_PIN H14 IOSTANDARD LVCMOS33 } [get_ports { Bluetooth_txd }]; # FPGA -> module RX
set_property -dict { PACKAGE_PIN J16 IOSTANDARD LVCMOS33 } [get_ports { Bluetooth_rxd }]; # module TX -> FPGA
 
## Buzzer (enable jumper J12 on pins 1-2)
set_property -dict { PACKAGE_PIN K12 IOSTANDARD LVCMOS33 } [get_ports { Buzzer }];
 
## SPI DAC (MCP4921), output on J13 pin 3
set_property -dict { PACKAGE_PIN E5  IOSTANDARD LVCMOS33 } [get_ports { SCK }];
set_property -dict { PACKAGE_PIN F5  IOSTANDARD LVCMOS33 } [get_ports { CS }];
set_property -dict { PACKAGE_PIN F4  IOSTANDARD LVCMOS33 } [get_ports { MOSI }];
 
## HDMI out (TMDS)
set_property -dict { PACKAGE_PIN A5  IOSTANDARD TMDS_33 } [get_ports { hdmi_tx_p[0] }];
set_property -dict { PACKAGE_PIN B6  IOSTANDARD TMDS_33 } [get_ports { hdmi_tx_p[1] }];
set_property -dict { PACKAGE_PIN B7  IOSTANDARD TMDS_33 } [get_ports { hdmi_tx_p[2] }];
set_property -dict { PACKAGE_PIN E3  IOSTANDARD TMDS_33 } [get_ports { hdmi_tx_clk_p }];
set_property -dict { PACKAGE_PIN A4  IOSTANDARD TMDS_33 } [get_ports { hdmi_tx_n[0] }];
set_property -dict { PACKAGE_PIN B5  IOSTANDARD TMDS_33 } [get_ports { hdmi_tx_n[1] }];
set_property -dict { PACKAGE_PIN A7  IOSTANDARD TMDS_33 } [get_ports { hdmi_tx_n[2] }];
set_property -dict { PACKAGE_PIN D3  IOSTANDARD TMDS_33 } [get_ports { hdmi_tx_clk_n }];
 
## 2x16 character LCD, connector J7 (8-bit mode; R/W is tied to GND on the board)
## data[n] drives LCD pin DBn. The schematic net names run the other way (net LCD_D0 = DB7).
set_property -dict { PACKAGE_PIN T4  IOSTANDARD LVCMOS33 } [get_ports { data[0] }]; # DB0, J7 pin 7
set_property -dict { PACKAGE_PIN T2  IOSTANDARD LVCMOS33 } [get_ports { data[1] }]; # DB1, J7 pin 8
set_property -dict { PACKAGE_PIN R3  IOSTANDARD LVCMOS33 } [get_ports { data[2] }]; # DB2, J7 pin 9
set_property -dict { PACKAGE_PIN R1  IOSTANDARD LVCMOS33 } [get_ports { data[3] }]; # DB3, J7 pin 10
set_property -dict { PACKAGE_PIN R2  IOSTANDARD LVCMOS33 } [get_ports { data[4] }]; # DB4, J7 pin 11
set_property -dict { PACKAGE_PIN N4  IOSTANDARD LVCMOS33 } [get_ports { data[5] }]; # DB5, J7 pin 12
set_property -dict { PACKAGE_PIN M5  IOSTANDARD LVCMOS33 } [get_ports { data[6] }]; # DB6, J7 pin 13
set_property -dict { PACKAGE_PIN P3  IOSTANDARD LVCMOS33 } [get_ports { data[7] }]; # DB7, J7 pin 14
set_property -dict { PACKAGE_PIN T3  IOSTANDARD LVCMOS33 } [get_ports { lcd_e }];   # E,  J7 pin 6
set_property -dict { PACKAGE_PIN P5  IOSTANDARD LVCMOS33 } [get_ports { lcd_rs }];  # RS, J7 pin 4
 
## 32 MB SDRAM (MT48LC16M16A2, 256 Mb, x16)
set_property -dict { PACKAGE_PIN D8  IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[0] }];
set_property -dict { PACKAGE_PIN C8  IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[1] }];
set_property -dict { PACKAGE_PIN A8  IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[2] }];
set_property -dict { PACKAGE_PIN A9  IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[3] }];
set_property -dict { PACKAGE_PIN B9  IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[4] }];
set_property -dict { PACKAGE_PIN A10 IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[5] }];
set_property -dict { PACKAGE_PIN B10 IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[6] }];
set_property -dict { PACKAGE_PIN C14 IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[7] }];
set_property -dict { PACKAGE_PIN A14 IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[8] }];
set_property -dict { PACKAGE_PIN A13 IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[9] }];
set_property -dict { PACKAGE_PIN D9  IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[10] }];
set_property -dict { PACKAGE_PIN D10 IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[11] }];
set_property -dict { PACKAGE_PIN C9  IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[12] }];
set_property -dict { PACKAGE_PIN A12 IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[13] }];
set_property -dict { PACKAGE_PIN B12 IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[14] }];
set_property -dict { PACKAGE_PIN B11 IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[15] }];
 
set_property -dict { PACKAGE_PIN D11 IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[0] }];
set_property -dict { PACKAGE_PIN E11 IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[1] }];
set_property -dict { PACKAGE_PIN E13 IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[2] }];
set_property -dict { PACKAGE_PIN D14 IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[3] }];
set_property -dict { PACKAGE_PIN F3  IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[4] }];
set_property -dict { PACKAGE_PIN G2  IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[5] }];  # shared with segment A
set_property -dict { PACKAGE_PIN G1  IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[6] }];  # shared with segment B
set_property -dict { PACKAGE_PIN H1  IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[7] }];  # shared with segment DP
set_property -dict { PACKAGE_PIN J5  IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[8] }];  # shared with segment E
set_property -dict { PACKAGE_PIN H2  IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[9] }];  # shared with segment G
set_property -dict { PACKAGE_PIN J4  IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[10] }]; # shared with segment F
set_property -dict { PACKAGE_PIN H4  IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[11] }]; # shared with segment D
set_property -dict { PACKAGE_PIN H5  IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[12] }]; # shared with segment C
 
set_property -dict { PACKAGE_PIN B14 IOSTANDARD LVCMOS33 } [get_ports { sdram_ba[0] }];
set_property -dict { PACKAGE_PIN B15 IOSTANDARD LVCMOS33 } [get_ports { sdram_ba[1] }];
set_property -dict { PACKAGE_PIN E12 IOSTANDARD LVCMOS33 } [get_ports { sdram_dqm[0] }]; # DQML
set_property -dict { PACKAGE_PIN C16 IOSTANDARD LVCMOS33 } [get_ports { sdram_dqm[1] }]; # DQMH
set_property -dict { PACKAGE_PIN D13 IOSTANDARD LVCMOS33 } [get_ports { sdram_clk }];
set_property -dict { PACKAGE_PIN A15 IOSTANDARD LVCMOS33 } [get_ports { sdram_cke }];
set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS33 } [get_ports { sdram_cs_n }];
set_property -dict { PACKAGE_PIN C11 IOSTANDARD LVCMOS33 } [get_ports { sdram_we_n }];
set_property -dict { PACKAGE_PIN C13 IOSTANDARD LVCMOS33 } [get_ports { sdram_cas_n }];
set_property -dict { PACKAGE_PIN B16 IOSTANDARD LVCMOS33 } [get_ports { sdram_ras_n }];
 
## 1.8" SPI TFT (ST7735S controller, 160x128), connector J10
set_property -dict { PACKAGE_PIN T13 IOSTANDARD LVCMOS33 } [get_ports { tft_sck }];   # J10 pin 7
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports { tft_sdi }];   # J10 pin 6, SDA
set_property -dict { PACKAGE_PIN R11 IOSTANDARD LVCMOS33 } [get_ports { tft_dc }];    # J10 pin 5, A0
set_property -dict { PACKAGE_PIN N9  IOSTANDARD LVCMOS33 } [get_ports { tft_reset }]; # J10 pin 4
set_property -dict { PACKAGE_PIN P9  IOSTANDARD LVCMOS33 } [get_ports { tft_cs }];    # J10 pin 3
 
## OV7670 CMOS camera on expansion connector J11 (camera pin 1 on J11 pin 3)
## PCLK (R15) is not a clock-capable pin. If it clocks logic directly, uncomment:
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets ov7670_pclk_IBUF];
set_property -dict { PACKAGE_PIN M16 IOSTANDARD LVCMOS33 } [get_ports { ov7670_sioc }];
set_property -dict { PACKAGE_PIN N16 IOSTANDARD LVCMOS33 } [get_ports { ov7670_siod }];
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports { ov7670_vsync }];
set_property -dict { PACKAGE_PIN P16 IOSTANDARD LVCMOS33 } [get_ports { ov7670_href }];
set_property -dict { PACKAGE_PIN R15 IOSTANDARD LVCMOS33 } [get_ports { ov7670_pclk }];
set_property -dict { PACKAGE_PIN R16 IOSTANDARD LVCMOS33 } [get_ports { ov7670_xclk }];
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 } [get_ports { ov7670_data[7] }];
set_property -dict { PACKAGE_PIN T15 IOSTANDARD LVCMOS33 } [get_ports { ov7670_data[6] }];
set_property -dict { PACKAGE_PIN N13 IOSTANDARD LVCMOS33 } [get_ports { ov7670_data[5] }];
set_property -dict { PACKAGE_PIN P13 IOSTANDARD LVCMOS33 } [get_ports { ov7670_data[4] }];
set_property -dict { PACKAGE_PIN N14 IOSTANDARD LVCMOS33 } [get_ports { ov7670_data[3] }];
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports { ov7670_data[2] }];
set_property -dict { PACKAGE_PIN P10 IOSTANDARD LVCMOS33 } [get_ports { ov7670_data[1] }];
set_property -dict { PACKAGE_PIN P11 IOSTANDARD LVCMOS33 } [get_ports { ov7670_data[0] }];
set_property -dict { PACKAGE_PIN R12 IOSTANDARD LVCMOS33 } [get_ports { ov7670_reset }];
set_property -dict { PACKAGE_PIN T12 IOSTANDARD LVCMOS33 } [get_ports { ov7670_pwdn }];
 
## 20-pin expansion connector J11 (same pins as the camera; use one block or the other)
## pin 1 = 5V, pin 2 = NC, pin 3 = 3V3, pin 4 = GND
#set_property -dict { PACKAGE_PIN M16 IOSTANDARD LVCMOS33 } [get_ports { pin5 }];
#set_property -dict { PACKAGE_PIN N16 IOSTANDARD LVCMOS33 } [get_ports { pin6 }];
#set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports { pin7 }];
#set_property -dict { PACKAGE_PIN P16 IOSTANDARD LVCMOS33 } [get_ports { pin8 }];
#set_property -dict { PACKAGE_PIN R15 IOSTANDARD LVCMOS33 } [get_ports { pin9 }];
#set_property -dict { PACKAGE_PIN R16 IOSTANDARD LVCMOS33 } [get_ports { pin10 }];
#set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 } [get_ports { pin11 }];
#set_property -dict { PACKAGE_PIN T15 IOSTANDARD LVCMOS33 } [get_ports { pin12 }];
#set_property -dict { PACKAGE_PIN N13 IOSTANDARD LVCMOS33 } [get_ports { pin13 }];
#set_property -dict { PACKAGE_PIN P13 IOSTANDARD LVCMOS33 } [get_ports { pin14 }];
#set_property -dict { PACKAGE_PIN N14 IOSTANDARD LVCMOS33 } [get_ports { pin15 }];
#set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports { pin16 }];
#set_property -dict { PACKAGE_PIN P10 IOSTANDARD LVCMOS33 } [get_ports { pin17 }];
#set_property -dict { PACKAGE_PIN P11 IOSTANDARD LVCMOS33 } [get_ports { pin18 }];
#set_property -dict { PACKAGE_PIN R12 IOSTANDARD LVCMOS33 } [get_ports { pin19 }];
#set_property -dict { PACKAGE_PIN T12 IOSTANDARD LVCMOS33 } [get_ports { pin20 }];
 
## 12-bit VGA (bit 3 = MSB, 510 ohm; bit 0 = LSB, 4 k)
set_property -dict { PACKAGE_PIN F14 IOSTANDARD LVCMOS33 } [get_ports { vga_hsync }];
set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 } [get_ports { vga_vsync }];
set_property -dict { PACKAGE_PIN D15 IOSTANDARD LVCMOS33 } [get_ports { vga_r[0] }];
set_property -dict { PACKAGE_PIN F12 IOSTANDARD LVCMOS33 } [get_ports { vga_r[1] }];
set_property -dict { PACKAGE_PIN F13 IOSTANDARD LVCMOS33 } [get_ports { vga_r[2] }];
set_property -dict { PACKAGE_PIN E16 IOSTANDARD LVCMOS33 } [get_ports { vga_r[3] }];
set_property -dict { PACKAGE_PIN D16 IOSTANDARD LVCMOS33 } [get_ports { vga_g[0] }];
set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS33 } [get_ports { vga_g[1] }];
set_property -dict { PACKAGE_PIN E15 IOSTANDARD LVCMOS33 } [get_ports { vga_g[2] }];
set_property -dict { PACKAGE_PIN H11 IOSTANDARD LVCMOS33 } [get_ports { vga_g[3] }];
set_property -dict { PACKAGE_PIN G12 IOSTANDARD LVCMOS33 } [get_ports { vga_b[0] }];
set_property -dict { PACKAGE_PIN H12 IOSTANDARD LVCMOS33 } [get_ports { vga_b[1] }];
set_property -dict { PACKAGE_PIN H13 IOSTANDARD LVCMOS33 } [get_ports { vga_b[2] }];
set_property -dict { PACKAGE_PIN G14 IOSTANDARD LVCMOS33 } [get_ports { vga_b[3] }];
 
## microSD slot U3 (the board has no pull-ups on CMD/DAT; the internal ones are enabled here)
set_property -dict { PACKAGE_PIN D6  IOSTANDARD LVCMOS33 } [get_ports { sd_cclk }];
set_property -dict { PACKAGE_PIN E6  IOSTANDARD LVCMOS33 PULLUP true } [get_ports { sd_cd }];
set_property -dict { PACKAGE_PIN D5  IOSTANDARD LVCMOS33 PULLUP true } [get_ports { sd_cmd }];
set_property -dict { PACKAGE_PIN B4  IOSTANDARD LVCMOS33 PULLUP true } [get_ports { sd_d[0] }];
set_property -dict { PACKAGE_PIN A3  IOSTANDARD LVCMOS33 PULLUP true } [get_ports { sd_d[1] }];
set_property -dict { PACKAGE_PIN C7  IOSTANDARD LVCMOS33 PULLUP true } [get_ports { sd_d[2] }];
set_property -dict { PACKAGE_PIN C6  IOSTANDARD LVCMOS33 PULLUP true } [get_ports { sd_d[3] }];
 
## XADC auxiliary inputs, 0-3.3 V on J13 (scaled to 0-1 V on the board)
## J13 pin 5 = VAUX6, pin 6 = VAUX14, pin 7 = VAUX7, pin 8 = VAUX15
## Temperature sensor: jumper J13 pins 7-9 (reads on VAUX7). LDR: jumper J13 pins 8-10 (reads on VAUX15).
set_property -dict { PACKAGE_PIN C3  IOSTANDARD LVCMOS33 } [get_ports { vauxp6 }];
set_property -dict { PACKAGE_PIN C2  IOSTANDARD LVCMOS33 } [get_ports { vauxn6 }];
set_property -dict { PACKAGE_PIN B2  IOSTANDARD LVCMOS33 } [get_ports { vauxp14 }];
set_property -dict { PACKAGE_PIN A2  IOSTANDARD LVCMOS33 } [get_ports { vauxn14 }];
set_property -dict { PACKAGE_PIN C1  IOSTANDARD LVCMOS33 } [get_ports { vauxp7 }];
set_property -dict { PACKAGE_PIN B1  IOSTANDARD LVCMOS33 } [get_ports { vauxn7 }];
set_property -dict { PACKAGE_PIN E2  IOSTANDARD LVCMOS33 } [get_ports { vauxp15 }];
set_property -dict { PACKAGE_PIN D1  IOSTANDARD LVCMOS33 } [get_ports { vauxn15 }];
 
## Stereo audio jack J1 (PWM / delta-sigma output through a 3.3 k / 4.7 nF low-pass filter)
set_property -dict { PACKAGE_PIN G11 IOSTANDARD LVCMOS33 } [get_ports { Audio_L }];
set_property -dict { PACKAGE_PIN G15 IOSTANDARD LVCMOS33 } [get_ports { Audio_R }];
 
## Version 1.0 boards only (512 KB SRAM, replaced by SDRAM from version 2.0)
#set_property -dict { PACKAGE_PIN D10 IOSTANDARD LVCMOS33 } [get_ports { sram_addr[0] }];
#set_property -dict { PACKAGE_PIN C8  IOSTANDARD LVCMOS33 } [get_ports { sram_addr[1] }];
#set_property -dict { PACKAGE_PIN C9  IOSTANDARD LVCMOS33 } [get_ports { sram_addr[2] }];
#set_property -dict { PACKAGE_PIN A8  IOSTANDARD LVCMOS33 } [get_ports { sram_addr[3] }];
#set_property -dict { PACKAGE_PIN A9  IOSTANDARD LVCMOS33 } [get_ports { sram_addr[4] }];
#set_property -dict { PACKAGE_PIN B9  IOSTANDARD LVCMOS33 } [get_ports { sram_addr[5] }];
#set_property -dict { PACKAGE_PIN A10 IOSTANDARD LVCMOS33 } [get_ports { sram_addr[6] }];
#set_property -dict { PACKAGE_PIN B10 IOSTANDARD LVCMOS33 } [get_ports { sram_addr[7] }];
#set_property -dict { PACKAGE_PIN B11 IOSTANDARD LVCMOS33 } [get_ports { sram_addr[8] }];
#set_property -dict { PACKAGE_PIN B12 IOSTANDARD LVCMOS33 } [get_ports { sram_addr[9] }];
#set_property -dict { PACKAGE_PIN A12 IOSTANDARD LVCMOS33 } [get_ports { sram_addr[10] }];
#set_property -dict { PACKAGE_PIN D8  IOSTANDARD LVCMOS33 } [get_ports { sram_addr[11] }];
#set_property -dict { PACKAGE_PIN D9  IOSTANDARD LVCMOS33 } [get_ports { sram_addr[12] }];
#set_property -dict { PACKAGE_PIN A13 IOSTANDARD LVCMOS33 } [get_ports { sram_addr[13] }];
#set_property -dict { PACKAGE_PIN A14 IOSTANDARD LVCMOS33 } [get_ports { sram_addr[14] }];
#set_property -dict { PACKAGE_PIN C14 IOSTANDARD LVCMOS33 } [get_ports { sram_addr[15] }];
#set_property -dict { PACKAGE_PIN B14 IOSTANDARD LVCMOS33 } [get_ports { sram_addr[16] }];
#set_property -dict { PACKAGE_PIN B15 IOSTANDARD LVCMOS33 } [get_ports { sram_addr[17] }];
#set_property -dict { PACKAGE_PIN A15 IOSTANDARD LVCMOS33 } [get_ports { sram_addr[18] }];
#set_property -dict { PACKAGE_PIN C16 IOSTANDARD LVCMOS33 } [get_ports { sram_data[0] }];
#set_property -dict { PACKAGE_PIN B16 IOSTANDARD LVCMOS33 } [get_ports { sram_data[1] }];
#set_property -dict { PACKAGE_PIN C11 IOSTANDARD LVCMOS33 } [get_ports { sram_data[2] }];
#set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS33 } [get_ports { sram_data[3] }];
#set_property -dict { PACKAGE_PIN D13 IOSTANDARD LVCMOS33 } [get_ports { sram_data[4] }];
#set_property -dict { PACKAGE_PIN C13 IOSTANDARD LVCMOS33 } [get_ports { sram_data[5] }];
#set_property -dict { PACKAGE_PIN E12 IOSTANDARD LVCMOS33 } [get_ports { sram_data[6] }];
#set_property -dict { PACKAGE_PIN E13 IOSTANDARD LVCMOS33 } [get_ports { sram_data[7] }];
#set_property -dict { PACKAGE_PIN D14 IOSTANDARD LVCMOS33 } [get_ports { sram_we_n }];
#set_property -dict { PACKAGE_PIN E11 IOSTANDARD LVCMOS33 } [get_ports { sram_oe_n }];
#set_property -dict { PACKAGE_PIN D11 IOSTANDARD LVCMOS33 } [get_ports { sram_ce_a_n }];
