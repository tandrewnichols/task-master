describe 'opts', ->
  Given -> @loader = spyObj 'get', 'load'
  Given -> @fm = spyObj 'generate'
  Given -> @subject = sandbox '../lib/builder',
    './loader': @loader
    'file-manifest': @fm

  describe '.buildOpts', ->
    afterEach -> @subject.merge.restore()
    Given -> sinon.stub @subject, 'merge'
    Given -> @opts = {}
    Given -> @loader.load.withArgs('opts', @opts, '/root', ['tasks'], true).returns
      opts: true
      context: 'foo'
      alias: 'bar'
    Given -> @loader.load.withArgs('context', 'foo', '/root', ['tasks']).returns
      context: true
    Given -> @loader.load.withArgs('alias', 'bar', '/root', ['tasks']).returns
      alias: true
    When -> @subject.buildOpts '/root', @opts
    Then -> expect(@subject.merge).to.have.been.calledWith
      opts: true
      context:
        context: true
      alias:
        alias: true

  describe '.merge', ->
    context 'no opts passed in', ->
      Given -> @opts = {}
      When -> @options = @subject.merge @opts
      Then -> expect(@options).to.deep.equal
        devDependencies: true
        dependencies: false
        optionalDependencies: false
        peerDependencies: false
        pattern: /^grunt-/
        include: []
        exclude: []
        ignore: []
        tasks: ['tasks']

    context 'opts passed in', ->
      Given -> @opts =
        devDependencies: false
        dependencies: true
        optionalDependencies: true
        peerDependencies: true
        pattern: '^foo-'
        include: 'bar'
        exclude: 'baz'
        ignore: 'quux'
        tasks: 'blah'
      When -> @options = @subject.merge @opts
      Then -> expect(@options).to.deep.equal
        devDependencies: false
        dependencies: true
        optionalDependencies: true
        peerDependencies: true
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
        memo: {}
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
        memo: {}
        patterns: ['**/*.{js,coffee,json,yml}', '!**/_*.*', '!baz.js']
        reducer: sinon.match.func
      ).returns foo: 'bar'
      When -> @config = @subject.buildConfig '/root', @options, @grunt
      Then -> expect(@config).to.deep.equal
        foo: 'bar'

    context 'reduce function', ->
      context 'no override', ->
        Given -> @loader.get.withArgs('/root/fruit.js', @grunt, { foo: 'bar' }).returns 'banana'
        Given -> @loader.load.withArgs('override.fruit', null, '/root', ['foo']).returns {}
        Given -> @fm.generate.withArgs('/root/foo',
          memo: {}
          patterns: ['**/*.{js,coffee,json,yml}', '!**/_*.*', '!baz.js']
          reducer: sinon.match.func
        ).returns foo: 'bar'
        When -> @subject.buildConfig '/root', { tasks: ['foo'] }, @grunt
        And -> @func = @fm.generate.getCall(0).args[1].reducer
        And -> @newConf = @func {},
          foo: 'bar'
        ,
          fullPath: '/root/fruit.js'
          name: 'fruit'
        Then -> expect(@newConf).to.deep.equal
          foo: 'bar'
          fruit: 'banana'

      context 'with overrides', ->
        Given -> @loader.get.withArgs('/root/fruit.js', @grunt, { foo: 'bar' }).returns 'banana'
        Given -> @loader.load.withArgs('override.fruit', null, '/root', ['foo']).returns 'apple'
        Given -> @fm.generate.withArgs('/root/foo',
          memo: {}
          patterns: ['**/*.{js,coffee,json,yml}', '!**/_*.*', '!baz.js']
          reducer: sinon.match.func
        ).returns foo: 'bar'
        When -> @subject.buildConfig '/root', { tasks: ['foo'] }, @grunt
        And -> @func = @fm.generate.getCall(0).args[1].reducer
        And -> @newConf = @func {},
          foo: 'bar'
        ,
          fullPath: '/root/fruit.js'
          name: 'fruit'
        Then -> expect(@newConf).to.deep.equal
          foo: 'bar'
          fruit: 'apple'

      context 'with <task>.<target>.js style file', ->
        Given -> @loader.get.withArgs('/root/fruit.banana.js', @grunt, { foo: 'bar' }).returns 'yellow'
        Given -> @loader.load.withArgs('override.fruit.banana', null, '/root', ['foo']).returns {}
        Given -> @fm.generate.withArgs('/root/foo',
          memo: {}
          patterns: ['**/*.{js,coffee,json,yml}', '!**/_*.*', '!baz.js']
          reducer: sinon.match.func
        ).returns foo: 'bar'
        When -> @subject.buildConfig '/root', { tasks: ['foo'] }, @grunt
        And -> @func = @fm.generate.getCall(0).args[1].reducer
        And -> @newConf = @func {},
          foo: 'bar'
        ,
          fullPath: '/root/fruit.banana.js'
          name: 'fruit.banana'
        Then -> expect(@newConf).to.deep.equal
          foo: 'bar'
          fruit:
            banana: 'yellow'
            
      context 'with <task>.<target>.js style file plus base file', ->
        Given -> @loader.get.withArgs('/root/fruit.banana.js', @grunt, {}).returns 'yellow'
        Given -> @loader.get.withArgs('/root/fruit.js', @grunt,
          fruit:
            banana: 'yellow'
        ).returns
          color: 'yellow'
        Given -> @loader.load.withArgs('override.fruit.banana', null, '/root', ['foo']).returns {}
        Given -> @loader.load.withArgs('override.fruit', null, '/root', ['foo']).returns {}
        Given -> @fm.generate.withArgs('/root/foo',
          memo: {}
          patterns: ['**/*.{js,coffee,json,yml}', '!**/_*.*', '!baz.js']
          reducer: sinon.match.func
        ).returns foo: 'bar'
        When -> @subject.buildConfig '/root', { tasks: ['foo'] }, @grunt
        And -> @func = @fm.generate.getCall(0).args[1].reducer
        And -> @newConf = @func {}, {},
          fullPath: '/root/fruit.banana.js'
          name: 'fruit.banana'
        And -> console.log @newConf
        And -> @newerConf = @func {}, @newConf,
          fullPath: '/root/fruit.js'
          name: 'fruit'
        Then -> expect(@newerConf).to.deep.equal
          fruit:
            banana: 'yellow'
            color: 'yellow'
