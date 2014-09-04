var fm = require('file-manifest'),
    path = require('path');

module.exports = function(grunt, opts) {
  // Default options
  var options = {
    devDependencies: true,
    dependencies: false,
    pattern: /^grunt-/,
    include: [],
    exclude: [],
    tasks: ['tasks']
  };

  // Merge options
  if (typeof opts === 'string') {
    options.devDependencies = false;
    options[opts] = true;
  } else {
    for (var key in opts) {
      options[key] = opts[key];
    }
  }

  // Make sure pattern is a regex
  if (!(options.pattern instanceof RegExp) {
    options.pattern = new RegExp(options.pattern);
  }

  // Try to load package.json
  var root = __dirname.split('node_modules')[0];
  var pkg;
  try {
    pkg = require(root + '/package');
  } catch (e) {
    console.log('Unable to find package.json');
  }

  // Loop over dependencies to find grunt plugins
  if (pkg) {
    ['dependencies', 'devDependencies'].forEach(function(key) {
      if (pkg[key] && options[key]) {
        for (var dep in pkg[key]) {
          // If it matches the pattern and is not being excluded OR it is explicitly being included
          if ((options.pattern.test(dep) && exclude.indexOf(dep) === -1) || include.indexOf(dep) !== -1) {
            grunt.loadNpmTasks(dep);
          }
        }
      }
    });
  }

  // Build a grunt config from the directories in "tasks"
  var config = {};
  for (var dir in options.tasks) {
    fm.generate(root + '/' + dir, { memo: config, reducer: function(options, manifest, file) {
      var req = require(file.fullPath);
      var config = typeof req === 'function' ? req(grunt) : req;
      if (config) manifest[file.name] = config;
      return manifest;
    }});
  }
  
  // Initialize grunt config
  grunt.initConfig(config);
};
