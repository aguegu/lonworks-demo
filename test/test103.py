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

	def transmit(self, s):
		self.sp.write(bytearray.fromhex(s))
#		print "> " + s 

	def receive(self, n):
		tmp = self.sp.read(n)
		s = " ".join("{:02x}".format(ord(c)) for c in tmp)
#		print '< ' + s
		return s

	def testOpen(self):
		self.sp.open()
		self.assertTrue(self.sp.isOpen())
		self.sp.close()

	def command(self, outstr, instr):
		self.sp.open()
		self.transmit(outstr)
		s = self.receive(32)
		self.sp.close()
		self.assertTrue(s == instr)

	def testOpenCover(self):
		self.command("68 0a 0a 68 53 01 40 01 0c 01 12 70 00 00 24 16", "10 28 01 29 16");

	def testCloseCover(self):
		self.command("68 0a 0a 68 53 01 40 01 0c 01 12 71 00 00 25 16", "10 28 01 29 16");
	
if __name__ == '__main__':
	unittest.main()
