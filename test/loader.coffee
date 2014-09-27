describe 'loader', ->
  Given -> @yaml = spyObj 'load'
  Given -> @fs = spyObj 'readFileSync'
  Given -> @glob = spyObj 'sync'
  Given -> @mango = -> mango: true
  Given -> @mango['@noCallThru'] = true
  Given -> @elderberry = (foo) -> elderberry: foo
  Given -> @elderberry['@noCallThru'] = true
  Given -> @subject = sandbox '../lib/loader',
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

    context 'file does not exist', ->
      When -> @content = @subject.get 'serviceberry.coffee'
      Then -> expect(@content).to.deep.equal {}

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
      Given -> @fs.readFileSync.withArgs('kiwi.html', 'utf8').returns "<div>kiwi</div>"
      When -> @content = @subject.get 'kiwi.opts'
      Then -> expect(@content).to.deep.equal {}

  describe '.getAll', ->
    afterEach -> @subject.get.restore()
    Given -> sinon.stub @subject, 'get'
    Given -> @glob.sync.withArgs('1', { cwd: '/root/tasks' }).returns ['foo']
    Given -> @glob.sync.withArgs('2', { cwd: '/root/tasks' }).returns ['bar', 'baz']
    Given -> @subject.get.withArgs('/root/tasks/foo').returns foo: 1
    Given -> @subject.get.withArgs('/root/tasks/bar').returns bar: 1
    Given -> @subject.get.withArgs('/root/tasks/baz').returns baz: 1
    When -> @res = @subject.getAll ['1', '2'], '/root', ['tasks']
    Then -> expect(@res).to.deep.equal
      foo: 1
      bar: 1
      baz: 1

  describe '.load', ->
    afterEach -> @subject.getAll.restore()
    Given -> sinon.stub @subject, 'getAll'
    
    context 'value is an object', ->
      Given -> @subject.getAll.withArgs(['_taskmaster.name*.{js,coffee,json,yml}'], '/root', ['tasks']).returns baz: 'quux'
      When -> @res = @subject.load 'name', { foo: 'bar' }, '/root', ['tasks']
      Then -> expect(@res).to.deep.equal
        foo: 'bar'
        baz: 'quux'

    context 'value is a string', ->
      Given -> @subject.getAll.withArgs(['_taskmaster.name*.{js,coffee,json,yml}'], '/root', ['tasks']).returns baz: 'quux'
      Given -> @subject.getAll.withArgs(['blah.js'], '/root', ['tasks']).returns foo: 'bar'
      When -> @res = @subject.load 'name', 'blah.js', '/root', ['tasks']
      Then -> expect(@res).to.deep.equal
        foo: 'bar'
        baz: 'quux'

    context 'value is an array', ->
      Given -> @subject.getAll.withArgs(['_taskmaster.name*.{js,coffee,json,yml}'], '/root', ['tasks']).returns baz: 'quux'
      Given -> @subject.getAll.withArgs(['blah.js'], '/root', ['tasks']).returns foo: 'bar'
      When -> @res = @subject.load 'name', ['blah.js'], '/root', ['tasks']
      Then -> expect(@res).to.deep.equal
        foo: 'bar'
        baz: 'quux'

    context 'non-canonical files take precedence', ->
      Given -> @subject.getAll.withArgs(['_taskmaster.name*.{js,coffee,json,yml}'], '/root', ['tasks']).returns foo: 'Zippy ate a banana'
      Given -> @subject.getAll.withArgs(['blah.js'], '/root', ['tasks']).returns foo: 'Toto ate grass in the backyard'
      When -> @res = @subject.load 'name', 'blah.js', '/root', ['tasks']
      Then -> expect(@res).to.deep.equal
        foo: 'Toto ate grass in the backyard'
