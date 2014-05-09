var taskMaster = require('./task-master');

module.exports = function(grunt) {
  taskMaster(grunt);
  grunt.registerTask('baz', function() {
    console.log(grunt.config.get());
  });
  grunt.registerTask('foo', ['bar', 'baz']);
};
