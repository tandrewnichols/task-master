var _ = require('lodash');

exports.load = function(pkg, options, grunt) {
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
};

exports.alias = function(options, grunt) {

};

exports.init = function(config, grunt) {
  // Interpolate any string interpolation in config object
  var processedConfig = _.template(JSON.stringify(config), config.context);

  // Initialize grunt config
  grunt.initConfig(JSON.parse(processedConfig));
};
