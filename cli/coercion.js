exports.collect = function(arg, memo) {
  memo = memo || [];
  return memo.concat(arg.split(','));
};

exports.toRegex = function(regex) {
  return regex instanceof RegExp ? regex : new RegExp(regex);
};

exports.toSpacing = function(num) {
  var str = '';
  for (var i = 0; i < num; i++) {
    str += ' '; 
  }
  return str;
};
