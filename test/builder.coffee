describe 'opts', ->
  Given -> @loader = spyObj 'get', 'load'
  Given -> @fm = spyObj 'generate'
  Given -> @subject = sandbox '../lib/builder',
    './file': @loader
    'file-manifest': @fm

  describe '.buildOpts', ->
    afterEach -> @subject.merge.restore()
    Given -> sinon.stub @subject, 'merge'
    Given -> @opts = {}
    Given -> @loader.load.withArgs('opts', @opts, '/root', true).returns
      opts: true
      context: 'foo'
    Given -> @loader.load.withArgs('context', 'foo', '/root').returns
      context: true
    When -> @subject.buildOpts '/root', @opts
    Then -> expect(@subject.merge).to.have.been.calledWith
      opts: true
      context:
        context: true

  describe '.merge', ->
    context 'no opts passed in', ->
      Given -> @opts = {}
      When -> @options = @subject.merge @opts
      Then -> expect(@options).to.deep.equal
        devDependencies: true
        dependencies: false
        pattern: /^grunt-/
        include: []
        exclude: []
        ignore: []
        tasks: ['tasks']

    context 'opts passed in', ->
      Given -> @opts =
        devDependencies: false
        dependencies: true
        pattern: '^foo-'
        include: 'bar'
        exclude: 'baz'
        ignore: 'quux'
        tasks: 'blah'
      When -> @options = @subject.merge @opts
      Then -> expect(@options).to.deep.equal
        devDependencies: false
        dependencies: true
        pattern: /^foo-/
        include: ['bar']
        exclude: ['baz']
        ignore: ['quux']
        tasks: ['blah']

  describe '.buildConfig', ->
    Given -> @grunt = {}
    context 'with no context and no ignored files', ->
      Given -> @options =
        tasks: ['foo']
      Given -> @fm.generate.withArgs('/root/foo',
        memo:
          context: {}
        patterns: ['**/*.{js,coffee,json,yml}', '!**/_*.*']
        reducer: sinon.match.func
      ).returns foo: 'bar'
      When -> @config = @subject.buildConfig '/root', @options, @grunt
      Then -> expect(@config).to.deep.equal
        foo: 'bar'

    context 'with a context', ->
      Given -> @options =
        tasks: ['foo']
        context:
          foo: 'bar'
      Given -> @fm.generate.withArgs('/root/foo',
        memo:
          context:
            foo: 'bar'
        patterns: ['**/*.{js,coffee,json,yml}', '!**/_*.*']
        reducer: sinon.match.func
      ).returns foo: 'bar'
      When -> @config = @subject.buildConfig '/root', @options, @grunt
      Then -> expect(@config).to.deep.equal
        foo: 'bar'

    context 'with ignored files', ->
      Given -> @options =
        tasks: ['foo']
        ignore: ['baz.js']
      Given -> @fm.generate.withArgs('/root/foo',
        memo:
          context: {}
        patterns: ['**/*.{js,coffee,json,yml}', '!**/_*.*', '!baz.js']
        reducer: sinon.match.func
      ).returns foo: 'bar'
      When -> @config = @subject.buildConfig '/root', @options, @grunt
      Then -> expect(@config).to.deep.equal
        foo: 'bar'

    context 'reduce function', ->
      Given -> @loader.get.withArgs('/root/fruit.js', @grunt, { foo: 'bar' }).returns 'banana'
      Given -> @fm.generate.withArgs('/root/foo',
        memo: {}
        patterns: ['**/*.{js,coffee,json,yml}', '!**/_*.*', '!baz.js']
        reducer: sinon.match.func
      ).returns foo: 'bar'
      When -> @subject.buildConfig '/root', { tasks: ['foo'] }, @grunt
      And -> @func = @fm.generate.getCall(0).args[1].reducer
      And -> @newConf = @func {},
        context:
          foo: 'bar'
      ,
        fullPath: '/root/fruit.js'
        name: 'fruit'
      Then -> expect(@newConf).to.deep.equal
        context:
          foo: 'bar'
        fruit: 'banana'
