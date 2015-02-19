_ = require 'lodash'
debug = require('debug')('meshblu:pin-authenticator:meshblu-db')

class PinAuthenticatorDb
  constructor: (@meshblu) ->

  findOne : (query, callback=->)=>
    @meshblu.devices query, (devices)=>
      return callback new Error 'record not found' if !devices.length
      callback null, devices[0]


  insert: (record, callback=->) =>
    @meshblu.update record, (device) =>
      callback null, true

module.exports = PinAuthenticatorDb
