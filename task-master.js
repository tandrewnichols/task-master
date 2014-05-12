var fm = require('file-manifest'),
    _ = require('underscore'),
    path = require('path');

module.exports = function(grunt) {
  return fm.generate(__dirname + '/tasks', function(manifest, file) {
    var req = require(file);
    var name = path.basename(file, path.extname(file));
    var config = typeof req === 'function' ? req(grunt) : req;
    if (config) manifest[name] = config;
    return manifest;
  });
};
