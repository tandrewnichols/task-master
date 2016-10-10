module.exports = {
  cover: {
    options: {
      hookRunInContext: true,
      root: 'lib',
      dir: 'coverage',
      x: ['**/node_modules/**'],
      simple: {
        args: ['grunt', 'mochaTest:test']
      }
    }
  }
};
