_ = require 'lodash'
debug = require('debug')('meshblu:pin-authenticator:meshblu-db')

class PinAuthenticatorDb
  constructor: (@meshblu) ->

  findOne : (query, callback=->)=>
    @meshblu.devices query, (res)=>
      debug "found devices: ", res.devices
      return callback new Error 'record not found' if !res.devices.length
      callback null, res.devices[0]


  insert: (record, callback=->) =>
    debug "writing", record
    @meshblu.register record, (device) =>
      debug "insert response", device
      callback null, device

module.exports = PinAuthenticatorDb
