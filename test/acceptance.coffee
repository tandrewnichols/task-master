cp = require 'child_process'
fs = require 'fs'

describe 'Acceptance test', ->
  afterEach (done) -> cp.exec 'rm -r tasks', done
  afterEach (done) -> cp.exec 'rm Gruntfile.js', done
  Given (done) -> cp.exec 'cp -r tasks ../tasks', { cwd: __dirname, stdio: 'inherit' }, done
  Given (done) -> cp.exec 'cp Gruntfile.js ../Gruntfile.js', { cwd: __dirname, stdio: 'inherit' }, done

  describe 'regular tasks', ->
    When (done) -> cp.exec 'grunt foo', { stdio: 'inherit' }, (err, stdout) =>
      @output = stdout
      done()
    Then ->
      expect(@output).to.contain 'Running "bar" task'
      expect(@output).to.contain 'Done, without errors'
    And ->
      expect(@output).to.contain 'Running "baz" task'
      expect(@output).to.contain 'Done, without errors'
      expect(@output).to.contain 'quux'

  describe 'multi task run with target', ->
    When (done) -> cp.exec 'grunt log:foo', { stdio: 'inherit' }, (err, stdout) =>
      @output = stdout
      done()
    Then ->
      expect(@output).to.contain 'Running "log:foo" task'
      expect(@output).to.contain 'Done, without errors'
