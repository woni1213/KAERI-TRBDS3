#include <stdio.h>
#include "xparameters.h"
#include "xil_io.h"
#include "sleep.h"

int main()
{
	int i;
	int a, b;
	int reg;

	int spi_state_0;
	int spi_state_1;
	int spi_state_2;
	int spi_state_3;

	int spi_delay_test_0;
	int spi_delay_test_1;
	int spi_delay_test_2;
	int spi_delay_test_3;

	float adc_conv_data_0;
	float adc_conv_data_1;
	float adc_conv_data_2;
	float adc_conv_data_3;

	int adc_data_0;
	int adc_data_1;
	int adc_data_2;
	int adc_data_3;

	float adc_gain_0 = 0.000384;
	float adc_gain_1 = 0.000385;
	float adc_gain_2 = 0.000384;
	float adc_gain_3 = 0.000386;

	float adc_offset_0 = 0.004332;
	float adc_offset_1 = 0.005559;
	float adc_offset_2 = 0.003755;
	float adc_offset_3 = 0.004544;


	Xil_Out32((XPAR_TRBDS3_TOP_ADC_0_BASEADDR + 12), 240);
	Xil_Out32((XPAR_TRBDS3_TOP_ADC_0_BASEADDR + 16), 1000);
	Xil_Out32((XPAR_TRBDS3_TOP_ADC_1_BASEADDR + 12), 240);
	Xil_Out32((XPAR_TRBDS3_TOP_ADC_1_BASEADDR + 16), 1000);
	Xil_Out32((XPAR_TRBDS3_TOP_ADC_2_BASEADDR + 12), 240);
	Xil_Out32((XPAR_TRBDS3_TOP_ADC_2_BASEADDR + 16), 1000);
	Xil_Out32((XPAR_TRBDS3_TOP_ADC_3_BASEADDR + 12), 240);
	Xil_Out32((XPAR_TRBDS3_TOP_ADC_3_BASEADDR + 16), 1000);


	// SPI State Check
/*
	while(1)
	{
		spi_state_0 = Xil_In32((XPAR_TRBDS3_TOP_ADC_0_BASEADDR + 4));
		spi_state_1 = Xil_In32((XPAR_TRBDS3_TOP_ADC_1_BASEADDR + 4));
		spi_state_2 = Xil_In32((XPAR_TRBDS3_TOP_ADC_2_BASEADDR + 4));
		spi_state_3 = Xil_In32((XPAR_TRBDS3_TOP_ADC_3_BASEADDR + 4));

		spi_delay_test_0 = Xil_In32((XPAR_TRBDS3_TOP_ADC_0_BASEADDR + 8));
		spi_delay_test_1 = Xil_In32((XPAR_TRBDS3_TOP_ADC_1_BASEADDR + 8));
		spi_delay_test_2 = Xil_In32((XPAR_TRBDS3_TOP_ADC_2_BASEADDR + 8));
		spi_delay_test_3 = Xil_In32((XPAR_TRBDS3_TOP_ADC_3_BASEADDR + 8));

		printf("%d  ", spi_delay_test_0);
		printf("%d  ", spi_delay_test_1);
		printf("%d  ", spi_delay_test_2);
		printf("%d  ", spi_delay_test_3);

		printf("\n");

		usleep(1000);
	}

*/
/*
	// 실시간 측정
	while(1)
	{
		adc_data_0 = Xil_In32((XPAR_TRBDS3_TOP_ADC_0_BASEADDR));
		adc_data_1 = Xil_In32((XPAR_TRBDS3_TOP_ADC_1_BASEADDR));
		adc_data_2 = Xil_In32((XPAR_TRBDS3_TOP_ADC_2_BASEADDR));
		adc_data_3 = Xil_In32((XPAR_TRBDS3_TOP_ADC_3_BASEADDR));

		// 1 Ch
		if (adc_data_0 > 32768)
			adc_conv_data_0 = ((65535 - adc_data_0 + 1) * adc_gain_0) + adc_offset_0;

		else if (adc_data_0 < 32768)
			adc_conv_data_0 = (adc_data_0 * adc_gain_0) + adc_offset_0;

		else
			adc_conv_data_0 = 0;


		// 2 Ch
		if (adc_data_1 > 32768)
			adc_conv_data_1 = ((65535 - adc_data_1 + 1) * adc_gain_1) + adc_offset_1;

		else if (adc_data_1 < 32768)
			adc_conv_data_1 = (adc_data_1 * adc_gain_1) + adc_offset_1;

		else
			adc_conv_data_1 = 0;


		// 3 Ch
		if (adc_data_2 > 32768)
			adc_conv_data_2 = ((65535 - adc_data_2 + 1) * adc_gain_2) + adc_offset_2;

		else if (adc_data_2 < 32768)
			adc_conv_data_2 = (adc_data_2 * adc_gain_2) + adc_offset_2;

		else
			adc_conv_data_2 = 0;


		// 1 Ch
		if (adc_data_3 > 32768)
			adc_conv_data_3 = ((65535 - adc_data_3 + 1) * adc_gain_3) + adc_offset_3;

		else if (adc_data_3 < 32768)
			adc_conv_data_3 = (adc_data_3 * adc_gain_3) + adc_offset_3;

		else
			adc_conv_data_3 = 0;

		//printf("%d", adc_data_3);
		printf("%f", adc_conv_data_3);
		//printf("%f    ", adc_conv_data_0);
		//printf("%f    ", adc_conv_data_1);
		//printf("%f    ", adc_conv_data_2);
		//printf("%f", adc_conv_data_3);

		printf("\n");

		usleep(100000);
	}
*/
/*
	// Trigger 측정 1 Ch
	while(1)
	{
		scanf("%d\n", &b);
//		printf("%d\n", b);

		for (i = 0; i < 1000; i++)
		{
			Xil_Out32((XPAR_TRBDS3_TOP_ADC_3_BASEADDR + 20), (u32)i);

			usleep(100);

			adc_data_0 = Xil_In32((XPAR_TRBDS3_TOP_ADC_3_BASEADDR + 8));

			if (adc_data_0 > 32768)
			{
				adc_conv_data_0 = ((65535 - adc_data_0 + 1) * adc_gain_3) + adc_offset_3;
				printf("-%f\n", adc_conv_data_0);
			}

			else if (adc_data_0 < 32768)
			{
				adc_conv_data_0 = (adc_data_0 * adc_gain_3) + adc_offset_3;
				printf("%f\n", adc_conv_data_0);
			}

			else
				printf("0/n");


			usleep(100);

		}
		printf("///////////////////////\n");
	}
*/

	// DIO Test
	while(1)
	{
		printf("SLV_REG?\n");
		scanf("%d", &a);

		if (a == 0)
		{
			printf("?\n");
			scanf("%d", &b);

			Xil_Out32((XPAR_TRBDS3_TOP_DIO_0_BASEADDR), (u32)b);
			usleep(100);
			reg = Xil_In32((XPAR_TRBDS3_TOP_DIO_0_BASEADDR));

			printf("SLV_REG 0 : %d\n", reg);
		}

		else if (a == 1)
		{
			printf("?\n");
			scanf("%d", &b);

			Xil_Out32((XPAR_TRBDS3_TOP_DIO_0_BASEADDR + 4), (u32)b);
			usleep(100);
			reg = Xil_In32(XPAR_TRBDS3_TOP_DIO_0_BASEADDR + 4);

			printf("SLV_REG 1 : %d\n", reg);
		}

	}
	return 0;
}
