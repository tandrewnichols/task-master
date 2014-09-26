var _ = require('lodash');

/**
 * Load grunt plugins from node_modules
 * @param {Object} pkg - Package.json contents
 * @param {Object} options - Options
 * @param {Object} grunt - The grunt instance
 */
exports.load = function(pkg, options, grunt) {
  // Loop over dependencies to find grunt plugins
  if (pkg) {
    _.each(['dependencies', 'devDependencies', 'optionalDependencies', 'peerDependencies'], function(key) {
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

/**
 * Load grunt aliases
 * @param {Object} options - Options
 * @param {Object} grunt - The grunt instance
 */
exports.alias = function(options, grunt) {
  _(options.alias || {}).keys().each(function(k) {
    grunt.registerTask(k, options.alias[k]);
  });
};
