var _ = require('lodash');
_.mixin(require('safe-obj'));
var builder = require('./builder');
var gruntHelper = require('./grunt');
var jit = require('jit-grunt');

module.exports = function(grunt, opts) {
  // Try to load package.json, but don't catch errors.
  // If we can't find the package, we might as well not continue.
  var root = _.contains(__dirname, 'node_modules') ? __dirname.split('node_modules')[0] : process.cwd();
  var pkg = require(root + '/package');

  // Merge default options with passed in options
  var options = builder.buildOpts(root, opts);

  // Load grunt tasks from package.json
  if (options.jit === false) {
    gruntHelper.load(pkg, options, grunt); 
  } else if (options.jit) {
    jit(grunt, options.jit);
  } else {
    jit(grunt);
  }

  // Build a grunt config from the directories in "tasks"
  var config = builder.buildConfig(root, options, grunt);
  
  // Grab grunt aliases
  gruntHelper.alias(options, grunt);

  // Initialize grunt config
  grunt.initConfig(config);
};
