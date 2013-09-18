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
