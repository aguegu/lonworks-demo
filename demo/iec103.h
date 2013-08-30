#ifndef IEC_103_H_
#define IEC_103_H_

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

typedef  struct {
	uint8_t typ;
	uint8_t vsq;
	uint8_t cot;
	uint8_t pid;
	uint8_t fun;
	uint8_t inf;
} AsduHead;


Frame10 REP_NULL = { 0X10, 0X09, 0X00, 0X00, 0X16 };

#endif