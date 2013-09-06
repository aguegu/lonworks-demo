#ifndef USART_NC
#define USART_NC

#include <io_types.h>

#pragma specify_io_clock "10 MHz"

IO_8 sci baud(SCI_9600) __parity(even) iosci;

#define BUFF_SIZE 128

struct RingBuff{
	uint8_t buff[BUFF_SIZE];
	uint8_t index_in;
	uint8_t index_out;
};

far struct RingBuff _buff_rx;
far struct RingBuff _buff_tx;

static far uint8_t _usart_dr[2][16];
static uint8_t _length;
static uint8_t _flag;

void usart_init(void) {
    _buff_rx.index_in = 0;
    _buff_rx.index_out = 0;        
    _buff_tx.index_in = 0;
    _buff_tx.index_out = 0;

	_flag = 0;
   	(void)io_in_request(iosci, _usart_dr[1], 16);
}

void usart_rxbuffin(uint8_t *p, uint8_t length) {
	uint8_t i;
	while (length--) {
		i = (uint8_t)((_buff_rx.index_in + 1) % BUFF_SIZE);
		if (i != _buff_rx.index_out) {	
			_buff_rx.buff[_buff_rx.index_in] = *p++;
			_buff_rx.index_in = i;	
		}
	}
}

void usart_txbuffout(uint8_t *p, uint8_t length) {
	while (length--) {
		*p++ = (uint8_t)_buff_tx.buff[_buff_tx.index_out];
		_buff_tx.index_out = (uint8_t)((_buff_tx.index_out + 1) % BUFF_SIZE);
		if (_buff_tx.index_out == _buff_tx.index_in) 
			break;
	}
}

when (io_in_ready(iosci)) {
	_length = sci_in_request_ex(_usart_dr[_flag], 16);	
	_flag ^= 0x01;	
	usart_rxbuffin(_usart_dr[_flag], _length);	
}

uint8_t usart_available(void) {
	return  (uint8_t)((BUFF_SIZE - _buff_rx.index_out + _buff_rx.index_in) % BUFF_SIZE);
}

uint8_t usart_cached(void) {
	return  (uint8_t)((BUFF_SIZE - _buff_tx.index_out + _buff_tx.index_in) % BUFF_SIZE);
}

int16_t usart_read(void) {
	if (_buff_rx.index_in != _buff_rx.index_out) {
		uint8_t c;
		c = _buff_rx.buff[_buff_rx.index_out];
		_buff_rx.index_out = (uint8_t)((_buff_rx.index_out + 1) % BUFF_SIZE);
		return c;
	}
	return -1;	
}

int16_t usart_readTimed(void) {
	uint16_t start, t;
	int16_t c;
	start = get_tick_count();
	t = 6;
	
	while (t) {
		c = usart_read();
		if (c >= 0 ) return c;
		if (get_tick_count() - start) {
			t--;
			start++;
		}
	}
	
	return -1;
}

uint8_t usart_readBytes(uint8_t * buff, uint8_t length) {
	uint8_t index;
	int16_t c; 
	
	index = 0;
	
	while(index < length) {
		c = usart_readTimed();
		if (c == -1) break;
		*buff++ = (uint8_t)c;
		index++;
	}
	
	return index;
}

void usart_write(uint8_t data) {
	uint8_t i;
	i = (uint8_t)((_buff_tx.index_in + 1) % BUFF_SIZE);
	if (i != _buff_tx.index_out) {
		_buff_tx.buff[_buff_tx.index_in] = data;
		_buff_tx.index_in = i;
	}
}

void usart_writeBytes(uint8_t *buff, uint8_t length) {
	while (length--) 
		usart_write(*buff++);
}

void usart_writeString(const char *buff) {
	while (*buff) 
		usart_write(*buff++);
}

void usart_flush(void) {	
	uint8_t c;
	while (usart_cached()) {
		usart_txbuffout(&c, 1);
		io_out_request(iosci, &c, 1);		
	}
}

#endif