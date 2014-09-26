describe 'grunt', ->
  Given -> @subject = require '../lib/grunt'

  describe '.load', ->
    Given -> @pkg =
      dependencies:
        'grunt-foo': 'foo'
        bar: 'bar'
      devDependencies:
        quux: 'quux'
        'grunt-baz': 'baz'

    context 'no include or exclude', ->
      Given -> @grunt = spyObj 'loadNpmTasks'
      Given -> @options =
        dependencies: true
        devDependencies: true
        pattern: /^grunt-/
        include: []
        exclude: []
      When -> @subject.load @pkg, @options, @grunt
      Then -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-foo'
      And -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-baz'

  describe '.alias', ->
    Given -> @options =
      alias:
        foo: ['a', 'b', 'c']
        bar: ['d:e']
    Given -> @grunt = spyObj 'registerTask'
    When -> @subject.alias @options, @grunt
    Then -> expect(@grunt.registerTask).to.have.been.calledWith 'foo', ['a', 'b', 'c']
    And -> expect(@grunt.registerTask).to.have.been.calledWith 'bar', ['d:e']

  describe '.init', ->
    Given -> @grunt = spyObj 'initConfig'
    Given -> @config =
      context:
        foo: 'bar'
        baz:
          quux: 'something'
      hello: 'world'
      '<%= foo %>': '<%= baz.quux %>'
    When -> @subject.init @config, @grunt
    Then -> expect(@grunt.initConfig).to.have.been.calledWith
      context:
        foo: 'bar'
        baz:
          quux: 'something'
      hello: 'world'
      bar: 'something'
