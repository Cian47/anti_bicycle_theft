var express = require('express');
var router = express.Router();
var util = require('util');

var monk = require('monk');
var db = monk('localhost:27017/bikeapp');
var users = db.get('users');

router.get('/', function(req,res){
    res.render('register',{title: 'register'});
});

router.post('/',function(req, res){
	//Validation
	req.checkBody('username','Username is too short').notEmpty().len(5,20);


	var errors = req.validationErrors();
	if (errors) {
    res.status('There have been validation errors: ' + util.inspect(errors), 400);
    return;

    //end validation
  	}
	users.find({username:req.body.username},{},function(e,docs){
		var errMessage;
		if(docs.length!=0){
			errMessage='this username has already been chosen. Please use another one!'
			res.render('register',{title:'register', error:errMessage});
		}
		else{
			req.loginCookie.username = req.body.username;
			users.insert({username: req.body.username, password: req.body.password}, function(a,b){
				if(a) throw a;});
		res.redirect('/');
		}
	});
});

module.exports = router;
