path = require 'path'

describe 'task-master', ->
  Given -> @fm = {}
  Given -> @subject = sandbox '../task-master',
    'file-manifest': @fm
  Given -> @grunt = spyObj 'registerTask', 'registerMultiTask', 'initConfig'
  context 'new task', ->
    Given -> @fooSpy = sinon.stub()
    Given -> @barSpy = sinon.stub()
    Given -> @fm.generate = sinon.stub().returns
      foo: @fooSpy
      bar: @barSpy
    When -> @subject @grunt
    Then -> expect(@fooSpy).to.have.been.calledWith @grunt
    And -> expect(@barSpy).to.have.been.calledWith @grunt

  context 'existing task config', ->
    Given -> @fm.generate = sinon.stub().returns
      foo:
        bar: 'baz'
    When -> @subject @grunt
    Then -> expect(@grunt.initConfig).to.have.been.calledWith
      foo:
        bar: 'baz'
