describe 'coercion', ->
  Given -> @subject = require '../../cli/coercion'

  describe '.collect', ->
    context 'called multiple times', ->
      Given -> @list = []
      When -> @list = @subject.collect 'foo', @list
      And -> @list = @subject.collect 'bar', @list
      And -> @list = @subject.collect 'baz', @list
      Then -> expect(@list).to.deep.equal [ 'foo', 'bar', 'baz' ]

    context 'called with a literal list', ->
      Given -> @list = ['foo']
      When -> @list = @subject.collect 'bar,baz', @list
      Then -> expect(@list).to.deep.equal ['foo', 'bar', 'baz' ]

  describe '.toRegex', ->
    context 'with a regex', ->
      Given -> @reg = /^foo/
      When -> @ret = @subject.toRegex @reg
      Then -> expect(@ret).to.equal @reg

    context 'with a string', ->
      Given -> @reg = '^foo'
      When -> @ret = @subject.toRegex @reg
      Then -> expect(@ret).to.deep.equal /^foo/

  describe '.toSpacing', ->
    When -> @str = @subject.toSpacing 3
    Then -> expect(@str).to.equal '   '
