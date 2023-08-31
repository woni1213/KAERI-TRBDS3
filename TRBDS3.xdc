set_property -dict { PACKAGE_PIN F20   IOSTANDARD LVCMOS33 } [get_ports { i_beam_trg_0 }];  #

set_property -dict { PACKAGE_PIN B20   IOSTANDARD LVCMOS33 } [get_ports { i_spi_adc_data_0 }];  # 
set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { i_spi_adc_data_1 }];  # 
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { i_spi_adc_data_2 }];  # 
set_property -dict { PACKAGE_PIN F17   IOSTANDARD LVCMOS33 } [get_ports { i_spi_adc_data_3 }];  # 

set_property -dict { PACKAGE_PIN D20   IOSTANDARD LVCMOS33 } [get_ports { o_spi_adc_clk_0 }];  # 
set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports { o_spi_adc_clk_1 }];  # 
set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports { o_spi_adc_clk_2 }];  # 
set_property -dict { PACKAGE_PIN G20   IOSTANDARD LVCMOS33 } [get_ports { o_spi_adc_clk_3 }];  # 

set_property -dict { PACKAGE_PIN A20   IOSTANDARD LVCMOS33 } [get_ports { o_adc_conv_0 }];  # 
set_property -dict { PACKAGE_PIN K19   IOSTANDARD LVCMOS33 } [get_ports { o_adc_conv_1 }];  #
set_property -dict { PACKAGE_PIN J20   IOSTANDARD LVCMOS33 } [get_ports { o_adc_conv_2 }];  #
set_property -dict { PACKAGE_PIN E17   IOSTANDARD LVCMOS33 } [get_ports { o_adc_conv_3 }];  #

set_property -dict { PACKAGE_PIN N20   IOSTANDARD LVCMOS33 } [get_ports { o_do_trg_0 }];  #

set_property -dict { PACKAGE_PIN P19   IOSTANDARD LVCMOS33 } [get_ports { o_do_ch1_0 }];  #
set_property -dict { PACKAGE_PIN Y17   IOSTANDARD LVCMOS33 } [get_ports { o_do_ch2_0 }];  #
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { o_do_ch3_0 }];  #
set_property -dict { PACKAGE_PIN Y14   IOSTANDARD LVCMOS33 } [get_ports { o_do_ch4_0 }];  #

set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports { o_do_interlock_0 }];  #


set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { o_led_0 }];  #