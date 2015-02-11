class PinController
  constructor : (uuid, dependencies) ->
    @uuid = uuid
    @meshblu = dependencies.meshblu
    @db = dependencies.db

  createDevice : (pin, callback=->) =>
    @meshblu.register { configureWhitelist : [ @uuid ] }, (device) =>
      @db.save { pin: pin, uuid: device.uuid }
      callback null, device.uuid

  getToken : (uuid, pin) =>
    @db.checkPin uuid, pin

module.exports = PinController