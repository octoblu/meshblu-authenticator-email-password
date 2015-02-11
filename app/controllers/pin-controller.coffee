class PinController
  constructor : (uuid, dependencies) ->
    @uuid = uuid
    @meshblu = dependencies?.meshblu || require 'meshblu'
    @db = dependencies?.db || require '../models/PinModel'

  createDevice : (pin, callback=->) =>
    @meshblu.register { configureWhitelist : [ @uuid ] }, (device) =>
      @db.save { pin: pin, uuid: device.uuid }
      callback null, device.uuid

  getToken : (uuid, pin, callback=->) =>
    @db.checkPin uuid, pin, (error, result)=>
      return callback(error) if error
      @meshblu.getSessionToken uuid, callback

module.exports = PinController
