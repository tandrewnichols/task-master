global.sinon = require 'sinon'
global.expect = require('indeed').expect
global.sandbox = require('proxyquire').noCallThru()
_ = require 'lodash'

global.spyObj = (fns...) ->
  _(fns).reduce (obj, fn) ->
    obj[fn] = sinon.stub()
    obj
  , {}
