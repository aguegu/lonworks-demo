#!/usr/bin/env python
import unittest
import serial
import re

class Node:
	def __init__(self, serialport, address):
		self.sp = serialport
		self.address = address

	def command10(self, function):
		s = bytearray()
		s.append(0x10)
		s.append(function)
		s.append(self.address)
		s.append(function + self.address)
		s.append(0x16)
		return s

	@staticmethod
	def getHex(ba):
		return " ".join("{:02x}".format(k) for k in ba)

	def open(self):
		self.sp.open()

	def close(self):
		self.sp.close()
		

class SimplesticTest(unittest.TestCase):

	def setUp(self):
		sp = serial.Serial();
		sp.port = '/dev/ttyUSB0'
		sp.baudrate = 9600 
		sp.parity = serial.PARITY_EVEN
		sp.timeout = 0.06
		self.node = Node(sp, 0x01)
		self.node.open()
		print Node.getHex(self.node.command10(0x28))

	def tearDown(self):
		self.node.close()

	def transmit(self, s):
		self.sp.write(bytearray.fromhex(s))
		print "\n> " + s 

	def receive(self, n):
		m = memoryview(self.sp.read(n)).tolist()

		if len(m):
			self.assertTrue(m[0] == 0x68 or m[0] == 0x10)
			self.assertTrue(m[-1] == 0x16)
		
			if m[0] == 0x68:
				self.assertTrue(sum(m[4:-2]) & 0xff == m[-2])
				self.assertTrue(m[0] == m[3])
				self.assertTrue(m[1] == m[2])
				self.assertTrue(len(m[4:-2]) & 0xff == m[1])

			if m[0] == 0x10:
				self.assertTrue(sum(m[1:3]) & 0xff == m[-2])

		s = " ".join("{:02x}".format(k) for k in m)
		print '< ' + s
		return s

	def testPortOpen(self):
		self.assertTrue(self.node.sp.isOpen())

	def command(self, outstr, instr):
		self.transmit(outstr)
		s = self.receive(32)
		#self.assertTrue(s == instr.lower())
		self.assertTrue(re.match(instr.lower(), s))

	def testOpenCover(self):
		self.command("68 0a 0a 68 53 01 40 01 0c 01 12 70 00 00 24 16", "^10 28 01 29 16$");

	def testCloseCover(self):
		self.command("68 0a 0a 68 53 01 40 01 0c 01 12 71 00 00 25 16", "^10 28 01 29 16$");

	def testTiming(self):
		self.command("68 0F 0F 68 44 01 06 81 08 FF FF 00 40 9C 00 12 07 08 5D 2C 16", "");

	def testInquireCover(self):
		self.command("10 5B 01 5C 16", "^68 1a 1a 68 08 01 32 83 00 00 0c 01 01 08 ([\da-f]{2} ){4}01 09 ([\da-f]{2} ){4}01 01 ([\da-f]{2} ){5}16$")

if __name__ == '__main__':
	unittest.main()
