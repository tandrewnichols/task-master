module.exports = function(grunt) {
  grunt.registerTask('foo', 'Foo task', function() {
    console.log(grunt.config('foo.bar'));
  });
  return {
    bar: 'foo was run'
  };
};
