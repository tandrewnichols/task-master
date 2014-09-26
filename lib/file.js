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
    var content = require(file);

    // If the file exports a function, call it
    if (_.isFunction(content)) {
      return content.apply(null, [].slice.call(arguments, 1));
    } else {
      return content;
    }
  // If the file is a yaml file, parse it
  } else if (path.extname(file) === '.yml') {
    return yaml.load(file);
  // If the file is anything else, just return the contents as is
  } else {
    return fs.readFileSync(file, 'utf8');
  }
};

/**
 * Load a file in some predictable ways
 * @param {string} name - Canonical file to load
 * @param {string|Object} value - A string filename to load
 * @param {string} root - The project root
 * @param {Boolean} disallowString - Whether to return a string
 */
exports.load = function(name, value, root, disallowString) {
  if (_.isString(value)) {
    // If it's a string, it represents a file path
    value = exports.get(value); 
    value = disallowString && _.isString(value) ? {} : value;
  } else if (!value) {
    // If it's empty and we have a canonical file matching the name, load that
    var files = glob.sync('_taskmaster.' + name + '.{js,coffee,json,yml}', { cwd: root + '/tasks' });
    value = files.length ? exports.get(files[0]) : {};
  }
  return value;
};
