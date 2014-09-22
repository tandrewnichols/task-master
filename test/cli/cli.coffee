_ = require 'lodash'

describe 'cli', ->
  Given -> @actions = spyObj 'init'
  Given -> @subject = sandbox '../cli.js',
    './cli/actions': @actions

  describe 'name', ->
    Then -> expect(@subject.name).to.equal 'task-master'

  describe 'version', ->
    Then -> expect(@subject.version()).to.equal require('../../package').version

  describe 'init', ->
    context 'description and options', ->
      Given -> @cmd = _.findWhere @subject.commands, { _name: 'init' }
      Given -> @flags = _.pluck @cmd.options, 'flags'
      Given -> @descriptions = _.pluck @cmd.options, 'description'
      Then -> expect(@cmd._description).to.equal 'Create a gruntfile that use task-master'
      And -> expect(@flags).to.deep.equal [
        '-d, --dependencies',
        '-D, --no-dev-dependencies',
        '-p, --pattern <pattern>',
        '-i, --include <plugin>',
        '-e, --exclude <plugin>',
        '-t, --task-dir <path>',
        '-c, --coffee',
        '--tabstop <number>',
        '--no-expand-tab'
      ]
      And -> expect(@descriptions).to.deep.equal [
        'Add grunt plugins from production dependencies',
        'Do not add grunt plugins from development dependencies',
        'Pattern for matching grunt plugins',
        'Plugins to include',
        'Plugins to ignore',
        'Directory/directories containing grunt tasks or configuration',
        'Generate Gruntfile.coffee instead of Gruntfile.js',
        'Set the indentation level for generated files',
        'Use tabs instead of spaces'
      ]

    
    context 'register calls mk.register', ->
      When -> @subject.parse ['node', 'task', 'init']
      Then -> expect(@actions.init).to.have.been.called
