child = require 'child_process'

describe.only 'acceptance', ->
  Given -> @output = ''

  context 'task function', ->
    When (done) ->
      grunt = child.spawn 'grunt', ['foo'], { cwd: "#{__dirname}/fixtures/defaults" }
      grunt.stdout.on 'data', (output) =>
        @output += output.toString()
      grunt.on 'close', done
    And -> console.log @output # Comment in to debug
    Then -> expect(@output).to.contain 'foo was run'
