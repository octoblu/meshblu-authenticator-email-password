_ = require 'lodash'
debug = require('debug')('meshblu:meshblu-db')

class MeshbluDb
  constructor: (@meshblu) ->

  findOne: (query, callback=->)=>
    @meshblu.devices query, (res)=>
      debug "found devices: ", res.devices
      return callback new Error 'record not found' if !res.devices.length
      callback null, res.devices[0]

  update: (device, callback) => 
    @meshblu.update device, callback    

  insert: (record, callback=->) =>
    debug "writing", record
    @meshblu.register record, (device) =>
      debug "insert response", device
      callback null, device

module.exports = MeshbluDb
