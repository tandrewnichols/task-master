exports.map = function(val) {
  return {
    dependencies: 'dependencies: true',
    devDependencies: 'devDependencies: false',
    pattern: 'pattern: ' + val,
    include: 'include: [' + val.join(', ') + ']',
    exclude: 'exclude: [' + val.join(', ') + ']',
    taskDir: 'tasks: [' + val.join(', ') + ']'
  };
};
