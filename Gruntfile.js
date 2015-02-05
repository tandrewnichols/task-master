// Yes, I could just require './lib/task-master', but I've
// previously accidentally published this with "main" pointing
// to the wrong thing, so this is a safeguard against that. It's
// similar to what you get when you install task-master and
// require it.
var pkg = require('./package');
var taskMaster = require(pkg.main);
module.exports = function(grunt) {
  taskMaster(grunt, {
    jit: {
      mochacov: 'grunt-mocha-cov'
    }
  });
};
