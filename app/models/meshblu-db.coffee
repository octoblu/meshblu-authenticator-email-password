_ = require 'lodash'
debug = require('debug')('meshblu:pin-authenticator:meshblu-db')
class MeshbluDb
  constructor: (@meshblu) ->
    debug 'making a meshbludb'

  findOne : (query, callback=->)=>
    debug 'calling findOne', query
    @meshblu.whoami null, (device)=>
      res = _.findWhere(device.pins, query)
      return callback new Error 'record not found' if !res
      callback null, res


  insert: (record, callback=->) =>
    debug 'calling insert', record
    @meshblu.whoami null, (device)=>
      device.pins ?= []
      device.pins.push record
      @meshblu.update pins: device.pins, =>
        callback null, true

module.exports = MeshbluDb
