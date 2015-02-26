PinModel = require '../models/pin-model'
PinAuthenticatorDb = require '../models/pin-authenticator-db'
_ = require 'lodash'

class PinController
  constructor : (uuid, dependencies) ->
    @uuid = uuid
    @meshblu = dependencies?.meshblu
    @pinModel = dependencies?.pinModel || new PinModel( @uuid, db: new PinAuthenticatorDb( @meshblu ))

  createDevice : (pin, device={}, callback=->) =>
    attributes = _.cloneDeep device
    attributes.configureWhitelist ?= []
    attributes.configureWhitelist.push @uuid

    @pinModel.save pin, attributes, (error, device) =>
      if (error)
        return callback error, device?.uuid

      @meshblu.generateAndStoreToken uuid: device?.uuid, (result) =>
        callback null, { uuid: device?.uuid, token: result?.token }

  getToken : (uuid, pin, callback=->) =>
    @pinModel.checkPin uuid, pin, (error, result)=>
      return callback(error) if error
      return callback( new Error 'Pin is invalid') if !result
      @meshblu.generateAndStoreToken uuid: uuid, (result) =>
        callback null, result

module.exports = PinController
