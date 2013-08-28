
far struct ring_buff buff_rx;
far struct ring_buff buff_tx;

static far uint8_t usart_dr[2][16];
uint8_t length;
static uint8_t flag;

void usart_init(void) {
    buff_rx.index_in = 0;
    buff_rx.index_out = 0;        
    buff_tx.index_in = 0;
    buff_tx.index_out = 0;

	flag = 0;
   	(void)io_in_request(iosci, usart_dr[1], 16);
}

void usart_rxbuffin(uint8_t *p, uint8_t len) {
	uint8_t i;
	while (len--) {
		i = (buff_rx.index_in + 1) % BUFF_SIZE;
		if (i != buff_rx.index_out) {	
			buff_rx.buff[buff_rx.index_in] = *p++;
			buff_rx.index_in = i;	
		}
	}
}

when (io_in_ready(iosci)) {
//	uint8_t i;
//	i = (buff_rx.index_in + 1) % BUFF_SIZE;
//	if (i != buff_rx.index_out) {
//		buff_rx.buff[buff_rx.index_in] = usart_dr[flag];
//		buff_rx.index_in = i;
//	}

	length = sci_in_request_ex(usart_dr[flag], 128);	
	flag ^= 0x01;	
	usart_rxbuffin(usart_dr[flag], length);	
}

uint8_t usart_available(void) {
	return  (uint8_t)((BUFF_SIZE - buff_rx.index_out + buff_rx.index_in) % BUFF_SIZE);
}

int16_t usart_read(void) {
	if (buff_rx.index_in != buff_rx.index_out) {
		uint8_t c;
		c = buff_rx.buff[buff_rx.index_out];
		buff_rx.index_out = (buff_rx.index_out + 1) % BUFF_SIZE;
		return c;
	}
	return -1;	
}



void usart_write(uint8_t data) {
	uint8_t i;
	i = (buff_tx.index_in + 1) % BUFF_SIZE;
	while (i == buff_tx.index_out);
	
	buff_tx.buff[buff_tx.index_in] = data;
	buff_tx.index_in = i;
}

void usart_flush(void) {	
	uint8_t c;
	while (usart_available()) {
		c = (uint8_t)usart_read();
		io_out_request(iosci, &c, 1);		
	}
}
