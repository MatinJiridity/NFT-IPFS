var express = require('express');
var app = express();
app.use(express.static('src'));
app.use(express.static('../contract/build/contracts'));
app.get('/', function (req, res) {
  res.render('index.html');
});
app.listen(5001, function () {
  console.log('Your Dapp listening on port 5001!');
});