describe 'file', ->
  Given -> @yaml = spyObj 'load'
  Given -> @fs = spyObj 'readFileSync'
  Given -> @mango = -> mango: true
  Given -> @mango['@noCallThru'] = true
  Given -> @elderberry = (foo) -> elderberry: foo
  Given -> @elderberry['@noCallThru'] = true
  Given -> @subject = sandbox '../lib/file',
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
