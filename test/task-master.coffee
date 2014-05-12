describe 'task-master', ->
  Given -> @fm = {}
  Given -> @subject = sandbox '../task-master',
    'file-manifest': @fm
  Given -> @fm.generate = sinon.stub().returns
    foo:
      msg: 'fooness'
    bar:
      msg: 'barness'
    baz:
      msg: 'bazness'
  When -> @config = @subject {}
  Then -> expect(@config).to.deep.equal
    foo:
      msg: 'fooness'
    bar:
      msg: 'barness'
    baz:
      msg: 'bazness'
