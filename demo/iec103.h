#ifndef IEC_103_H_
#define IEC_103_H_

#include "macros.h"
#include <float.h>

typedef struct {
	uint8_t buff[64];
	uint8_t length;
} Record;

typedef struct {
	uint8_t start;
	uint8_t length;
	uint8_t length_confirm;
	uint8_t start_confirm;
	uint8_t control;
	uint8_t address;
} Header68;

typedef  struct {
	uint8_t typ;
	uint8_t vsq;
	uint8_t cot;
	uint8_t pid;
	uint8_t fun;
	uint8_t inf;
} AsduHead;

void init(Record *p, void * cache, uint8_t length) {
	memcpy(p->buff, cache, length);
	p->length = length;
}

void fillFrame10(Record *p, uint8_t control, uint8_t address) {
	p->buff[0] = 0x10;
	p->buff[1] = control;
	p->buff[2] = address;
	p->buff[3] = p->buff[1] + p->buff[2];
	p->buff[4] = 0x16;
	p->length = 5;
}

void fillFrame68(Record *p, uint8_t control, uint8_t address, const void * asdu, uint8_t asdu_length) {
	uint8_t i, sum;

	p->buff[0] = p->buff[3] = 0x68;
	p->buff[1] = p->buff[2] = asdu_length + 2;
	p->buff[4] = control;
	p->buff[5] = address;
	memcpy(p->buff + 6, asdu, asdu_length);

	for (i=4, sum=0; i<6+asdu_length; i++)
		sum += p->buff[i];

	p->buff[asdu_length + 6] = sum;
	p->buff[asdu_length + 7] = 0x16;
	p->length = asdu_length + 8;
}

uint8_t getFunctionCode(Record *p) {
   uint8_t func;

	if (p->buff[0] == 0x68)
		func = *(p->buff + 4) & 0x0f;
	else if (p->buff[0] == 0x10)
		func = *(p->buff + 1) & 0x0f;
	else
		func = 0;

	return func;
}

AsduHead * getAsduHead(Record *p) {
	return (AsduHead *) (p->buff + 6);
}

#endif