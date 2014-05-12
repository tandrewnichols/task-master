module.exports = function(grunt) {
  grunt.registerTask('bar', function() {
    grunt.log.writeln(grunt.config('bar').msg);
  });
  return {
    msg: 'Did some bar stuff'
  };
};
