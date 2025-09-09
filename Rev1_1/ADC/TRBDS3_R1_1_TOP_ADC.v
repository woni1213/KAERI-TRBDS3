`timescale 1 ns / 1 ps
/*
System Clock : 200 MHz, 5ns
*/

	module TRBDS3_R1_1_TOP_ADC #
	(
		// TOP의 Parameter가 최우선임
		parameter integer DATA_WIDTH = 16,
		parameter integer DELAY = 2,
		parameter integer T_CYCLE = 2,					// 반주기 = 10ns * T_CYCLE (50이면 1MHz (10ns * 50 * 2 = 1us))               

		parameter integer MEM_SIZE = 10000,				// DPRAM Memory Depth

		parameter integer C_S_AXI_DATA_WIDTH = 32,								// AXI4-Lite Data Width
		parameter integer C_S_AXI_ADDR_NUM = 5,									// AXI4-Lite Slave Reg Number
		parameter integer C_S_AXI_ADDR_WIDTH = $clog2(C_S_AXI_ADDR_NUM) + 2,	// AXI4-Lite Address

		parameter integer ADC_CONV_TIME = 130,

		parameter integer DDR_OFFSET = 0,
		parameter integer DDR_CH_OFFSET = 32'h1000_0000
	)
	(
		input i_clk,
		input i_rst,

		input i_adc_spi_data,		// MISO
		input i_beam_trg,			// Trigger

		output o_spi_adc_clk,		// SPI Clock.
		output o_adc_conv,			// ADC Conversion Pin
		output o_adc_trg_irq,		// ADC Complete Flag. PS Interrupt

		output [2:0] o_adc_state,

		(* X_INTERFACE_PARAMETER = "FREQ_HZ 200000000" *)
		output [31:0] m_axis_raw_adc_tdata,
		input m_axis_raw_adc_tready,
		output m_axis_raw_adc_tvalid,

		(* X_INTERFACE_PARAMETER = "FREQ_HZ 200000000" *)
		input [31:0] s_axis_float_adc_tdata,
		output s_axis_float_adc_tready,
		input s_axis_float_adc_tvalid,

		(* X_INTERFACE_PARAMETER = "FREQ_HZ 200000000" *)
		output [31:0] m_axis_adc_gain_tdata,
		input m_axis_adc_gain_tready,
		output m_axis_adc_gain_tvalid,

		(* X_INTERFACE_PARAMETER = "FREQ_HZ 200000000" *)
		output [31:0] m_axis_adc_offset_tdata,
		input m_axis_adc_offset_tready,
		output m_axis_adc_offset_tvalid,

		(* X_INTERFACE_PARAMETER = "FREQ_HZ 200000000" *)
		output [31:0] m_axis_user_gain_tdata,
		input m_axis_user_gain_tready,
		output m_axis_user_gain_tvalid,

		(* X_INTERFACE_PARAMETER = "FREQ_HZ 200000000" *)
		output [31:0] m_axis_user_offset_tdata,
		input m_axis_user_offset_tready,
		output m_axis_user_offset_tvalid,

		(* X_INTERFACE_PARAMETER = "FREQ_HZ 200000000" *)
		input [C_S_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input [2 : 0] s00_axi_awprot,
		input s00_axi_awvalid,
		output s00_axi_awready,
		input [C_S_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input s00_axi_wvalid,
		output s00_axi_wready,
		output [1 : 0] s00_axi_bresp,
		output s00_axi_bvalid,
		input s00_axi_bready,
		input [C_S_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input [2 : 0] s00_axi_arprot,
		input s00_axi_arvalid,
		output s00_axi_arready,
		output [C_S_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output [1 : 0] s00_axi_rresp,
		output s00_axi_rvalid,
		input s00_axi_rready,

		(* X_INTERFACE_PARAMETER = "FREQ_HZ 200000000" *)
		// Write Address Channel
		output [5:0]	M_AXI_AWID,
		output [31:0] 	M_AXI_AWADDR,
		output [3:0] 	M_AXI_AWLEN,
		output [2:0] 	M_AXI_AWSIZE,
		output [1:0] 	M_AXI_AWBURST,
		output 			M_AXI_AWLOCK,
		output [3:0] 	M_AXI_AWCACHE,
		output [2:0] 	M_AXI_AWPROT,
		output [3:0] 	M_AXI_AWQOS,
		output [3:0] 	M_AXI_AWREGION,
		output [7:0]	M_AXI_AWUSER,
		output 			M_AXI_AWVALID,
		input 			M_AXI_AWREADY,

		// Write Data Channel
		output [31:0] 	M_AXI_WDATA,
		output [3:0] 	M_AXI_WSTRB,
		output 			M_AXI_WLAST,
		output [7:0]	M_AXI_WUSER,
		output 			M_AXI_WVALID,
		input 			M_AXI_WREADY,

		// Write Response Channel
		input [5:0]		M_AXI_BID,
		input [1:0] 	M_AXI_BRESP,
		input [7:0]		M_AXI_BUSER,
		input 			M_AXI_BVALID,
		output 			M_AXI_BREADY,

		// Read Address Channel
		output [5:0]	M_AXI_ARID,
		output [31:0] 	M_AXI_ARADDR,
		output [3:0] 	M_AXI_ARLEN,
		output [2:0] 	M_AXI_ARSIZE,
		output [1:0] 	M_AXI_ARBURST,
		output 			M_AXI_ARLOCK,
		output [3:0] 	M_AXI_ARCACHE,
		output [2:0] 	M_AXI_ARPROT,
		output [3:0] 	M_AXI_ARQOS,
		output [3:0] 	M_AXI_ARREGION,
		output [7:0]	M_AXI_ARUSER,
		output 			M_AXI_ARVALID,
		input 			M_AXI_ARREADY,

		// Read Data Channel
		input [5:0]		M_AXI_RID,
		input [31:0] 	M_AXI_RDATA,
		input [1:0] 	M_AXI_RRESP,
		input 			M_AXI_RLAST,
		input [7:0]		M_AXI_RUSER,
		input 			M_AXI_RVALID,
		output 			M_AXI_RREADY
	);

	reg adc_trg_flag;
	reg [15:0] ddr_addr;
	wire [31:0] raw_adc_data_buf;
	wire adc_done_flag;
	wire ddr_done_flag;

	// SPI
	wire [2:0] adc_spi_state;
	wire adc_spi_start;

	// ADC Setup
	wire [9:0] adc_freq;
	wire [$clog2(MEM_SIZE) : 0] ddr_size;

	always @(posedge i_clk or negedge i_rst) 
	begin
		if (~i_rst)
			adc_trg_flag <= 0;

		else if (~i_beam_trg)
			adc_trg_flag <= 1;

		else if (ddr_addr == ddr_size)
			adc_trg_flag <= 0;

		else
			adc_trg_flag <= adc_trg_flag;
	end


	always @(posedge i_clk or negedge i_rst) 
	begin
		if (~i_rst)
			ddr_addr <= 0;

		else if (ddr_done_flag)
			ddr_addr <= ddr_addr + 1;

		else if (!adc_trg_flag)
			ddr_addr <= 0;

		else
			ddr_addr <= ddr_addr;
	end

	ARRAY_S00_AXI #
	(
		.MEM_SIZE(MEM_SIZE),

		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_NUM(C_S_AXI_ADDR_NUM),
		.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
	) 
	u_ARRAY_S00_AXI 
	(
		.i_adc_data(s_axis_float_adc_tdata),

		.o_user_gain(m_axis_user_gain_tdata),
		.o_user_offset(m_axis_user_offset_tdata),

		.o_adc_freq(adc_freq),
		.o_ddr_size(ddr_size),

		.S_AXI_ACLK(i_clk),
		.S_AXI_ARESETN(i_rst),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);

	ADC_AD7903 #
	(
		.ADC_CONV_TIME(ADC_CONV_TIME)
	)
	u_ADC_AD7903
	(
		.i_rst(i_rst),
		.i_clk(i_clk),

		// ZYNQ Ports
		.o_adc_conv(o_adc_conv),

		// SPI
		.i_spi_state(adc_spi_state),
		.o_spi_start(adc_spi_start),

		// ADC Setup
		.i_adc_freq(adc_freq),						// 240 (1.2us) ~ 1024 (5.12us)
		.o_state(o_adc_state)
	);

	SPI_AD7903 #
	(
		.DATA_WIDTH(DATA_WIDTH),
		.T_CYCLE(T_CYCLE),
		.DELAY(DELAY)
	)
	u_SPI_AD7903
	(
		.i_rst(i_rst),
		.i_clk(i_clk),
		.i_spi_start(adc_spi_start),
		.i_mosi_data(),
		.miso(i_adc_spi_data),

		.o_miso_data(raw_adc_data_buf),
		.spi_clk(o_spi_adc_clk),

		.o_spi_state(adc_spi_state)
	);

	PS_DDR_Sender u_PS_DDR_Sender
	(
		.i_clk(i_clk),
		.i_rst(i_rst),

		.i_start(s_axis_float_adc_tvalid && adc_trg_flag),
		.o_done(ddr_done_flag),

		.i_ddr_addr((ddr_addr * 4) + DDR_OFFSET + DDR_CH_OFFSET),
		.i_ddr_data(s_axis_float_adc_tdata),

		.o_state(),

		.M_AXI_AWID(M_AXI_AWID),
		.M_AXI_AWADDR(M_AXI_AWADDR),
		.M_AXI_AWLEN(M_AXI_AWLEN),
		.M_AXI_AWSIZE(M_AXI_AWSIZE),
		.M_AXI_AWBURST(M_AXI_AWBURST),
		.M_AXI_AWLOCK(M_AXI_AWLOCK),
		.M_AXI_AWCACHE(M_AXI_AWCACHE),
		.M_AXI_AWPROT(M_AXI_AWPROT),
		.M_AXI_AWQOS(M_AXI_AWQOS),
		.M_AXI_AWREGION(M_AXI_AWREGION),
		.M_AXI_AWUSER(M_AXI_AWUSER),
		.M_AXI_AWVALID(M_AXI_AWVALID),
		.M_AXI_AWREADY(M_AXI_AWREADY),
		.M_AXI_WDATA(M_AXI_WDATA),
		.M_AXI_WSTRB(M_AXI_WSTRB),
		.M_AXI_WLAST(M_AXI_WLAST),
		.M_AXI_WUSER(M_AXI_WUSER),
		.M_AXI_WVALID(M_AXI_WVALID),
		.M_AXI_WREADY(M_AXI_WREADY),
		.M_AXI_BID(M_AXI_BID),
		.M_AXI_BRESP(M_AXI_BRESP),
		.M_AXI_BUSER(M_AXI_BUSER),
		.M_AXI_BVALID(M_AXI_BVALID),
		.M_AXI_BREADY(M_AXI_BREADY),
		.M_AXI_ARID(M_AXI_ARID),
		.M_AXI_ARADDR(M_AXI_ARADDR),
		.M_AXI_ARLEN(M_AXI_ARLEN),
		.M_AXI_ARSIZE(M_AXI_ARSIZE),
		.M_AXI_ARBURST(M_AXI_ARBURST),
		.M_AXI_ARLOCK(M_AXI_ARLOCK),
		.M_AXI_ARCACHE(M_AXI_ARCACHE),
		.M_AXI_ARPROT(M_AXI_ARPROT),
		.M_AXI_ARQOS(M_AXI_ARQOS),
		.M_AXI_ARREGION(M_AXI_ARREGION),
		.M_AXI_ARUSER(M_AXI_ARUSER),
		.M_AXI_ARVALID(M_AXI_ARVALID),
		.M_AXI_ARREADY(M_AXI_ARREADY),
		.M_AXI_RID(M_AXI_RID),
		.M_AXI_RDATA(M_AXI_RDATA),
		.M_AXI_RRESP(M_AXI_RRESP),
		.M_AXI_RLAST(M_AXI_RLAST),
		.M_AXI_RUSER(M_AXI_RUSER),
		.M_AXI_RVALID(M_AXI_RVALID),
		.M_AXI_RREADY(M_AXI_RREADY)
	);

	assign m_axis_raw_adc_tdata = (raw_adc_data_buf[15] == 0) ? raw_adc_data_buf : 0;
	assign m_axis_raw_adc_tvalid = (adc_spi_state == 4);
	assign o_adc_trg_irq = ~adc_trg_flag;

	assign m_axis_adc_gain_tdata = 32'h39c80009;		// 0.00038147
	assign m_axis_adc_offset_tdata = 32'h00000000;

	assign m_axis_adc_gain_tvalid = 1;
	assign m_axis_adc_offset_tvalid = 1;
	assign m_axis_user_gain_tvalid = 1;
	assign m_axis_user_offset_tvalid = 1;

endmodule
