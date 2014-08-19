cp = require 'child_process'
fs = require 'fs'

describe 'Acceptance test', ->
  describe 'devDependencies', ->
    afterEach (done) -> cp.exec 'rm -r tasks', done
    afterEach (done) -> cp.exec 'rm Gruntfile.js', done
    Given (done) -> cp.exec 'cp -r tasks ../tasks', { cwd: __dirname, stdio: 'inherit' }, done
    Given (done) -> cp.exec 'cp Gruntfile.js ../Gruntfile.js', { cwd: __dirname, stdio: 'inherit' }, done

    describe 'existing task', ->
      When (done) -> cp.exec 'grunt', (err, stdout) =>
        @output = stdout
        # Comment in to debug
        #console.log @output
        done()
      Then ->
        expect(@output).to.contain('Running "jshint:default" (jshint) task') and
        expect(@output).to.contain('task-master.js') and
        expect(@output).to.match(/\d+ errors in \d+ files?/) and
        expect(@output).to.contain('Warning: Task "jshint:default" failed.') and
        expect(@output).to.contain 'Aborted due to warnings'

    describe 'regular tasks', ->
      When (done) -> cp.exec 'grunt foo', (err, stdout) =>
        @output = stdout
        #console.log @output
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
        #console.log @output
        done()
      Then ->
        expect(@output).to.contain('Running "log:foo" (log) task') and
        expect.chain(@output).to.contain('Did some foo stuff') and
        expect(@output).to.contain 'Done, without errors'

  describe 'dependencies', ->
    afterEach (done) -> cp.exec 'rm -r tasks', done
    afterEach (done) -> cp.exec 'rm Gruntfile.js', done
    Given (done) -> cp.exec 'cp -r tasks ../tasks', { cwd: __dirname, stdio: 'inherit' }, done
    Given (done) -> cp.exec 'cp Gruntfile-prod.js ../Gruntfile.js', { cwd: __dirname, stdio: 'inherit' }, done
    Given (done) -> fs.mkdir 'foo', done
    describe 'existing task', ->
      When (done) -> cp.exec 'grunt', (err, stdout) =>
        @output = stdout
        # Comment in to debug
        #console.log @output
        done()
      Then ->
        expect(@output).to.contain('Running "clean:0" (clean) task')
