var fm = require('file-manifest'),
    path = require('path');

module.exports = function(grunt) {

  // Try to get the package.json of the project using this module
  var root = process.cwd();
  var pkg;
  try {
    pkg = require(root + '/package');
  } catch (e) {
    console.log('Unable to find package.json');
  }

  // Get all npm grunt related modules
  var tasks = [];
  if (pkg && pkg.devDependencies) {
    for (var dep in pkg.devDependencies) {
      if (dep.indexOf('grunt-') === 0) tasks.push(dep);
    }
  }

  // Load those tasks
  if (tasks.length) grunt.loadNpmTasks.apply(grunt, tasks);

  // Build a grunt config from the tasks directory
  var config = fm.generate(root + '/tasks', function(manifest, file) {
    var req = require(file);
    var name = path.basename(file, path.extname(file));
    var config = typeof req === 'function' ? req(grunt) : req;
    if (config) manifest[name] = config;
    return manifest;
  });
  
  // Initialize grunt config
  grunt.initConfig(config);
};
