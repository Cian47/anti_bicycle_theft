from pymongo import MongoClient

class BikeDB:
	def __init__(self, host='localhost', port=27017):
		self.client = MongoClient(host, port)
		self.db = client.bikeapp
		self.positions = db.positions
	def printPositions():
		return self.positions.find()


