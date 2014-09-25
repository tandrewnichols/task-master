var _ = require('lodash');
var file = require('./file');
var fs = require('fs');
var glob = require('glob');

/**
 * Gets the options, either passed in or from a file
 * @param {string} root - The project root
 * @param {string|Object} opts - An options object, a file path for opts, or null
 */
exports.build = function(root, opts) {
  // If opts is a string, it represents an options file location
  if (_.isString(opts)) {
    opts = file.get(opts);
    // In the case of a string (e.g. the file was not .js, .coffee
    // .json, or .yml), use an empty object, or merge will blow up
    opts = _.isString(opts) ? {} : opts;
  } else if (!opts) {
    // If no options are passed in, see if there's a canonical opts file
    var files = glob.sync('_taskmaster.opts.{js,coffee,json,yml}', { cwd: root + '/tasks' });
    // If the file exists, get it with file getter;
    // otherwise, use an empty object
    opts = files.length ? file.get(files[0]) : {};
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
    tasks: 'tasks'
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
