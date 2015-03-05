MeshbluDB = require 'meshblu-db'
ForgotPasswordModel = require '../models/forgot-password-model'
debug = require('debug')('meshblu-email-password-authenticator:forgot-controller')

class ForgotPasswordController
  constructor: (meshbluJSON, @meshblu) ->
    @authenticatorUuid = meshbluJSON.uuid
    @authenticatorName = meshbluJSON.name
    @meshbludb = new MeshbluDB @meshblu
    @forgotPasswordModel = new ForgotPasswordModel(@authenticatorUuid, 'key-1363df07931b61ec9eeabda8702a8998', { db: @meshbludb, meshblu: @meshblu})


  forgot: (request, response) =>
    @forgotPasswordModel.forgot( request.body.email, (error, data)=>
      return response.status(404).send(error.message) if error && error.message == 'Device not found for email address'
      return response.status(500).send(error.message) if error
      return response.send(201)
    )



module.exports = ForgotPasswordController
