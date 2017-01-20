import sys
import conf #contains my API key, follows format from piazza
import re
import time
import logging
import json
from twisted.protocols import basic
from twisted.internet import protocol, reactor, defer
from twisted.application import service, internet
from twisted.web.client import getPage

API_KEY = conf.API_KEY
servers = conf.PORT_NUM

serverNeighbors = {
    "Alford" : ["Hamilton" , "Welsh"],
    "Ball" : ["Welsh" , "Holiday"], 
    "Hamilton" : ["Alford" , "Holiday"],
    "Holiday" : ["Hamilton" , "Ball"],
    "Welsh" : ["Alford" , "Ball"]
}

class ProxyHerdProtocol(basic.LineReceiver):
    def __init__(self, factory):
        self.factory = factory

    def connectionMade(self):
        logging.info("New connection established")

    def connectionLost(self, reason):
        logging.info("Connection lost")

    def propagate(self, message):
        for n in serverNeighbors[self.factory.name]:
            reactor.connectTCP('localhost', servers[n], ProxyClient(message))
        return

    def handle_IAMAT(self, line, unformattedline):
        components = line.split()
        if len(components) != 4:
            logging.error("invalid line received: {0}".format(unformattedline))
            self.transport.write("? {0}\n".format(unformattedline))
            return
        cmd, clientId, pos, clientTime = components
        timeDiff = time.time() - float(clientTime)
        response = None
        if timeDiff >= 0:
            response = "AT {0} +{1} {2}".format(self.factory.name, timeDiff, ' '.join(components[1:]))
        else:
            response = "AT {0} {1} {2}".format(self.factory.name, timeDiff, ' '.join(components[1:])) 
        if (clientId in self.factory.clients) and (clientTime <= self.factory.clients[clientId]["time"]):
            logging.info("duplicate/old IAMAT command") 
            return        
        self.factory.clients[clientId] = {"response":response, "time":clientTime} 
        logging.info("Server response: {0}".format(response))
        self.transport.write("{0}\n".format(response))
        logging.info("Propagate location update to neighbors")
        self.propagate(response)
        return


    def handle_AT(self, line, unformattedline):
        components = line.split()
        if (len(components) != 6):
            logging.error("invalid line received: {0}".format(unformattedline))
            self.transport.write("? {0}\n".format(unformattedline))
            return
        cmd, server, timeDiff, clientId, pos, clientTime = components
        if (clientId in self.factory.clients) and (clientTime <= self.factory.clients[clientId]["time"]):
            logging.info("duplicate/old IAMAT command") 
            return
        logging.info("{0} : {1}".format(line, clientTime))
        self.factory.clients[clientId] = {"response":line, "time":clientTime}
        self.propagate(self.factory.clients[clientId]["response"])
        return

    def handle_WHATSAT(self, line, unformattedline):
        components = line.split()
        if (len(components) != 4):
            logging.error("invalid line received: {0}".format(unformattedline))
            self.transport.write("? {0}\n".format(unformattedline))
            return
        cmd, clientId, radius, limit = components
        if not (clientId in self.factory.clients):
            logging.error("WHATSAT: client ID not found")
            self.transport.write("? {0}\n".format(unformattedline))
            return

        cachedResponse = self.factory.clients[clientId]["response"]
        logging.info("Cached response: {0}".format(cachedResponse))
        cmd, server, timeDiff,  client2Id, pos, clientTime = cachedResponse.split()
        pos = re.sub(r'[+]', ' +', pos)
        pos = re.sub(r'[-]', ' -', pos).split()
        pos_formatted = pos[0] + "," + pos[1]
        query = "location={0}&radius={1}&key={2}".format(pos_formatted, radius, API_KEY)
        url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?" + query
        logging.info("Query Google Places: {0}".format(url))
        queryResult = getPage(url)
        queryResult.addCallback(self.handleGooglePlaceResponse, clientId, limit)

    def handleGooglePlaceResponse(self, queryResult, pclientId, plimit):
        jsonObj = json.loads(queryResult)
        jsonObj["results"] = jsonObj["results"][0:int(plimit)]
        response = self.factory.clients[pclientId]["response"]
        tmp = json.dumps(jsonObj, indent=4)
        tmp = re.sub("[\n]+","\n",tmp).rstrip("\n")
        logging.info("WHATSAT response:\n{0}\n{1}\n\n".format(response, tmp))
        self.transport.write("{0}\n{1}\n\n".format(response, tmp))

    def validateAndHandleLine(self, commandName, line, unformattedline): #check for valid syntax and call appropriate handler
    	if (commandName == "IAMAT"):
    		match = re.search(r'^IAMAT[\s]+[\S]+[\s]+[\+\-][\d]+[\.][\d]+[\+\-][\d]+[\.][\d]+[\s]+[\d]+[\.][\d]+$' , line)
    		if match:
    			self.handle_IAMAT(line, unformattedline)
    		else:
    			logging.error("invalid line received: {0}".format(unformattedline))
                        self.transport.write("? {0}\n".format(unformattedline))
    	elif (commandName == "AT"):
    		match = re.search(r'^AT[\s]+(Alford|Ball|Hamilton|Holiday|Welsh)[\s]+[\+\-][\d]+[\.][\d]+[\s]+[\S]+[\s]+[\+\-][\d]+[\.][\d]+[\+\-][\d]+[\.][\d]+[\s]+[-]?[\d]+[\.][\d]+$' , line)
    		if match:
    			self.handle_AT(line, unformattedline)
	        else:
                    logging.error("invalid line received: {0}".format(unformattedline))
                    self.transport.write("? {0}\n".format(unformattedline))
    	elif (commandName == "WHATSAT"):
    		lineComponents = line.split()
    		radius = int(lineComponents[2])
    		informationBound = int(lineComponents[3])
    		if (radius > 50 or informationBound > 20):
                    logging.error("invalid line received: {0}".format(unformattedline))
                    self.transport.write("? {0}\n".format(unformattedline))
    		else:
    		    match = re.search(r'^WHATSAT [\S]+ [\d]+ [\d]+$' , line)
    		    if match:
    			self.handle_WHATSAT(line, unformattedline)
    		    else:
                        logging.error("invalid line received: {0}".format(unformattedline))
                        self.transport.write("? {0}\n".format(unformattedline))
    	else:
            logging.error("invalid line received: {0}".format(unformattedline))
            self.transport.write("? {0}\n".format(unformattedline))
    	return

    def lineReceived(self, line):
        logging.info("Received line: {0}".format(line))
        tmp = re.sub("[ \t]+"," ", line.strip()) #trim and compress whitespace 
        inputcomponents = tmp.split()
        self.validateAndHandleLine(inputcomponents[0], tmp, line)



class ProxyServer(protocol.ServerFactory):
    def __init__(self, serverName):
        self.name = serverName
        self.port = servers[self.name]
        self.clients = {}
        logging.basicConfig(filename = self.name + ".log", level = logging.DEBUG, filemode = 'a', format='%(asctime)s %(message)s')
        logging.info("Server started: {0} ({1})".format(self.name, self.port))

    def buildProtocol(self, addr):
        return ProxyHerdProtocol(self)

    def stopFactory(self):
        logging.info("{0} shutdown".format(self.name))

class ProxyClientProtocol(basic.LineReceiver):
    def __init__(self,factory):
        self.factory = factory

    def connectionMade(self):
        self.sendLine(self.factory.message)
        self.transport.loseConnection() #DOUBLE CHECK IF THIS SHOULD BE HERE OR NOT


class ProxyClient(protocol.ClientFactory):
    def __init__(self, message):
        self.message = message

    def buildProtocol(self, addr):
        return ProxyClientProtocol(self)

def main():
    if len(sys.argv) != 2:
        print "Invalid number of arguments"
        exit()
    factory = ProxyServer(sys.argv[1])
    reactor.listenTCP(servers[sys.argv[1]], factory)
    reactor.run()

if __name__ == '__main__':
	main()
