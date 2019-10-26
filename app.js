var createError = require('http-errors');
var express = require('express');
var path = require('path');
var bodyParser = require("body-parser");
var cookieParser = require('cookie-parser');
var logger = require('morgan');
var sassMiddleware = require('node-sass-middleware');

var indexRouter = require('./routes/index');
var usersRouter = require('./routes/users');

var app = express();

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

// load app config
var fs = require('fs')
var appconfig = JSON.parse(fs.readFileSync('appconfig.json'));

// Web3
var contractabi = JSON.parse(fs.readFileSync('contractabi.json'));
var Eth = require('web3-eth');
var eth = new Eth(Eth.givenProvider || appconfig['eth_node']);

var contract = new eth.Contract(contractabi, appconfig['contract_address']);

app.post('/registerstudent',function(req, res){
  var id = req.body.id;
  var fullname = req.body.fullname;
  contract.methods.registerStudent(id, fullname).send({from: appconfig['manager_address']}).on('error', function(error){
    res.end(error);
  });
  res.end("Done!");
});

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(sassMiddleware({
  src: path.join(__dirname, 'public'),
  dest: path.join(__dirname, 'public'),
  indentedSyntax: true, // true = .sass and false = .scss
  sourceMap: true
}));
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', indexRouter);
app.use('/users', usersRouter);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

module.exports = app;
