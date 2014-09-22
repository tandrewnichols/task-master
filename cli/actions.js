var _ = require('lodash');
var fs = require('fs');

exports.init = function(options) {
  options.space = options.expandtab ? '\t' : options.tabstop;
  options.dependencies = options.dependencies || false;
  fs.readFile(__dirname + '/Gruntfile.js', 'utf8', function(err, file) {
    var gruntfile = _.template(file, options); 
    console.log(gruntfile);
  });
};
