var express = require('express');
var mongodb = require('mongodb')
var monk = require('monk');
var db = monk('localhost:27017/bikeapp');
var users = db.get('users');
var positions = db.get('positions');

var router = express.Router();


router.get('/registerNew', function(req, res){
	var username = req.loginCookie.username;
	res.render('registerBike', {username:username});
});

router.post('/registerNew',function(req,res){
	var username = req.loginCookie.username;
	var bikeName = req.body.nickname;
	var color = req.body.color;
	var sensorId = req.body.sensorId;
	users.find({username:username},{}, function(e, docs){
		users.find({username:username, bikes:{$elemMatch:{nickname:bikeName}}},{},function(e,docs){
			if(docs.length>0){
			}
			else{
				users.update({username:username},{$push:{bikes:{nickname:bikeName, color:color, stolen:false, _Id:sensorId}}})
			}
		});	
	});
	res.redirect('/');
});

router.get('/showBike',function(req,res){
	var username = req.loginCookie.username;
	var bikeName = req.query.nickname;	
	users.findOne({username:username, bikes:{$elemMatch:{nickname:bikeName}}},{fields: {'bikes.$':1}},function(e,user){
		if(user){
		positions.find({bike_Id:user.bikes[0]._Id}, function(e,pos){
			if(pos.length>0){
			//calculate marker string for map
			var labels=['A',  'B',  'C',  'D',  'E',  'F',  'G',  'H',  'I',  'J',  'K',  'L',  'M',  'N',  'O',  'P',  'Q',  'R',  'S',  'T',  'U',  'V',  'W',  'X',  'Y',  'Z'];
			var markerString = "";
			var count=0;
			for(position of pos){
				if(count<=7){
				markerString+="&markers=color:green%7Clabel:"+labels[count]+"%7C"+position.lat+","+position.long
				count+=1;
				}
				else{
					break;
				}
			}
			res.render('showBike', {username:username, bikeName:bikeName, positions:pos, markerString:markerString, labels:labels})
			}
			else{
				res.redirect('/');
			}
		});
	}
	else{
		res.redirect('/');
	}
	});


});

module.exports = router;
