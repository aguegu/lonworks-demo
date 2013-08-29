far struct ring_buff _buff_rx;
far struct ring_buff _buff_tx;

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

when (io_in_ready(iosci)) {
	_length = sci_in_request_ex(_usart_dr[_flag], 16);	
	_flag ^= 0x01;	
	usart_rxbuffin(_usart_dr[_flag], _length);	
}

uint8_t usart_available(void) {
	return  (uint8_t)((BUFF_SIZE - _buff_rx.index_out + _buff_rx.index_in) % BUFF_SIZE);
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

void usart_write(uint8_t data) {
	uint8_t i;
	i = (uint8_t)((_buff_tx.index_in + 1) % BUFF_SIZE);
	while (i == _buff_tx.index_out);
	
	_buff_tx.buff[_buff_tx.index_in] = data;
	_buff_tx.index_in = i;
}

void usart_flush(void) {	
	uint8_t c;
	while (usart_available()) {
		c = (uint8_t)usart_read();
		io_out_request(iosci, &c, 1);		
	}
}
