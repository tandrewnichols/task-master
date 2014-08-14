cp = require 'child_process'

describe 'Acceptance test', ->
  describe 'existing task', ->
    When (done) -> cp.exec 'grunt --gruntfile test/Gruntfile.js --base ./', (err, @output) =>
      # Comment in to debug
      #console.log @output
      done()
    Then ->
      expect(@output).to.contain('Running "jshint:default" (jshint) task') and
      expect(@output).to.contain('task-master.js') and
      expect(@output).to.contain('18 |') and
      expect(@output).to.contain("Expected '{' and instead saw 'grunt'") and
      expect(@output).to.contain('27 |') and
      expect(@output).to.contain("Expected '{' and instead saw 'manifest'") and
      expect(@output).to.contain('2 errors in 1 file') and
      expect(@output).to.contain('Warning: Task "jshint:default" failed.') and
      expect(@output).to.contain 'Aborted due to warnings'

  describe 'regular tasks', ->
    When (done) -> cp.exec 'grunt --gruntfile test/Gruntfile.js --base ./ foo', (err, @output) =>
      # Comment in to debug
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
    When (done) -> cp.exec 'grunt --gruntfile test/Gruntfile.js --base ./ log:foo', (err, @output) =>
      # Comment in to debug
      #console.log @output
      done()
    Then ->
      expect(@output).to.contain('Running "log:foo" (log) task') and
      expect.chain(@output).to.contain('Did some foo stuff') and
      expect(@output).to.contain 'Done, without errors'
