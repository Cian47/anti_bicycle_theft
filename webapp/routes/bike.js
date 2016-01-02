var express = require('express');
var router = express.Router();

var monk = require('monk');
var db = monk('localhost:27017/bikeapp');
var users = db.get('users');
var positions = db.get('positions');

router.get('/registerNew', function(req, res){
	var username = req.loginCookie.username;
	res.render('registerBike', {username:username});

});

router.post('/registerNew',function(req,res){
	var username = req.loginCookie.username;
	var bikeName = req.body.nickname;
	var color = req.body.color;
	users.find({username:username},{}, function(e, docs){
		users.find({username:username, bikes:{$elemMatch:{nickname:bikeName}}},{},function(e,docs){
			if(docs.length>0){
				console.log('already exists');
			}
			else{
				users.update({username:username},{$push:{bikes:{nickname:bikeName, color:color, stolen:false}}})
			}
		});	
	});
	res.redirect('/');
});

router.get('/showBike',function(req,res){
	var username = req.loginCookie.username;
	var bikeName = req.query.nickname;
	console.log(bikeName);
	
		users.findOne({username:username, bikes:{$elemMatch:{nickname:bikeName}}},{fields: {'bikes.$':1}},function(e,user){
			positions.find({user_id:user._id, bike_name:user.bikes[0].nickname}, function(e,pos){
				if(pos.length>0){
				//calculate marker string for map
				var labels=['A','B','C','D','E'];
				var markerString = "";
				var count=0;
				for(position of pos){
					markerString+="&markers=color:blue%7Clabel:"+labels[count%labels.length]+"%7C"+position.lat+","+position.long
					count+=1;
				}
				console.log(markerString)
				res.render('showBike', {username:username, bikeName:bikeName, positions:pos, markerString:markerString})
				}
				else{
					res.redirect('/');
				}
			});
		});


});

module.exports = router;