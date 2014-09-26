describe 'file', ->
  Given -> @yaml = spyObj 'load'
  Given -> @fs = spyObj 'readFileSync'
  Given -> @glob = spyObj 'sync'
  Given -> @mango = -> mango: true
  Given -> @mango['@noCallThru'] = true
  Given -> @elderberry = (foo) -> elderberry: foo
  Given -> @elderberry['@noCallThru'] = true
  Given -> @subject = sandbox '../lib/file',
    glob: @glob
    yamljs: @yaml
    fs: @fs
    'banana.js':
      banana: true
      '@noCallThru': true
    'apple.coffee':
      apple: true
      '@noCallThru': true
    'pear.json':
      pear: true
      '@noCallThru': true
    'mango.js': @mango
    'elderberry.js': @elderberry

  describe '.get', ->
    context '.js file', ->
      When -> @content = @subject.get 'banana.js'
      Then -> expect(@content).to.deep.equal
        banana: true
        '@noCallThru': true

    context '.coffee file', ->
      When -> @content = @subject.get 'apple.coffee'
      Then -> expect(@content).to.deep.equal
        apple: true
        '@noCallThru': true

    context '.json file', ->
      When -> @content = @subject.get 'pear.json'
      Then -> expect(@content).to.deep.equal
        pear: true
        '@noCallThru': true

    context 'exports a function', ->
      When -> @content = @subject.get 'mango.js'
      Then -> expect(@content).to.deep.equal mango: true

    context 'exports a function and arguments are provided', ->
      When -> @content = @subject.get 'elderberry.js', true
      Then -> expect(@content).to.deep.equal elderberry: true

    context '.yml file', ->
      Given -> @yaml.load.withArgs('dragonfruit.yml').returns dragonfruit: true
      When -> @content = @subject.get 'dragonfruit.yml'
      Then -> expect(@content).to.deep.equal dragonfruit: true

    context 'something else', ->
      Given -> @fs.readFileSync.withArgs('kiwi.opts', 'utf8').returns "<div>kiwi</div>"
      When -> @content = @subject.get 'kiwi.opts'
      Then -> expect(@content).to.equal "<div>kiwi</div>"

  describe '.load', ->
    afterEach -> @subject.get.restore()
    Given -> sinon.stub @subject, 'get'
    
    context 'value is an object', ->
      When -> @res = @subject.load 'name', { foo: 'bar' }, '/root'
      Then -> expect(@res).to.deep.equal foo: 'bar'

    context 'value is a string', ->
      context 'disallowString is false', ->
        Given -> @subject.get.withArgs('blah.js').returns foo: 'bar'
        When -> @res = @subject.load 'name', 'blah.js', '/root'
        Then -> expect(@res).to.deep.equal foo: 'bar'

      context 'disallowString is true but result is object', ->
        Given -> @subject.get.withArgs('blah.js').returns foo: 'bar'
        When -> @res = @subject.load 'name', 'blah.js', '/root', true
        Then -> expect(@res).to.deep.equal foo: 'bar'

      context 'disallowString is true and result is a string', ->
        Given -> @subject.get.withArgs('blah.js').returns 'foo'
        When -> @res = @subject.load 'name', 'blah.js', '/root', true
        Then -> expect(@res).to.deep.equal {}

    context 'value is falsy', ->
      context 'canonical file exists', ->
        Given -> @glob.sync.withArgs('_taskmaster.name.{js,coffee,json,yml}', { cwd: '/root/tasks' }).returns ['blah.js']
        Given -> @subject.get.withArgs('blah.js').returns foo: 'bar'
        When -> @res = @subject.load 'name', null, '/root'
        Then -> expect(@res).to.deep.equal foo: 'bar'

      context 'canonical file does not exist', ->
        Given -> @glob.sync.withArgs('_taskmaster.name.{js,coffee,json,yml}', { cwd: '/root/tasks' }).returns []
        Given -> @subject.get.withArgs('blah.js').returns foo: 'bar'
        When -> @res = @subject.load 'name', null, '/root'
        Then -> expect(@res).to.deep.equal {}
