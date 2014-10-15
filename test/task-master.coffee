describe 'task-master', ->
  Given -> @root = process.cwd()
  Given -> @fm = {}
  Given -> @builder = spyObj 'buildOpts', 'buildConfig'
  Given -> @gruntHelper = spyObj 'load', 'init', 'alias'
  Given -> @jit = sinon.stub()
  Given -> @stubs =
    './builder': @builder
    'file-manifest': @fm
    './grunt': @gruntHelper
    'jit-grunt': @jit
  Given -> @stubs["#{@root}/package"] = 'pkg'

  Given -> @subject = sandbox '../lib/task-master', @stubs
  Given -> @grunt = spyObj 'initConfig'

  context 'no jit options', ->
    Given -> @options = {}
    Given -> @builder.buildOpts.withArgs(@root, @options).returns 'options'
    Given -> @builder.buildConfig.withArgs(@root, 'options', @grunt).returns 'config'
    When -> @subject @grunt, @options
    Then -> expect(@jit).to.have.been.calledWith @grunt
    And -> expect(@gruntHelper.alias).to.have.been.calledWith 'options', @grunt
    And -> expect(@grunt.initConfig).to.have.been.calledWith 'config'

  context 'jit options', ->
    Given -> @options = {}
    Given -> @builder.buildOpts.withArgs(@root, @options).returns
      jit:
        foo: 'bar'
    Given -> @builder.buildConfig.withArgs(@root,
      jit:
        foo: 'bar'
    , @grunt).returns 'config'
    When -> @subject @grunt, @options
    Then -> expect(@jit).to.have.been.calledWith @grunt, { foo: 'bar' }
    And -> expect(@gruntHelper.alias).to.have.been.calledWith
      jit:
        foo: 'bar'
    , @grunt
    And -> expect(@grunt.initConfig).to.have.been.calledWith 'config'

  context 'jit is false', ->
    Given -> @options = {}
    Given -> @builder.buildOpts.withArgs(@root, @options).returns
      jit: false
    Given -> @builder.buildConfig.withArgs(@root, { jit: false }, @grunt).returns 'config'
    When -> @subject @grunt, @options
    Then -> expect(@jit.called).to.be.false()
    And -> expect(@gruntHelper.load).to.have.been.calledWith 'pkg', { jit: false }, @grunt
    And -> expect(@gruntHelper.alias).to.have.been.calledWith { jit: false }, @grunt
    And -> expect(@grunt.initConfig).to.have.been.calledWith 'config'
