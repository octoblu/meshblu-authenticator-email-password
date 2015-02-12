class PinController
  constructor : (uuid, dependencies) ->
    @uuid = uuid
    @meshblu = dependencies?.meshblu
    @pinModel = dependencies?.pinModel || new require '../models/pin-model'

  createDevice : (pin, callback=->) =>
    @meshblu.register { configureWhitelist : [ @uuid ] }, (device) =>
      @pinModel.save { pin: pin, uuid: device.uuid }
      callback null, device.uuid

  getToken : (uuid, pin, callback=->) =>
    @pinModel.checkPin uuid, pin, (error, result)=>
      return callback(error) if error
      return callback( new Error 'Pin is invalid') if !result
      @meshblu.getSessionToken uuid, callback

module.exports = PinController
