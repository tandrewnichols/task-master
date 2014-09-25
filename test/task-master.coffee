describe 'task-master', ->
  Given -> @root = process.cwd()
  Given -> @fm = {}
  Given -> @stubs =
    'file-manifest': @fm
    baz:
      content: 'baz'
      '@noCallThru': true
    quux: (grunt, conf) ->
      return "#{conf.foo} quux"
  Given -> @stubs.quux['@noCallThru'] = true
  Given -> @stubs["#{@root}/package"] =
    devDependencies:
      blah: 'blah'
      foo: 'foo'
      'grunt-foo': 'foo'
      bar: 'bar'
      'grunt-cool-things': 'cool things'
      'not-grunt-nope': 'not grunt'
      'not-grunt-nada': 'also not grunt'
    dependencies:
      'grunt-hello-world': 'hello world'

  Given -> @subject = sandbox '../lib/task-master', @stubs
  Given -> @fm.generate = sinon.stub()
  Given -> @fm.generate.withArgs("#{@root}/tasks",
    memo:
      context: {}
    patterns: ['**/*.{js,coffee,json,yml}', '!**/_*.*']
    reducer: sinon.match.func
  ).returns
    context: {}
    foo:
      msg: 'fooness'
    bar:
      msg: 'barness'
    baz:
      msg: 'bazness'
  Given -> @fm.generate.withArgs("#{@root}/toppings",
    memo: sinon.match.object
    patterns: ['**/*.{js,coffee,json,yml}', '!**/_*.*']
    reducer: sinon.match.func
  ).returns
    context: {}
    hamburger:
      toppings: ['cheese', 'lettuce', 'ketchup']
    pizza:
      toppings: ['pepperoni', 'bacon']
  Given -> @fm.generate.withArgs("#{@root}/flavors",
    memo: sinon.match.object
    patterns: ['**/*.{js,coffee,json,yml}', '!**/_*.*']
    reducer: sinon.match.func
  ).returns
    context: {}
    icecream:
      flavor: 'chocolate'
  Given -> @grunt =
    loadNpmTasks: sinon.stub()
    initConfig: sinon.stub()

  describe 'with no options', ->
    When -> @subject @grunt
    Then -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-foo'
    And -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-cool-things'
    And -> expect(@grunt.initConfig).to.have.been.calledWith
      context: {}
      foo:
        msg: 'fooness'
      bar:
        msg: 'barness'
      baz:
        msg: 'bazness'

  describe 'with dependencies', ->
    context 'as an option', ->
      When -> @subject @grunt, { dependencies: true, devDependencies: false }
      Then -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-hello-world'
      And -> expect(@grunt.loadNpmTasks.calledWith('grunt-foo')).to.be.false()
      And -> expect(@grunt.loadNpmTasks.calledWith('grunt-cool-things')).to.be.false()

    context 'combined with devDependencies', ->
      When -> @subject @grunt, { dependencies: true }
      Then -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-hello-world'
      And -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-foo'
      And -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-cool-things'

  describe 'with a pattern', ->
    context 'as a regex', ->
      When -> @subject @grunt, { pattern: /^not-grunt-/ }
      Then -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'not-grunt-nope'
      And -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'not-grunt-nada'

    context 'as a string', ->
      When -> @subject @grunt, { pattern: 'not-grunt-' }
      Then -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'not-grunt-nope'
      And -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'not-grunt-nada'

  describe 'with include', ->
    context 'as a string', ->
      When -> @subject @grunt, { include: 'blah' }
      Then -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-foo'
      Then -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-cool-things'
      Then -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'blah'

    context 'as an array', ->
      When -> @subject @grunt, { include: ['foo', 'blah'] }
      Then -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-foo'
      Then -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-cool-things'
      Then -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'blah'
      Then -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'foo'

  describe 'with exclude', ->
    context 'as a string', ->
      When -> @subject @grunt, { exclude: 'grunt-cool-things' }
      Then -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-foo'
      Then -> expect(@grunt.loadNpmTasks.calledWith('grunt-cool-things')).to.be.false()

    context 'as an array', ->
      When -> @subject @grunt, { exclude: ['grunt-cool-things', 'grunt-foo'] }
      Then -> expect(@grunt.loadNpmTasks.called).to.be.false()

  describe 'with tasks', ->
    context 'as a string', ->
      When -> @subject @grunt, { tasks: 'toppings' }
      Then -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-foo'
      And -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-cool-things'
      And -> expect(@grunt.initConfig).to.have.been.calledWith
        context: {}
        hamburger:
          toppings: ['cheese', 'lettuce', 'ketchup']
        pizza:
          toppings: ['pepperoni', 'bacon']

    context 'as an array', ->
      When -> @subject @grunt, { tasks: ['flavors'] }
      Then -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-foo'
      And -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-cool-things'
      And -> expect(@grunt.initConfig).to.have.been.calledWith
        context: {}
        icecream:
          flavor: 'chocolate'

  describe 'reducer', ->
    context 'exports is an object', ->
      When -> @subject @grunt
      And -> @reducer = @fm.generate.getCall(0).args[1].reducer
      And -> @config = @reducer {}, {}, { fullPath: 'baz', name: 'baz' }
      Then -> expect(@config).to.deep.equal
        baz:
          content: 'baz'
          '@noCallThru': true

    context 'exports is a function', ->
      When -> @subject @grunt
      And -> @reducer = @fm.generate.getCall(0).args[1].reducer
      And -> @config = @reducer {}, { context: { foo: 'bar' } }, { fullPath: 'quux', name: 'quux' }
      Then -> expect(@config).to.deep.equal
        context:
          foo: 'bar'
        quux: 'bar quux'

  describe 'context', ->
    Given -> @fm.generate.withArgs("#{@root}/tasks",
      memo:
        context:
          hello: 'world'
          timestamp: 'now'
      patterns: ['**/*.{js,coffee,json,yml}', '!**/_*.*']
      reducer: sinon.match.func
    ).returns
      context:
        hello:
          world: 'yep'
        timestamp: 'now'
      foo:
        msg: 'fooness'
      bar:
        msg: 'barness'
      baz:
        msg: 'bazness'
      "<%= hello.world %>": "<%= timestamp %>"
    When -> @subject @grunt,
      context:
        hello: 'world'
        timestamp: 'now'
    Then -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-foo'
    And -> expect(@grunt.loadNpmTasks).to.have.been.calledWith 'grunt-cool-things'
    And -> expect(@grunt.initConfig).to.have.been.calledWith
      context:
        hello:
          world: 'yep'
        timestamp: 'now'
      foo:
        msg: 'fooness'
      bar:
        msg: 'barness'
      baz:
        msg: 'bazness'
      yep: 'now'
