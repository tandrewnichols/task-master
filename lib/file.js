var _ = require('lodash');
var path = require('path');
var yaml = require('yamljs');
var fs = require('fs');

/**
 * Get file contents in a predictable way
 * @param {string} file - filename of the file to load
 * @param {Function} cb - callback
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
