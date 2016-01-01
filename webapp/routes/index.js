var express = require('express');
var router = express.Router();

var monk = require('monk');
var db = monk('localhost:27017/bikeapp');
var users = db.get('users');

router.get('/', function(req,res){
	var username= req.loginCookie.username;
	users.find({username:username}, function(e,docs){
		var bikes = docs[0].bikes;
		res.render('index', {username: username, bikes:bikes});
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