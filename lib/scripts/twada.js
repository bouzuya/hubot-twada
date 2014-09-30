// Description
//   A Hubot script that returns a t_wada.png
//
// Configuration:
//   None
//
// Commands:
//   テスト書いてない - returns a t_wada.png
//
// Author:
//   bouzuya <m@bouzuya.net>
//
module.exports = function(robot) {
  var pattern;
  pattern = /((?:test|テスト)[をは]?(?:[書か]いてい?ない|[書か]きたくない))$/i;
  return robot.hear(pattern, function(res) {
    return res.send("" + res.match[1] + "とかお前それ @t_wada の前でも同じこと言えんの？");
  });
};
