#!/usr/bin/env python
import unittest
import serial

class SimplesticTest(unittest.TestCase):

	def setUp(self):
		self.sp = serial.Serial()
		self.sp.port = '/dev/ttyUSB0'
		self.sp.baudrate = 9600 
		self.sp.parity = serial.PARITY_EVEN
		self.sp.timeout = 0.050
		self.sp.open()

	def tearDown(self):
		self.sp.close()

	def transmit(self, s):
		self.sp.write(bytearray.fromhex(s))
#		print "> " + s 

	def receive(self, n):
		tmp = self.sp.read(n)
		s = " ".join("{:02x}".format(ord(c)) for c in tmp)
#		print '< ' + s
		return s

	def testPortOpen(self):
		self.assertTrue(self.sp.isOpen())

	def command(self, outstr, instr):
		self.transmit(outstr)
		s = self.receive(32)
		self.assertTrue(s == instr.lower())

	def testOpenCover(self):
		self.command("68 0a 0a 68 53 01 40 01 0c 01 12 70 00 00 24 16", "10 28 01 29 16");

	def testCloseCover(self):
		self.command("68 0a 0a 68 53 01 40 01 0c 01 12 71 00 00 25 16", "10 28 01 29 16");

	def testTiming(self):
		self.command("68 0F 0F 68 44 01 06 81 08 FF FF 00 40 9C 00 12 07 08 5D 2C 16", "");

	def testInquireCover(self):
		self.command("10 5B 01 5C 16", "68 04 04 68 08 01 DE ED D4 16")

if __name__ == '__main__':
	unittest.main()
