PinModel = require '../models/pin-model'
MeshbluDb = require '../models/meshblu-db'

class PinController
  constructor : (uuid, dependencies) ->
    @uuid = uuid
    @meshblu = dependencies?.meshblu
    @pinModel = dependencies?.pinModel || new PinModel( db: new MeshbluDb( @meshblu ))

  createDevice : (pin, callback=->) =>
    @meshblu.register { configureWhitelist : [ @uuid ] }, (device) =>
      @pinModel.save device.uuid, pin, (error) ->
        callback error, device.uuid

  getToken : (uuid, pin, callback=->) =>
    @pinModel.checkPin uuid, pin, (error, result)=>
      return callback(error) if error
      return callback( new Error 'Pin is invalid') if !result
      @meshblu.getSessionToken uuid, callback

module.exports = PinController
