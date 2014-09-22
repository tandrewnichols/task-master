global.sinon = require 'sinon'
global.expect = require('indeed').expect
global.sandbox = require 'proxyquire'
_ = require 'lodash'

global.spyObj = (fns...) ->
  _.reduce fns, (obj, fn) ->
    obj[fn] = sinon.stub()
    obj
  , {}
