var fm = require('file-manifest');
var _ = require('lodash');
var optsBuilder = require('./opts');

module.exports = function(grunt, opts) {
  // Try to load package.json
  var root = _.contains(__dirname, 'node_modules') ? __dirname.split('node_modules')[0] : process.cwd();
  var pkg = require(root + '/package');

  var options = optsBuilder.build(root, opts);
  // Loop over dependencies to find grunt plugins
  if (pkg) {
    _.each(['dependencies', 'devDependencies'], function(key) {
      if (pkg[key] && options[key]) {
        for (var dep in pkg[key]) {
          // If it matches the pattern and is not being excluded OR it is explicitly being included
          if ((options.pattern.test(dep) && options.exclude.indexOf(dep) === -1) || options.include.indexOf(dep) !== -1) {
            grunt.loadNpmTasks(dep);
          }
        }
      }
    });
  }
  // Build a grunt config from the directories in "tasks"
  var config = {};
  config.context = options.context || {};
  _.each(options.tasks, function(dir) {
    config = fm.generate(root + '/' + dir, {
      memo: config,
      patterns: ['**/*.{js,coffee,json,yml}', '!**/_*.*'],
      reducer: function(options, manifest, file) {
        var req = require(file.fullPath);
        var config = _.isFunction(req) ? req(grunt, manifest.context) : req;
        if (config) {
          manifest[file.name] = config;
        }
        return manifest;
      }
    });
  });

  var processedConfig = _.template(JSON.stringify(config), config.context);

  // Initialize grunt config
  grunt.initConfig(JSON.parse(processedConfig));
};
