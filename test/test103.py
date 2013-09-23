#!/usr/bin/env python
import unittest
import serial
import datetime
import re
import time
import struct

from node103 import Node

class SimplesticTest(unittest.TestCase):

	def setUp(self):
		sp = serial.Serial();
		sp.port = '/dev/ttyUSB0'
		sp.baudrate = 9600 
		sp.parity = serial.PARITY_NONE
		sp.timeout = 0.07

		self.node = Node(sp, 0x01)
		self.node.open()

	def tearDown(self):
		self.node.close()
		print

	def testPortOpen(self):
		self.assertTrue(self.node.sp.isOpen())

	def command(self, outstr):
		self.node.transmit(outstr)
		print "\n> " + Node.getHex(outstr)
		m = self.node.receive(64)
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
		return m

	@unittest.skip("without open")
	def testOpenCover(self):
		time.sleep(0.5)
		m = self.command(self.node.openCover())
		self.assertTrue(re.match(Node.getHex(self.node.frame10(0x28)), Node.getHex(m)))

	def testCloseCover(self):
		time.sleep(0.5)
		m = self.command(self.node.closeCover())
		self.assertTrue(re.match(Node.getHex(self.node.frame10(0x28)), Node.getHex(m)))
	

	def testInquireCover(self):
		time.sleep(0.5)
		m = self.command(self.node.frame10(0x5b))
		status = re.match(("68 1a 1a 68 08 %02x 32 83 00 00 0c 01 " +
			"(([\da-f]{2} ){6}){3}[\da-z]{2} 16")  % (self.node.address), Node.getHex(m))

		event_names = ["", "shock", "tile", "open"]
		if status:
			angle = struct.unpack('f', m[14:18])[0]
			print "angle: %.2f," % angle,
			stroke = struct.unpack('f', m[20:24])[0]
			print "stroke: %.2f," % stroke,
			print "status: %02x," % m[26],
			print "hasevent: %r," % bool(m[26] & 0x01),
			print "angle alarm: %r," % bool(m[26] & 0x02),
			print "magnet in position: %r" % bool(m[26] & 0x04)

		events = re.match(("68 (?:(?:(?:13)|(?:1d)|(?:27)) ){2}68 08 %02x 29 8[1-3] 00 00 0c 01") % self.node.address, Node.getHex(m))
		if events:
			i = 13
			while i + 10 < len(m):
				j = m[i]
#				print "%r" % Node.getHex(m[i:i+10])
				print "on %02d:%02d:%02d," % (m[i + 4], m[i+3],m[i+2]), 
				print "count: %d," % m[i+5],
				print "event: %s," % event_names[j],
				if j == 0x01 or j == 0x02:
					print "val: %.2f" % struct.unpack('f', m[i+6:i+10])
				i += 10

		self.assertTrue(status or events)

	def testTiming(self):
		time.sleep(0.5)
		self.node.adjustTime()
		self.command(self.node.adjustTime())

if __name__ == '__main__':
	unittest.main()
