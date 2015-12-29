var express = require('express');
var clientSessions = require('client-sessions');
var path = require('path');
var logger = require('morgan');
var bodyParser = require('body-parser');



var login = require('./routes/login')
var register = require('./routes/register')

var app = express();

app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');
app.use(logger('dev'));

app.use(clientSessions({
  cookieName: 'loginCookie',
  secret: 'hardCodedSecret',
  duration: 1000*60*60*48,
  activeDuration: 1000*60*5
}));

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

app.use('/login', login);
app.use('/register', register);

app.get('/', function(req, res){
	console.log(req.loginCookie);
	if(!req.loginCookie.username){
		res.redirect('/login');
	}
	else{
		res.end('you are logged in')
	}
}).listen(8080);
