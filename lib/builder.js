var _ = require('lodash');
var loader = require('./file');
var glob = require('glob');
var fm = require('file-manifest');

/**
 * Gets the options, either passed in or from a file
 * @param {string} root - The project root
 * @param {string|Object} opts - An options object, a file path for opts, or null
 */
exports.buildOpts = function(root, opts) {
  // If opts is a string, it represents an options file location
  if (_.isString(opts)) {
    opts = loader.get(opts);
    // In the case of a string (e.g. the file was not .js, .coffee
    // .json, or .yml), use an empty object, or merge will blow up
    opts = _.isString(opts) ? {} : opts;
  } else if (!opts) {
    // If no options are passed in, see if there's a canonical opts file
    var files = glob.sync('_taskmaster.opts.{js,coffee,json,yml}', { cwd: root + '/tasks' });
    // If the file exists, get it with file getter;
    // otherwise, use an empty object
    opts = files.length ? loader.get(files[0]) : {};
  }

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
