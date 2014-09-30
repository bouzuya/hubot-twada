var path = require('path');

module.exports = function (robot) {
  robot.load(path.join(__dirname, '/lib/scripts/'));
};
