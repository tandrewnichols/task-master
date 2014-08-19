describe 'task-master', ->
  afterEach -> process.cwd.restore()
  Given -> sinon.stub process, 'cwd'
  Given -> process.cwd.returns '.'
  Given -> @fm = {}
  Given -> @subject = sandbox '../task-master',
    'file-manifest': @fm
    './package':
      devDependencies:
        blah: 'blah'
        foo: 'foo'
        'grunt-foo': 'foo'
        bar: 'bar'
        'grunt-cool-things': 'cool things'
      dependencies:
        'grunt-hello-world': 'hello world'
  Given -> @fm.generate = sinon.stub().returns
    foo:
      msg: 'fooness'
    bar:
      msg: 'barness'
    baz:
      msg: 'bazness'
  Given -> @grunt =
    loadNpmTasks: sinon.stub()
    initConfig: sinon.stub()
  
  context 'devDependencies', ->
    When -> @config = @subject @grunt
    Then -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-foo'
    And -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-cool-things'
    And -> expect(@grunt.initConfig).to.have.been.calledWith
      foo:
        msg: 'fooness'
      bar:
        msg: 'barness'
      baz:
        msg: 'bazness'

  context 'dependencies', ->
    When -> @config = @subject @grunt, { production: true }
    Then -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-hello-world'
    And -> expect(@grunt.initConfig).to.have.been.calledWith
      foo:
        msg: 'fooness'
      bar:
        msg: 'barness'
      baz:
        msg: 'bazness'
