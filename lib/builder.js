var _ = require('lodash');
var loader = require('./file');
var fm = require('file-manifest');

/**
 * Gets the options, either passed in or from a file
 * @param {string} root - The project root
 * @param {string|Object} opts - An options object, a file path for opts, or null
 */
exports.buildOpts = function(root, opts) {
  // Load options etc. from files if they are strings
  opts = loader.load('opts', opts, root, true); 
  opts.context = loader.load('context', opts.context, root);
  opts.alias = loader.load('alias', opts.alias, root);

  return exports.merge(opts);
};

/**
 * Merge the options object with the defaults
 * @param {Object} opts - The option overrides
 */
exports.merge = function(opts) {
  // Merge efault options
  var options = _.extend({}, {
    devDependencies: true,
    dependencies: false,
    pattern: /^grunt-/,
    include: [],
    exclude: [],
    ignore: [],
    tasks: ['tasks']
  }, opts);

  // Make sure pattern is a regex
  if (!_.isRegExp(options.pattern)) {
    options.pattern = new RegExp(options.pattern);
  }

  // Make string options into arrays
  _.each(['tasks', 'include', 'exclude', 'ignore'], function(key) {
    options[key] = _.isArray(options[key]) ? options[key] : [options[key]];
  });

  return options;
};

/**
 * Build the grunt configuration
 * @param {string} root - The project root
 * @param {Object} options - Task-master options
 * @param {Object} grunt - Grunt
 */
exports.buildConfig = function(root, options, grunt) {
  var config = {};
  config.context = options.context || {};

  // Add any ignored files to the file-manifest pattern
  var patterns = ['**/*.{js,coffee,json,yml}', '!**/_*.*'];
  _.each(options.ignore, function(file) {
    patterns.push('!' + file);
  });

  // Iterate over each task directory and build out
  // the grunt config using the results
  _.each(options.tasks, function(dir) {
    config = fm.generate(root + '/' + dir, {
      memo: config,
      patterns: patterns,
      reducer: function(opts, manifest, file) {
        var contents = loader.get(file.fullPath, grunt, manifest.context);
        if (contents) {
          manifest[file.name] = contents;
        }
        return manifest;
      }
    });
  });

  return config;
};
