cp = require 'child_process'
fs = require 'fs'

describe 'Acceptance test', ->
  afterEach -> console.log.restore()
  Given -> sinon.spy console, 'log'
  When (done) -> cp.exec 'grunt foo', done
  Then -> expect(console.log).to.have.been.calledWith 'bar task executed'
  And -> expect(console.log).to.have.been.calledWith 'baz task executed'
