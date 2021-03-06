"""
This module exposes two functions:
1) insertPosition()
	This function allows a basestation to insert a newly logged position of a bike
2) getIdsOfStolen()
	This function returns an array with the IDs of every bike that has been marked as stolen
"""

import pymongo
from bson import objectid

class BikeDB:
	def __init__(self, host='localhost', port=27017):
		self.client = pymongo.MongoClient(host, port)
		self.db = self.client.bikeapp
		self.positions = self.db.positions
		self.users = self.db.users
	
	def insertPosition(self, bikeID, latitude, longitude, time):
		newPos = {'bike_Id': bikeID, 'lat':latitude, 'long':longitude, 'time':time}
		self.positions.insert_one(newPos)

	def getIdsOfStolen(self):
		stolen = []
		self.positions.find()
		for user in self.users.find({'bikes':{'$elemMatch': {'stolen':True}}},{'bikes':1}):
			for bike in user['bikes']:
				if bike['stolen']==True:
					try:
						stolen.append(bike['_Id'])
					except KeyError as e:
						print('no key')
						
		return stolen


