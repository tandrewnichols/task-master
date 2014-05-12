var taskMaster = require('./task-master');

module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.initConfig(taskMaster(grunt));
  grunt.registerTask('baz', function() {
    grunt.log.writeln(grunt.config('baz').msg);
  });
  grunt.registerTask('default', ['jshint']);
  grunt.registerTask('foo', ['bar', 'baz']);
  grunt.registerMultiTask('log', 'log stuff', function() {
    grunt.log.writeln('Did some ' + this.target, ' stuff');
  });
};
