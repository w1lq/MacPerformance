#! /usr/bin/python
from TOSSIM import *
from sets import Set
import sys
from optparse import OptionParser

parser = OptionParser(usage="usage: %prog [options] filename",
	version="%prog 1.0")

parser.add_option("-g", "--gainfile",
	action="store",
	dest="gainfile",
	default="topology.txt",
	help="file containing gains between simulation nodes")

parser.add_option("-n", "--noisefile",
	action="store",
	dest="noise",
	default="Noise/meyer-heavy-short.txt",
	help="file containing gains between simulation nodes")

(options, args) = parser.parse_args()

options_dict = vars(options)

print options_dict['gainfile']

print "Simulation start"

from tinyos.tossim.TossimApp import *
n = NescApp()
vars = n.variables.variables()

t = Tossim(vars)
r = t.radio()
mac = t.mac()

# Topology configuration
gainfile = open(options_dict['gainfile'], "r")

nodes = Set([])

print "Simulation Topology:"
lines = gainfile.readlines()
for line in lines:
	splitlines = line.split() 
	if (len(splitlines) > 0):
		if (splitlines[0] == "gain"):
			r.add(int(splitlines[1]), int(splitlines[2]), float(splitlines[3].replace(",",".")))
			print "Source:", splitlines[1], "Destination:", splitlines[2], "Gain:", splitlines[3], "dBm";
			nodes.add(int(splitlines[1]))
			nodes.add(int(splitlines[2]))

print "Number of nodes: " + str(len(nodes)) + ", nodes' ids:", nodes

# Allocating debug outputs
energy_output = open("Simulation/Energy.txt", "w")
packet_output = open("Simulation/Packet.txt", "w")
t.addChannel("PacketState", packet_output)
t.addChannel("ENERGY_HANDLER", energy_output)

# Opening simulation result file
resultfile = open("Simulation/Result.txt", "w")

# Default noise trace
noise = open(options_dict['noise'], "r")
lines = noise.readlines()
for line in lines:
	stripline = line.strip() 
	if (stripline != ""):
		val = int(stripline)
		for node in nodes:
			t.getNode(node).addNoiseTraceReading(val)

for node in nodes:
	print "Creating noise model for node " + str(node) + "."
	t.getNode(node).createNoiseModel()

# Boot time spread
boot_time = 0
for node in nodes:
	t.getNode(node).bootAtTime(0 + boot_time);
	boot_time += 50000000 # equal to 5 ms


# This runs the network for 50 seconds:
time = t.time()
while (time + t.ticksPerSecond() * 50 > t.time()):
	t.runNextEvent()

resultfile.write("%d\n" % (t.time()))

for node in nodes:
	m = t.getNode(node)
	v = m.getVariable("MacPerformanceC.received_packets")
	received_packets = v.getData()
	c = m.getVariable("MacPerformanceC.counter")
	sent_packets = c.getData()	
	print "The node id", node, "has sent", sent_packets, "and received", received_packets, "in total.";	

	resultfile.write("%d,%d,%d\n" % (node, sent_packets, received_packets))

print "End of simulation."

