var fm = require('file-manifest'),
    path = require('path');

module.exports = function(grunt) {

  // Get all npm grunt related modules
  var pkg = require('./package');
  var tasks = [];
  if (pkg.devDependencies) {
    for (var dep in pkg.devDependencies) {
      if (dep.indexOf('grunt-') === 0) tasks.push(dep);
    }
  }

  // Load those tasks
  if (tasks.length) grunt.loadNpmTasks.apply(grunt, tasks);

  // Build a grunt config from the tasks directory
  var config = fm.generate(__dirname + '/tasks', function(manifest, file) {
    var req = require(file);
    var name = path.basename(file, path.extname(file));
    var config = typeof req === 'function' ? req(grunt) : req;
    if (config) manifest[name] = config;
    return manifest;
  });
  
  // Initialize grunt config
  grunt.initConfig(config);
};
