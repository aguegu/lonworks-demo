#include "macros.h"

typedef struct {
	uint8_t length;
	uint8_t buff[256];
} Record;

typedef struct {
	uint8_t start;
	uint8_t length;
	uint8_t length_confirm;
	uint8_t start_confirm;
	uint8_t control;
	uint8_t address;	
} Header68;

typedef struct {
	Header68 * header68;
	uint8_t * asdu_buff;	
	uint8_t * crc;
	uint8_t * end;
	uint8_t asdu_length;
} Frame68;

typedef struct {
	uint8_t start;	
	uint8_t control;
	uint8_t address;	
	uint8_t crc;
	uint8_t end;
} Frame10;

typedef struct {
	Record record;
	uint8_t *control;
	uint8_t *address;
	Frame68 frame68;	
	Frame10 *frame10;
} Package;