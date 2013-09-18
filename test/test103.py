#!/usr/bin/env python
import unittest
import serial
import datetime
import re
import time

from node103 import Node

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
