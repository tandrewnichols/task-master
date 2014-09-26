describe 'task-master', ->
  Given -> @root = process.cwd()
  Given -> @fm = {}
  Given -> @builder = spyObj 'buildOpts', 'buildConfig'
  Given -> @gruntHelper = spyObj 'load', 'init', 'alias'
  Given -> @stubs =
    './builder': @builder
    'file-manifest': @fm
    './grunt': @gruntHelper
  Given -> @stubs["#{@root}/package"] = 'pkg'

  Given -> @subject = sandbox '../lib/task-master', @stubs
  Given -> @grunt = spyObj 'initConfig'
  Given -> @options = {}
  Given -> @builder.buildOpts.withArgs(@root, @options).returns 'options'
  Given -> @builder.buildConfig.withArgs(@root, 'options', @grunt).returns 'config'

  When -> @subject @grunt, @options
  Then -> expect(@gruntHelper.load).to.have.been.calledWith 'pkg', 'options', @grunt
  And -> expect(@gruntHelper.alias).to.have.been.calledWith 'options', @grunt
  And -> expect(@grunt.initConfig).to.have.been.calledWith 'config'
