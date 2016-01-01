var express = require('express');
var clientSessions = require('client-sessions');
var path = require('path');
var logger = require('morgan');
var bodyParser = require('body-parser');


//include routes
var index = require('./routes/index');
var login = require('./routes/login');
var logout = require('./routes/logout');
var register = require('./routes/register');
var bike = require('./routes/bike');


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
app.use('/stylesheets', express.static(path.join(__dirname,'stylesheets')));
app.use('/js', express.static(path.join(__dirname,'js')));

//check all incoming request for login status. Redirect if not logged in.
app.all('*', function(req, res, next){
	//check all incoming request for login status. Redirect if not logged in.
	if(!req.loginCookie.username){
		res.redirect('/login');
	}
	else{
		next();
	};
})
app.use('/', index);
app.use('/login', login);
app.use('/logout', logout);
app.use('/register', register);
app.use('/bike', bike);


app.listen(8080);
