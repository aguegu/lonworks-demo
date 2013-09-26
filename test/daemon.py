#!/usr/bin/env python 

import serial
from node103 import Node
import threading
import time

class Daemon:
	def __init__(self):
		sp = serial.Serial();
		sp.port = '/dev/ttyUSB0'
		sp.baudrate = 9600
		sp.parity = serial.PARITY_NONE
		sp.timeout = 0.07

		self.node = Node(sp, 0x01)

	def setUp(self):
		self.node.open()

	def command(self, outstr):
		self.node.transmit(outstr)
		print "\n> ", Node.getHex(outstr)
		m = self.node.receive(64)
		print "< ", Node.getHex(m)
	
	def run(self):
		self.command(self.node.frame10(0x5b))
#		threading.Timer(5, self.run).start()

if __name__ == '__main__':
	dae = Daemon()
	dae.setUp()
	while True:
		dae.run()
		time.sleep(5)
	
