var _ = require('lodash');
var path = require('path');
var yaml = require('yamljs');
var fs = require('fs');
var glob = require('glob');

/**
 * Get file contents in a predictable way
 * @param {string} file - Filename of the file to load
 */
exports.get = function(file) {
  // If the file is a type natively recognized by node, just require it
  if (_.contains(['.js', '.coffee', '.json'], path.extname(file))) {
    var content = {};
    try {
      content = require(file);
    } catch (e) {
      return {};
    }

    // If the file exports a function, call it
    if (_.isFunction(content)) {
      return content.apply(null, [].slice.call(arguments, 1));
    } else {
      return content;
    }
  // If the file is a yaml file, parse it
  } else if (path.extname(file) === '.yml') {
    return yaml.load(file);
  // If the file is anything else, return an empty object
  // since we won't know what to do with it
  } else {
    return {};
  }
};

/**
 * Get files in all dirs matching a pattern
 * and merge their results
 * @param {string} pattern - A globstart pattern to match
 * @param {string} root - The project root
 * @param {Array} dirs - A list of directories to look in
 */
exports.getAll = function(patterns, root, dirs) {
  return _.reduce(dirs, function(manifest, dir) {
    // Get all matching files
    var files = _.reduce(patterns, function(inner, pattern) {
      return inner.concat(glob.sync(pattern, { cwd: root + '/' + dir }));
    }, []);

    // Combine the exports of all those files
    return _.reduce(files, function(manifest, file) {
      return _.extend({}, manifest, exports.get(root + '/' + dir + '/' + file));
    }, {});
  }, {});
};

/**
 * Load a file in some predictable ways
 * @param {string} name - Canonical file to load
 * @param {string|Object} value - A string filename to load
 * @param {string} root - The project root
 * @param {Array} dirs - Directories in which plugins are located
 */
exports.load = function(name, value, root, dirs) {
  // Assure that value is an array with a string, rather than a single string
  value = _.isString(value) ? [value] : value;
  var content = _.isArray(value) ? exports.getAll(value, root, dirs) : {};

  // Try to load the canonical file no matter what
  var canonical = exports.getAll(['_taskmaster.' + name + '*.{js,coffee,json,yml}'], root, dirs);

  // Merge everything we got into one big mess
  return _.extend({}, (_.isPlainObject(value) ? value : {}), canonical, content);
};
