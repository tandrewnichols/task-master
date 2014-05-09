var fm = require('file-manifest'),
    _ = require('underscore');

module.exports = function(grunt) {
  var tasks = fm.generate(__dirname + '/tasks', function(manifest, file) {
    manifest[file.replace(__dirname + '/tasks/', '')] = require(file);
    return manifest;
  });
  _.chain(tasks).keys().each(function(task) {
    if (typeof tasks[task] === 'function') {
      tasks[task](grunt);
    } else {
      var obj = {};
      obj[task] = tasks[task];
      grunt.initConfig(obj);
    }
  });
};
