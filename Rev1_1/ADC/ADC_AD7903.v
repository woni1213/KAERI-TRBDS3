`timescale 1ns / 1ps
/*
System Clock : 200 MHz, 5ns
Conversion Time은 최소 130 * 5ns = 650ns는 설정해야 됨
SPI 통신이 최소 500ns임
ADC Freq = Min 1.2us
*/

module ADC_AD7903 #
(
	parameter integer ADC_CONV_TIME = 130
)
(
	input i_rst,
	input i_clk,

	// ZYNQ Ports
	output o_adc_conv,							// AD7903 CNV Pin

	// SPI
	input [2:0] i_spi_state,					// SPI 상태 확인. SPI 전송 완료 신호로 사용
	output o_spi_start,							// SPI 전송 시작

	// ADC Setup
	input [9:0] i_adc_freq,						// ADC 측정 주기. 최소 240 이상. 240 이하면 동작하지 않음.
												// 240 (1.2us) ~ 1024 (5.12us). X 5ns

	output [2:0] o_state
);

	// state machine
	parameter IDLE 	= 0;
	parameter CONV	= 1;
	parameter ACQ 	= 2;
	parameter DONE 	= 3;

	reg [2:0] state;
	reg [2:0] n_state;

	//-- time counter --//
	reg [9:0] adc_freq_cnt;		// ADC 측정 주기 카운터

	//-- flag --//
	wire adc_conv_flag;			// ADC 시작용 내부 Flag

	// State Machine 상태
	always @(posedge i_clk or negedge i_rst) 
	begin
		if (~i_rst)
			state <= IDLE;

		else 
			state <= n_state;
	end

	// State Machine Control
	always @(*)
	begin
		case (state)
			IDLE 	: n_state = (adc_conv_flag) ? CONV : IDLE;
			CONV 	: n_state = (o_spi_start) ? ACQ : CONV;
			ACQ 	: n_state = (i_spi_state == 4) ? DONE : ACQ;
			DONE 	: n_state = IDLE;
			default : n_state <= IDLE;
		endcase
	end

	// adc 전체 동작 카운터
	always @(posedge i_clk or negedge i_rst) 
	begin
		if (~i_rst)
			adc_freq_cnt <= 0;

		else
			adc_freq_cnt <= (adc_freq_cnt == i_adc_freq) ? 0 : adc_freq_cnt + 1;
	end

	assign o_state = state;
	assign o_adc_conv = (adc_freq_cnt < ADC_CONV_TIME);								// ADC Conversion Hold Time 650ns (500 ~ 710ns).
	assign o_spi_start = (adc_freq_cnt == (ADC_CONV_TIME + 1));						// ADC Acquisition Start flag
	assign adc_conv_flag = ((adc_freq_cnt == 0) && (i_adc_freq >= 240)) ? 1 : 0;	// ADC Conversion Start flag

endmodule