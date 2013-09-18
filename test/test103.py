#!/usr/bin/env python
import unittest
import serial
import datetime
import re
import time

class Node:
	def __init__(self, serialport, address):
		self.sp = serialport
		self.address = address

	def frame10(self, function):
		s = bytearray()
		s.append(0x10)
		s.append(function)
		s.append(self.address)
		s.append(function + self.address)
		s.append(0x16)
		return s

	def initFrame68(self, function):
		s = bytearray()
		s.append(0x68)
		s.append(0)
		s.append(0)
		s.append(0x68)
		s.append(function)
		s.append(self.address)
		return s

	def appendFrame68(self, s, asdu):
		s.extend(asdu)
		return s

	def completeFrame68(self, s):
		s.append(sum(s[4:]) & 0xff)
		s.append(0x16)
		s[1] = s[2] = len(s) - 6 
		return s
	
	@staticmethod
	def getHex(ba):
		return " ".join("{:02x}".format(k) for k in ba)

	def open(self):
		self.sp.open()

	def close(self):
		self.sp.close()

	def openCover(self):
		s = self.initFrame68(0x53)
		s = self.appendFrame68(s, bytearray.fromhex("40 01 0c 01 12 70 00 00"))
		s = self.completeFrame68(s)
		return s
	
	def closeCover(self):
		s = self.initFrame68(0x53)
		s = self.appendFrame68(s, bytearray.fromhex("40 01 0c 01 12 71 00 00"))
		s = self.completeFrame68(s)
		return s

	def transmit(self, s):
		self.sp.write(s)

	def receive(self, n):
		return (bytearray)(self.sp.read(n))

	def adjustTime(self, t = datetime.datetime.now()):
		s = self.initFrame68(0x44)
		s = self.appendFrame68(s, bytearray.fromhex("06 81 08 FF FF 00"))
		t = datetime.datetime.now()
		millis = t.second * 1000 + t.microsecond/ 1000 
		s = self.appendFrame68(s, bytearray([millis % 256, millis / 256, t.minute, t.hour, t.day, t.month, t.year & 0x7f]))
		s = self.completeFrame68(s)
		return s


class SimplesticTest(unittest.TestCase):

	def setUp(self):
		sp = serial.Serial();
		sp.port = '/dev/ttyUSB0'
		sp.baudrate = 9600 
		sp.parity = serial.PARITY_NONE
		sp.timeout = 0.06

		self.node = Node(sp, 0x08)
		self.node.open()

	def tearDown(self):
		self.node.close()
		print

	def testPortOpen(self):
		self.assertTrue(self.node.sp.isOpen())

	def command(self, outstr, instr):
		self.node.transmit(outstr)
		print "\n> " + Node.getHex(outstr)
		print "= " + instr
		m = self.node.receive(32)
		print "< " + Node.getHex(m)
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

		self.assertTrue(re.match(instr.lower(), Node.getHex(m)))

	def testOpenCover(self):
		time.sleep(0.5)
		self.command(self.node.openCover(), Node.getHex(self.node.frame10(0x28)))

	def testCloseCover(self):
		time.sleep(0.5)
		self.command(self.node.closeCover(), Node.getHex(self.node.frame10(0x28)))

	def testInquireCover(self):
		time.sleep(0.5)
		self.command(self.node.frame10(0x5b), "68 1a 1a 68 08 %02x 32 83 00 00 0c 01 01 08 ([\da-f]{2} ){4}01 09 ([\da-f]{2} ){4}01 01 ([\da-f]{2} ){5}16" % (self.node.address))

	def testTiming(self):
		time.sleep(0.5)
		self.node.adjustTime()
		self.command(self.node.adjustTime(), "")

if __name__ == '__main__':
	unittest.main()
