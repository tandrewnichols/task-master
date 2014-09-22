var init = require('./init');
var _ = require('lodash');

exports.init = function(options) {
  var s = options.expandTab ? '\t' : options.tabstop;
  var gruntfile = ['var tm = require(\'task-master\');', '', 'module.exports = function(grunt) {'];
  var tmCall = ['tm(grunt);'];
  if (!options.devDependencies || _.anyOf(options, 'dependencies', 'pattern', 'include', 'exclude', 'taskDir')) {
    tmCall = [s + 'tm(grunt, {'];
    if (!options.devDependencies) {
      tmCall.push(s + s + init.map(options.devDependencies).devDependencies);
    }
    _.each(['dependencies', 'pattern', 'include', 'exclude', 'taskDir'], function(key, i, arr) {
      // TODO: does not work for empty arrays
      if (options[key]) {
        var comma = i === arr.length - 1 ? '' : ',';
        tmCall.push(s + s + init.map(key)[key] + comma);
      }
    });
  }
  gruntfile = gruntfile.concat(tmCall);
  gruntfile.push(s + '});');
  gruntfile.push('};'); 
  console.log(gruntfile);
};
