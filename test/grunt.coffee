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
      optionalDependencies:
        'grunt-hello': 'world'
      peerDependencies:
        'grunt-blah': 'blah'

    context 'no include or exclude', ->
      Given -> @grunt = spyObj 'loadNpmTasks'
      Given -> @options =
        dependencies: true
        devDependencies: true
        peerDependencies: true
        pattern: /^grunt-/
        include: []
        exclude: []
      When -> @subject.load @pkg, @options, @grunt
      Then -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-foo'
      And -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-baz'
      And -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-blah'
      And -> expect(@grunt.loadNpmTasks.calledWith('grunt-hello')).to.be.false()

  describe '.alias', ->
    Given -> @options =
      alias:
        foo: ['a', 'b', 'c']
        bar: ['d:e']
    Given -> @grunt = spyObj 'registerTask'
    When -> @subject.alias @options, @grunt
    Then -> expect(@grunt.registerTask).to.have.been.calledWith 'foo', ['a', 'b', 'c']
    And -> expect(@grunt.registerTask).to.have.been.calledWith 'bar', ['d:e']
