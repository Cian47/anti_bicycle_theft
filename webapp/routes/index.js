var express = require('express');
var router = express.Router();
var util = require('util');
var monk = require('monk');
var db = monk('localhost:27017/bikeapp');
var users = db.get('users');
var positions = db.get('positions')

router.get('/', function(req,res){
	var username= req.loginCookie.username;
	users.findOne({username:username}, function(e,user){
		var bikes = user.bikes;
		//Create an array holding the amount of logged locations per bike so they can be shown in a badge
		var count = 1;
		for(bike of bikes){
			positions.find({user_id:user._id, bike_name:bike.nickname},{}, function(e,docs){
				//this relies on for(.. of..) to interate over array in order (a[0],a[1],...). Not sure if this is always the case
				bikes[count-1].numberOfLogs = docs.length;
				if(count==bikes.length){
					res.render('index', {username: username, bikes:bikes});
				}
				else
					count+=1;
			});
		}
	});
	
});
//POST inputs for changing a bikes status
router.post('/', function(req,res){
	var username= req.loginCookie.username;
	if(req.body.changeTo=='stolen'){
		users.update({username:username, bikes:{$elemMatch:{nickname:req.body.bikename}}},{$set:{"bikes.$.stolen":true}},function(err){
		});
	}
	else if(req.body.changeTo=='found'){
		users.update({username:username, bikes:{$elemMatch:{nickname:req.body.bikename}}},{$set:{"bikes.$.stolen":false}},function(err){
		});
	}
	res.redirect('/');
})

module.exports = router;