#ifndef USART_H
#define USART_H

#include <io_types.h>

#pragma specify_io_clock "10 MHz"

IO_8 sci baud(SCI_9600) __parity(even) iosci;

struct ring_buff {
	uint8_t buff[256];
	uint8_t index_in;
	uint8_t index_out;
};

void usart_init(void);
int16_t usart_read(void);
void usart_flush(void);
uint8_t usart_available(void);

#include "usart.nc"

#endif