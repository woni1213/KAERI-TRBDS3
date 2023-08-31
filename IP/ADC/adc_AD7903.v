`timescale 1ns / 1ps
/*
System Clock : 200 MHz, 5ns
Conversion Time은 최소 130 * 5ns = 650ns는 설정해야 됨
SPI 통신이 최소 500ns임
ADC Freq = Min 1.2us
*/

module ADC_AD7903 #
(
    parameter integer DATA_WIDTH = 16,              // SPI Data 크기

    parameter integer AWIDTH = 16,
    parameter integer MEM_SIZE = 10000,

    parameter integer ADC_CONV_TIME = 130
)
(
    input i_fRST,
    input i_clk,

    // ZYNQ Ports
    input i_beam_trg,                                   // Beam Trigger 입력. RAM에 ADC Data 저장 시작
    output o_adc_conv,                                  // AD7903 CNV Pin
    output o_adc_data_save_flag,                        // PS Interlock. Ram 저장 완료

    // SPI
    input [2:0] i_spi_state,                            // SPI 상태 확인. SPI 전송 완료 신호로 사용
    output o_spi_start,                                 // SPI 전송 시작
    output [DATA_WIDTH - 1 : 0] o_spi_data,             // MOSI Data는 사용하지 않음. 0으로 설정

    // ADC Setup
    input [9:0] i_adc_freq,                             // ADC 측정 주기. 최소 240 이상. 240 이하면 동작하지 않음.
                                                        // 240 (1.2us) ~ 1024 (5.12us). X 5ns
    input [$clog2(MEM_SIZE) : 0] i_adc_data_ram_size,   // ADC Data RAM 크기. MEM_SIZE 상수에 의해서 10000 이하 설정.

    // RAM
    output reg [AWIDTH - 1 : 0] o_ram_addr,             // RAM Memory Addr.
    output o_ram_ce,                                    // RAM CE. 1로 고정                    
    output o_ram_we                                     // RAM WE. 1로 고정
);

    // state machine
    parameter idle = 0;
    parameter adc_conv = 1;
    parameter adc_acq = 2;
    parameter save = 3;

    reg [2:0] state;
    reg [2:0] n_state;

    //-- time counter --//
    reg [9:0] adc_freq_cnt;                             // ADC 측정 주기 카운터

    //-- flag --//
    wire adc_conv_flag;                                 // ADC 시작용 내부 Flag
    reg adc_done_flag;                                  // ADC Save 후 idle로 가기 위한 신호. 1 Clock 동작함
    reg adc_trg_flag;                                   // Beam Trigger 구분 Flag. 1이면 State가 save로 0이면 idle로 감
    reg adc_trg_np_flag;                                // ADC Trigger Neg, Pos Flag
                                                        // Trigger Level이 변화하기 전에 데이터 저장이 끝나서 다시 데이터를 덮어 쓰는것을 방지

    // State Machine 상태
    always @(posedge i_clk or negedge i_fRST) 
    begin
        if (~i_fRST)
            state <= idle;

        else 
            state <= n_state;
    end

    // State Machine Control
    always @(*)
    begin
        case (state)
            idle :
            begin
                if (adc_conv_flag)
                    n_state <= adc_conv;

                else
                    n_state <= idle;
            end

            adc_conv :
            begin
                if (o_spi_start)
                    n_state <= adc_acq;

                else
                    n_state <= adc_conv;
            end

            adc_acq :
            begin
                if (i_spi_state == 4)                   // spi 전송 완료
                begin
                    if (adc_trg_flag)
                        n_state <= save;

                    else
                        n_state <= idle;
                end

                else
                    n_state <= adc_acq;
            end

            save :
            begin
                if (adc_done_flag)
                    n_state <= idle;

                else
                    n_state <= save;
            end

            default :
                    n_state <= idle;
        endcase
    end

    // adc 전체 동작 카운터
    always @(posedge i_clk or negedge i_fRST) 
    begin
        if (~i_fRST)
            adc_freq_cnt <= 0;

        else if (adc_freq_cnt == i_adc_freq)
            adc_freq_cnt <= 0;

        else
            adc_freq_cnt <= adc_freq_cnt + 1;
    end


    always @(posedge i_clk or negedge i_fRST) 
    begin
        if (~i_fRST)
            adc_done_flag <= 0;

        else if (state == save)                         // State가 save로 진입 시 1 Clock만 유지
            adc_done_flag <= 1;

        else
            adc_done_flag <= 0;
    end


    always @(posedge i_clk or negedge i_fRST) 
    begin
        if (~i_fRST)
            adc_trg_flag <= 0;

        else if (~i_beam_trg && adc_trg_np_flag)        
            adc_trg_flag <= 1;

        else if (o_ram_addr == i_adc_data_ram_size)
            adc_trg_flag <= 0;

        else
            adc_trg_flag <= adc_trg_flag;
    end


    always @(posedge i_clk or negedge i_fRST) 
    begin
        if (~i_fRST)
            adc_trg_np_flag <= 1;

        else if (~i_beam_trg && adc_trg_np_flag)
            adc_trg_np_flag <= 0;

        else if (i_beam_trg)                            // Beam Trigger가 H가 되어야 해당 변수 초기화 됨
            adc_trg_np_flag <= 1;

        else
            adc_trg_np_flag <= adc_trg_np_flag;
    end


    always @(posedge i_clk or negedge i_fRST) 
    begin
        if (~i_fRST)
            o_ram_addr <= 0;

        else if (state == save)
            o_ram_addr <= o_ram_addr + 1;

        else if (!adc_trg_flag)
            o_ram_addr <= 0;

        else
            o_ram_addr <= o_ram_addr;
    end

    
    assign o_adc_conv = (adc_freq_cnt < ADC_CONV_TIME) ? 1 : 0;                         // ADC Conversion Hold Time 650ns (500 ~ 710ns).
    assign o_spi_start = (adc_freq_cnt == (ADC_CONV_TIME + 1)) ? 1 : 0;                 // ADC Acquisition Start flag
    assign o_ram_we = 1;                                            
    assign o_ram_ce = 1;       
    assign o_spi_data = 0;                                      
    assign o_adc_data_save_flag = ~adc_trg_flag;                                        // RAM 저장 완료 신호. PS 인터럽트
    assign adc_conv_flag = ((adc_freq_cnt == 0) && (i_adc_freq >= 240)) ? 1 : 0;        // ADC Conversion Start flag
    
endmodule