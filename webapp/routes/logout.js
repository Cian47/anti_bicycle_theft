var express = require('express');
var router = express.Router();

router.get('/', function(req, res){
	req.loginCookie.reset();
	res.redirect('/login');
})

module.exports = router;