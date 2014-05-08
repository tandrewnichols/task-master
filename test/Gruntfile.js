var taskMaster = require('task-master');

module.exports = function(grunt) {
  taskMaster(grunt);
  grunt.registerTask('baz', function() {
    console.log('data', this.data);
    console.log(this.data.test);
  });
  grunt.registerTask('foo', ['bar', 'baz']);
};
