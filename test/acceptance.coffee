fs = require('fs-extra')
child = require('child_process')

cp = (file, cb) ->
  fs.copy "#{__dirname}/fixtures/#{file}.js", "#{__dirname}/Gruntfile.js", (err) ->
    if err
      cb err
    else
      fs.copy "#{__dirname}/fixtures/#{file}", "#{__dirname}/tasks", cb

describe.only 'acceptance', ->
  afterEach (done) -> fs.remove "#{__dirname}/Gruntfile.js", done
  afterEach (done) -> fs.remove "#{__dirname}/tasks", done
  Given -> @output = ''

  context 'no options', ->
    Given (done) -> cp "no-opts", done
    When (done) ->
      grunt = child.spawn 'grunt', ['foo'], { cwd: __dirname }
      grunt.stdout.on 'data', (output) =>
        @output += output.toString()
      grunt.on 'close', done
    And -> console.log @output # Comment in to debug
    Then -> expect(@output).to.contain 'foo was run'
