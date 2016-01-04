var express = require('express');
var router = express.Router();

var monk = require('monk');
var db = monk('localhost:27017/bikeapp');
var users = db.get('users');

//call login page
router.get('/', function(req,res,next){
		//res.end(JSON.stringify({title:'login page'}));
	res.render('login',{title: 'login',failedLogin:false});
});


//handle login form
router.post('/',function(req, res){
	users.find({username:req.body.username},{}, function(e, docs){
		if(docs.length==0 || docs[0].password != req.body.password){
			res.render('login',{title:'login', failedLogin:true});
			}
		else{
			req.loginCookie.username = req.body.username;
			res.redirect('/');	
		}	
	});
});

module.exports = router;	