var express = require('express');
var router = express.Router();

/* GET */
router.get('/', function (req, res, next) {
  res.render(req.param('page', 'home'), {
    title: appconfig['webtitle']
  });
});

module.exports = router;