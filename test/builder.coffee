describe 'opts', ->
  Given -> @file = spyObj 'get'
  Given -> @glob = spyObj 'sync'
  Given -> @fm = spyObj 'generate'
  Given -> @subject = sandbox '../lib/builder',
    './file': @file
    glob: @glob
    'file-manifest': @fm

  describe '.buildOpts', ->
    afterEach -> @subject.merge.restore()
    Given -> sinon.stub @subject, 'merge'
    context 'opts is an object', ->
      Given -> @opts =
        foo: 'bar'
      When -> @subject.buildOpts '/root', @opts
      Then -> expect(@subject.merge).to.have.been.calledWith foo: 'bar'

    context 'opts is null', ->
      context 'canonical opts file does not exist', ->
        Given -> @glob.sync.withArgs('_taskmaster.opts.{js,coffee,json,yml}', { cwd: '/root/tasks' }).returns []
        When -> @subject.buildOpts '/root', null
        Then -> expect(@subject.merge).to.have.been.calledWith {}

      context 'canonical opts file exists', ->
        Given -> @glob.sync.withArgs('_taskmaster.opts.{js,coffee,json,yml}', { cwd: '/root/tasks' }).returns ['foo.bar']
        Given -> @file.get.withArgs('foo.bar').returns foo: 'bar'
        When -> @subject.buildOpts '/root', null
        Then -> expect(@subject.merge).to.have.been.calledWith foo: 'bar'

    context 'opts is a string', ->
      context 'returned content is a string', ->
        Given -> @file.get.withArgs('blah.js').returns 'lorem ibsum etc'
        When -> @subject.buildOpts '/root', 'blah.js'
        Then -> expect(@subject.merge).to.have.been.calledWith {}

      context 'returned content is an object', ->
        Given -> @file.get.withArgs('blah.js').returns foo: 'bar'
        When -> @subject.buildOpts '/root', 'blah.js'
        Then -> expect(@subject.merge).to.have.been.calledWith foo: 'bar'

    context 'opts.context is a string', ->
      Given -> @opts =
        context: 'blah.js'
      Given -> @file.get.withArgs('blah.js').returns 'lorem ibsum etc'
      When -> @subject.buildOpts '/root', @opts
      Then -> expect(@subject.merge).to.have.been.calledWith
        context: 'lorem ibsum etc'

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
      Given -> @file.get.withArgs('/root/fruit.js', @grunt, { foo: 'bar' }).returns 'banana'
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
