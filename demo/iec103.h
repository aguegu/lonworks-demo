#ifndef IEC_103_H_
#define IEC_103_H_

#include "macros.h"

typedef struct {
	uint8_t length;
	uint8_t buff[64];
} Record;

#endif