
far struct ring_buff buff_rx;
far struct ring_buff buff_tx;

static uint8_t usart_dr;
uint8_t dummy;

void usart_init(void) {
    buff_rx.index_in = 0;
    buff_rx.index_out = 0;        
    buff_tx.index_in = 0;
    buff_tx.index_out = 0;

   	dummy = io_in_request(iosci, &usart_dr, 1);
}

when (io_in_ready(iosci)) {
	uint8_t i;
	i = (buff_rx.index_in + 1) % 256;
	if (i != buff_rx.index_out) {
		buff_rx.buff[buff_rx.index_in] = usart_dr;
		buff_rx.index_in = i;
	}
	
	dummy = sci_in_request_ex(&usart_dr, 1);	
}

uint8_t usart_available(void) {
	return  (uint8_t)((buff_rx.index_in + 256 - buff_rx.index_out) % 256);
}

int16_t usart_read(void) {
	if (buff_rx.index_in != buff_rx.index_out) {
		uint8_t c;
		c = buff_rx.buff[buff_rx.index_out];
		buff_rx.index_out = (buff_rx.index_out + 1) % 256;
		return c;
	}
	return -1;	
}

void usart_write(uint8_t data) {
	uint8_t i;
	i = (buff_tx.index_in + 1) % 256;
	while (i == buff_tx.index_out);
	
	buff_tx.buff[buff_tx.index_in] = data;
	buff_tx.index_in = i;
}

void usart_flush(void) {
	while (usart_available()) {
		usart_dr = (uint8_t)usart_read();
		io_out_request(iosci, &usart_dr, 1);		
	}
}
