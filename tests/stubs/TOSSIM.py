class Variable:
    def __init__(self, value=0):
        self._value = value
    def getData(self):
        return self._value

class Node:
    def __init__(self, node_id):
        self.id = node_id
        self.received = 0
        self.sent = 0
        self.noise = []
    def addNoiseTraceReading(self, val):
        self.noise.append(val)
    def createNoiseModel(self):
        pass
    def bootAtTime(self, time):
        pass
    def getVariable(self, name):
        if name == "MacPerformanceC.received_packets":
            return Variable(self.received)
        elif name == "MacPerformanceC.counter":
            return Variable(self.sent)
        return Variable(0)

class Radio:
    def __init__(self):
        self.links = []
    def add(self, src, dest, gain):
        self.links.append((src, dest, gain))

class Tossim:
    def __init__(self, vars):
        self._time = 0
        self._nodes = {}
    def radio(self):
        return Radio()
    def mac(self):
        class Dummy: pass
        return Dummy()
    def addChannel(self, name, file):
        pass
    def getNode(self, node_id):
        if node_id not in self._nodes:
            self._nodes[node_id] = Node(node_id)
        return self._nodes[node_id]
    def time(self):
        return self._time
    def ticksPerSecond(self):
        return 1
    def runNextEvent(self):
        self._time += 1
