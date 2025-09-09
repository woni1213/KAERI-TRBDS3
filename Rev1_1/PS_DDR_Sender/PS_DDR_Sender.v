`timescale 1ns / 1ps

module PS_DDR_Sender
(
	input i_clk,
	input i_rst,

	input i_start,
	output o_done,

	input [31:0] i_ddr_addr,
	input [31:0] i_ddr_data, // 32비트 데이터 버스

	output [2:0] o_state,

	// AXI 쓰기 주소 채널
	output [5:0]	M_AXI_AWID,
	output [31:0]	M_AXI_AWADDR,
	output [3:0]	M_AXI_AWLEN,
	output [2:0]	M_AXI_AWSIZE,
	output [1:0]	M_AXI_AWBURST,
	output			M_AXI_AWLOCK,
	output [3:0]	M_AXI_AWCACHE,
	output [2:0]	M_AXI_AWPROT,
	output [3:0]	M_AXI_AWQOS,
	output [3:0]	M_AXI_AWREGION,
	output [7:0]	M_AXI_AWUSER,
	output			M_AXI_AWVALID,
	input			M_AXI_AWREADY,

	// AXI 쓰기 데이터 채널
	output [31:0]	M_AXI_WDATA,
	output [3:0]	M_AXI_WSTRB,
	output			M_AXI_WLAST,
	output [7:0]	M_AXI_WUSER,
	output			M_AXI_WVALID,
	input			M_AXI_WREADY,

	// AXI 쓰기 응답 채널
	input [5:0]		M_AXI_BID,
	input [1:0]		M_AXI_BRESP,
	input [7:0]		M_AXI_BUSER,
	input			M_AXI_BVALID,
	output			M_AXI_BREADY,

	// AXI 읽기 주소 채널
	output [5:0]	M_AXI_ARID,
	output [31:0]	M_AXI_ARADDR,
	output [3:0]	M_AXI_ARLEN,
	output [2:0]	M_AXI_ARSIZE,
	output [1:0]	M_AXI_ARBURST,
	output			M_AXI_ARLOCK,
	output [3:0]	M_AXI_ARCACHE,
	output [2:0]	M_AXI_ARPROT,
	output [3:0]	M_AXI_ARQOS,
	output [3:0]	M_AXI_ARREGION,
	output [7:0]	M_AXI_ARUSER,
	output			M_AXI_ARVALID,
	input			M_AXI_ARREADY,

	// AXI 읽기 데이터 채널
	input [5:0]		M_AXI_RID,
	input [31:0]	M_AXI_RDATA,
	input [1:0]		M_AXI_RRESP,
	input			M_AXI_RLAST,
	input [7:0]		M_AXI_RUSER,
	input			M_AXI_RVALID,
	output			M_AXI_RREADY
);

	localparam IDLE = 0;
	localparam ADDR_WRITE = 1;
	localparam DATA_WRITE = 2;
	localparam RESP_WAIT = 3;
	localparam DONE = 4;

	reg [2:0] state;

	reg awvalid_reg;
	reg wvalid_reg;
	reg bready_reg;

	always @(posedge i_clk or negedge i_rst)
	begin
		if (~i_rst) 
		begin
			state <= IDLE;
			awvalid_reg <= 0;
			wvalid_reg  <= 0;
			bready_reg  <= 0;
		end 
		
		else 
		begin
			awvalid_reg <= awvalid_reg;
			wvalid_reg  <= wvalid_reg;
			bready_reg  <= bready_reg;

			case (state)
				IDLE : begin
					if (i_start) 
					begin
						state <= ADDR_WRITE;
						awvalid_reg <= 1;
					end
				end
				ADDR_WRITE : begin
					if (M_AXI_AWREADY) 
					begin
						state <= DATA_WRITE;
						awvalid_reg <= 0;
						wvalid_reg <= 1;
					end
				end
				DATA_WRITE : begin
					if (M_AXI_WREADY) 
					begin
						state <= RESP_WAIT;
						wvalid_reg <= 0;
						bready_reg <= 1;
					end
				end
				RESP_WAIT : begin
					if (M_AXI_BVALID) 
					begin
						state <= DONE;
						bready_reg <= 0;
					end
				end
				DONE : begin
					state <= IDLE;
				end
				default: begin
					state <= IDLE;
				end
            endcase
        end
    end

    // AXI 신호 할당
    assign M_AXI_AWVALID = awvalid_reg;
    assign M_AXI_WVALID  = wvalid_reg;
    assign M_AXI_BREADY  = bready_reg;

    assign o_state = state;
    assign o_done = (state == DONE);

    // AXI 쓰기 주소 채널 신호
    assign M_AXI_AWID		= 0;
    assign M_AXI_AWADDR		= i_ddr_addr;
    assign M_AXI_AWLEN		= 0;		// 단일 전송 (1비트)
    assign M_AXI_AWSIZE		= 3'b010;	// 4바이트 (32비트 데이터)
    assign M_AXI_AWBURST	= 2'b01;	// INCR (증가) 버스트 타입
    assign M_AXI_AWLOCK		= 1'b0;		// 일반 접근
    assign M_AXI_AWCACHE	= 4'b0011;	// 일반 캐시 불가능 버퍼 가능
    assign M_AXI_AWPROT		= 3'b000;	// 비특권, 보안, 데이터 접근
    assign M_AXI_AWQOS		= 4'h0;
    assign M_AXI_AWREGION	= 4'h0;
    assign M_AXI_AWUSER		= 8'b0;

    // AXI 쓰기 데이터 채널 신호
    assign M_AXI_WDATA		= i_ddr_data;
    assign M_AXI_WSTRB		= 4'hF;		// 32비트 전송을 위한 모든 4바이트 스트로브 활성화
    assign M_AXI_WLAST		= (state == DATA_WRITE); 	// 단일 전송이므로 데이터 전송 상태일 때 LAST 활성화
    assign M_AXI_WUSER		= 8'b0;

    // AXI 읽기 채널 (사용되지 않음)
    assign M_AXI_ARID		= 4'h0;
    assign M_AXI_ARADDR		= 32'd0;
    assign M_AXI_ARLEN		= 4'd0;
    assign M_AXI_ARSIZE		= 3'b010;
    assign M_AXI_ARBURST	= 2'b01;
    assign M_AXI_ARLOCK		= 1'b0;
    assign M_AXI_ARCACHE	= 4'b0011;
    assign M_AXI_ARPROT		= 3'b000;
    assign M_AXI_ARQOS		= 4'h0;
    assign M_AXI_ARREGION	= 4'h0;
    assign M_AXI_ARUSER		= 8'b0;
    assign M_AXI_ARVALID	= 1'b0; // 항상 비활성화
    assign M_AXI_RREADY		= 1'b0; // 항상 비활성화

endmodule