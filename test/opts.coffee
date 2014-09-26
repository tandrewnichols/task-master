describe 'opts', ->
  Given -> @file = spyObj 'get'
  Given -> @glob = spyObj 'sync'
  Given -> @subject = sandbox '../lib/opts',
    './file': @file
    glob: @glob

  describe '.build', ->
    afterEach -> @subject.merge.restore()
    Given -> sinon.stub @subject, 'merge'
    context 'opts is an object', ->
      Given -> @opts =
        foo: 'bar'
      When -> @subject.build '/root', @opts
      Then -> expect(@subject.merge).to.have.been.calledWith foo: 'bar'

    context 'opts is null', ->
      context 'canonical opts file does not exist', ->
        Given -> @glob.sync.withArgs('_taskmaster.opts.{js,coffee,json,yml}', { cwd: '/root/tasks' }).returns []
        When -> @subject.build '/root', null
        Then -> expect(@subject.merge).to.have.been.calledWith {}

      context 'canonical opts file exists', ->
        Given -> @glob.sync.withArgs('_taskmaster.opts.{js,coffee,json,yml}', { cwd: '/root/tasks' }).returns ['foo.bar']
        Given -> @file.get.withArgs('foo.bar').returns foo: 'bar'
        When -> @subject.build '/root', null
        Then -> expect(@subject.merge).to.have.been.calledWith foo: 'bar'

    context 'opts is a string', ->
      context 'returned content is a string', ->
        Given -> @file.get.withArgs('blah.js').returns 'lorem ibsum etc'
        When -> @subject.build '/root', 'blah.js'
        Then -> expect(@subject.merge).to.have.been.calledWith {}

      context 'returned content is an object', ->
        Given -> @file.get.withArgs('blah.js').returns foo: 'bar'
        When -> @subject.build '/root', 'blah.js'
        Then -> expect(@subject.merge).to.have.been.calledWith foo: 'bar'

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
