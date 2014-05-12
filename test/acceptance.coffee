cp = require 'child_process'

describe 'Acceptance test', ->
  afterEach (done) -> cp.exec 'rm -r tasks', done
  afterEach (done) -> cp.exec 'rm Gruntfile.js', done
  Given (done) -> cp.exec 'cp -r tasks ../tasks', { cwd: __dirname, stdio: 'inherit' }, done
  Given (done) -> cp.exec 'cp Gruntfile.js ../Gruntfile.js', { cwd: __dirname, stdio: 'inherit' }, done

  describe 'existing task', ->
    When (done) -> cp.exec 'grunt', (err, stdout) =>
      @output = stdout
      #console.log @output
      done()
    Then ->
      expect(@output).to.contain('Running "jshint:default" (jshint) task') and
      expect(@output).to.contain('task-master.js') and
      expect(@output).to.contain('9 |') and
      expect(@output).to.contain("Expected '{' and instead saw 'manifest'") and
      expect(@output).to.contain('1 error in 1 file') and
      expect(@output).to.contain('Warning: Task "jshint:default" failed.') and
      expect(@output).to.contain 'Aborted due to warnings'

  describe 'regular tasks', ->
    When (done) -> cp.exec 'grunt foo', (err, stdout) =>
      @output = stdout
      done()
    Then ->
      expect(@output).to.contain('Running "bar" task') and
      expect(@output).to.contain('Did some bar stuff') and
      expect(@output).to.contain('Done, without errors') and
      expect(@output).to.contain('Running "baz" task') and
      expect(@output).to.contain('Did some baz stuff') and
      expect(@output).to.contain 'Done, without errors'

  describe 'multi task run with target', ->
    When (done) -> cp.exec 'grunt log:foo', (err, stdout) =>
      @output = stdout
      done()
    Then ->
      expect(@output).to.contain('Running "log:foo" (log) task') and
      expect.chain(@output).to.contain('Did some foo stuff') and
      expect(@output).to.contain 'Done, without errors'
