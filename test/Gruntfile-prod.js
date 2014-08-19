var taskMaster = require('./task-master');

module.exports = function(grunt) {
  taskMaster(grunt, { production: true, dev: false });
  grunt.registerTask('default', ['clean']);
};
