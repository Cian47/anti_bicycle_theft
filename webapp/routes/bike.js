var express = require('express');
var router = express.Router();

var monk = require('monk');
var db = monk('localhost:27017/bikeapp');
var users = db.get('users');

router.get('/registerNew', function(req, res){
	var username = req.loginCookie.username;
	res.render('registerBike', {username:username});

});

router.post('/registerNew',function(req,res){
	var username = req.loginCookie.username;
	users.find({username:username},{}, function(e, docs){
		for(bike of docs[0].bikes){
			users.find({username:username, bikes:{$elemMatch:{nickname:req.body.nickname}}},{},function(e,docs){
				if(docs.length>0){
					console.log('already exists');
				}
				else{
					users.update({username:username},{$push:{bikes:{nickname:req.body.nickname, color:req.body.color}}})
				}
			});
		}
	});
	res.redirect('registerNew');
});

module.exports = router;