#!/usr/bin/env python
import serial

def transmit(sp, s):
	sp.write(bytearray.fromhex(s))
	print "> " + s 

def receive(sp, n):
	tmp = sp.read(n)
	s = " ".join("{:02x}".format(ord(c)) for c in tmp)
	print '< ' + s
	return s

#####################################################################

sp = serial.Serial()
sp.port = '/dev/ttyUSB0'
sp.baudrate = 9600 
sp.parity = serial.PARITY_EVEN
sp.timeout = 0.050

sp.open()

assert sp.isOpen(), "serial port fails to be opened"

transmit(sp, '68 0a 0a 68 53 01 40 01 0c 01 12 70 00 00 24 16')
s = receive(sp, 6)

assert s == "10 28 01 29 16"

sp.close()


