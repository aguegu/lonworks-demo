#ifndef USART_H
#define USART_H

#include <io_types.h>

#pragma specify_io_clock "10 MHz"

IO_8 sci baud(SCI_9600) __parity(even) iosci;

#define BUFF_SIZE 128

struct RingBuff{
	uint8_t buff[BUFF_SIZE];
	uint8_t index_in;
	uint8_t index_out;
};

#include "usart.nc"

#endif