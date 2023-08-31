# TRBDS3
 양성자 ADC 장비 업그레이드 V3.

## 0. Address Map
ADC 1 :     0x4000_0000  
ADC 2 :     0x4000_1000  
ADC 3 :     0x4000_2000  
ADC 4 :     0x4000_3000  
DIO   :     0x4000_4000  

  
## 1. System
### a. 개요
- 4 Ch ADC, DO Ports
- Interlock, Trigger I/O Port
- System Clock 5ns (**FCLK_CLK0 : 200MHz**)


### b. 구성
- ADC_0
- ADC_1
- ADC_2
- ADC_3
- DIO_0

## 2. ADC
### a. 개요
- AD7903 (Differntial Endded ADC), +-10V
- 1개의 칩에 Isolation이 되어있는 2개의 ADC로 구성
- 각 채널 별 SPI 통신
- 최대 1.2us Sampling
- 16 Bit
- RAM Size 최대 10000 (수정 가능)

### b. 구성
- Top_ADC.v
  - adc_AD7903.v (AD7903 Control)
  - adc_s00_AXI.v (AXI)
  - adc_spi.v (SPI)
  - DPBRAM.v (DPRAM)

### c. 동작
- 전원이 켜지는 순간 설정된 Samping 시간으로 ADC 동작. ADC Off 시 Sampling Time을 240 미만으로 설정.
- Sampling Time 240 이상 설정해야함. 0일 경우 동작 안함.
- Conversion Time : 650ns 고정 (Busy 신호가 없음)
- SPI 20MHz, CPOL : 0, CPHA : 0

### d. AXI
- **[READ Only]**
  - slv_reg 0 [15:0]    : 현재 ADC 값
  - slv_reg 1 [2:0]  +4 : SPI Status (Used Debug)
  - slv_reg 2 [15:0] +8 : RAM Data


- **[Write]**
  - slv_reg 3 [9:0]  +C     : ADC Sampling Time (240 이상) 최소 sampling 시간. * 5ns
  - slv_reg 4 [13:0] +10    : RAM Save Size : (Capture time = Size * Sampling Time)
  - slv_reg 5 [15:0] +14    : RAM Address

### e. 변환식
- 0V : ADC Data = 32768
- &#43; Voltage : (ADC Data * Gain) - Offset
- &#45; Voltage : ((65536 - ADC Data) * Gain) + Offset
- Channel : Gain / Offset
- 1 Ch : 0.000384 / 0.004332
- 2 Ch : 0.000385 / 0.005559
- 3 Ch : 0.000384 / 0.003755
- 4 Ch : 0.000386 / 0.004544

### f. 주의 사항
- Sampling Time 240 이상


## 3. DO
### a. 개요
- Digital Output
- 4 Ch DO
- 1 Ch Interrupt Output
- 1 Ch Trigger I/O
- Interrupt : 5V
- etc : 3.3V

### b. 구성
- Top_DIO.v
  - dio_s00_AXI.v (AXI)

### c. 동작
- 0 : High
- 1 : Low
- 모두 PS와 1:1 연결. 모든 핀 제어는 PS에서 해야함.

### d. AXI
- **[Write - reg 0]**
  - slv_reg 0 [0]    : Trigger Out
  - slv_reg 0 [1]    : Interrupt Out
- **[Write - reg 1]**
  - slv_reg 1 [0]  +4 : Ch 1 DO
  - slv_reg 1 [1]  +4 : Ch 2 DO
  - slv_reg 1 [2]  +4 : Ch 3 DO
  - slv_reg 1 [3]  +4 : Ch 4 DO


### e-mail : <woni1213@e-hmt.kr>