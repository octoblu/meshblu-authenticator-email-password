EmailPasswordModel = require '../models/email-password-model'
MeshbluDb = require 'meshblu-db'
_ = require 'lodash'

class EmailPasswordController
  constructor : (uuid, dependencies) ->
    @uuid = uuid
    @meshblu = dependencies?.meshblu
    @emailPasswordModel = dependencies?.emailPasswordModel || new EmailPasswordModel( @uuid, db: new MeshbluDb( @meshblu ))

  createDevice : (email, password, device={}, callback=->) =>
    attributes = _.cloneDeep device
    attributes.configureWhitelist ?= []
    attributes.configureWhitelist.push @uuid

    @emailPasswordModel.save email, password, attributes, (error, device) =>
      return callback error, device?.uuid if error?

      @meshblu.generateAndStoreToken uuid: device?.uuid, (result) =>
        callback null, { uuid: device?.uuid, token: result?.token }

  getToken : (email, password, callback=->) =>
    @emailPasswordModel.checkEmailPassword email, password, (error, device)=>
      return callback(error) if error
      return callback( new Error 'Email and password combination is invalid') unless device?
      @meshblu.generateAndStoreToken uuid: device.uuid, (result) =>
        callback null, result

module.exports = EmailPasswordController
