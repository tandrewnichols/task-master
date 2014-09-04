module.exports = {
  options: {
    ui: 'mocha-given',
    require: 'coffee-script/register',
  },
  lcov: {
    options: {
      reporter: 'mocha-lcov-reporter',
      instrument: true,
      output: 'coverage/coverage.lcov'
    },
    src: ['test/acceptance.coffee'],
  },
  html: {
    options: {
      reporter: 'html-cov',
      output: 'coverage/coverage.html'
    },
    src: ['test/acceptance.coffee']
  }
};
