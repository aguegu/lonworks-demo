#ifndef IEC_103_H_
#define IEC_103_H_

#include "macros.h"
#include <float.h>

#define BUFF_SIZE 64

typedef struct {
	uint8_t buff[BUFF_SIZE];
	uint8_t length;
} Record;

typedef  struct {
	uint8_t typ;
	uint8_t vsq;
	uint8_t cot;
	uint8_t pid;
	uint8_t fun;
	uint8_t inf;
} AsduHead;

void setFrame10(Record *p, uint8_t control, uint8_t address) {
	p->buff[0] = 0x10;
	p->buff[1] = control;
	p->buff[2] = address;
	p->buff[3] = p->buff[1] + p->buff[2];
	p->buff[4] = 0x16;
	p->length = 5;
}

void initFrame68(Record *p, uint8_t control, uint8_t address) {
	p->buff[0] = p->buff[3] = 0x68;
	p->buff[1] = p->buff[2] = 0;
	p->buff[4] = control;
	p->buff[5] = address;
	p->length = 6;
}

void appendByteToFrame68(Record *p, const uint8_t buff) {
	p->buff[p->length] = buff;
	p->length++;
}

void appendFrame68(Record *p, const void * buff, uint8_t len) {
	memcpy(p->buff + p->length, buff, len);
	p->length += len;
}

void completeFrame68(Record *p) {
	uint8_t i, sum;
	for (i=4, sum=0; i < p->length; i++)
		sum += p->buff[i];

	p->buff[p->length] = sum;
	p->buff[p->length + 1] = 0x16;
	p->length += 2;

	p->buff[1] = p->buff[2] = p->length - 6;
}

void clear(Record *p) {
    p->length = 0;
    memset(p->buff, 0, BUFF_SIZE);
}

#endif