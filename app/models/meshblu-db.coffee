_ = require 'lodash'
class MeshbluDb
  constructor: (@meshblu) ->

  findOne : (query, callback=->)=>
    @meshblu.whoami null, (device)=>
      callback null, _.findWhere(device.pins, query)

  insert: (record, callback=->) =>
    @meshblu.whoami null, (device)=>
      device.pins ?= []
      device.pins.push record
      @meshblu.update pins: device.pins, =>
        callback null, true

module.exports = MeshbluDb
