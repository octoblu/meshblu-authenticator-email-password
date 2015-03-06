MeshbluDB = require 'meshblu-db'
ForgotPasswordModel = require '../models/forgot-password-model'
debug = require('debug')('meshblu-email-password-authenticator:forgot-controller')

class ForgotPasswordController
  constructor: (meshbluJSON, @meshblu) ->
    @authenticatorUuid = meshbluJSON.uuid
    @authenticatorName = meshbluJSON.name
    @meshbludb = new MeshbluDB @meshblu
    @forgotPasswordModel = new ForgotPasswordModel(@authenticatorUuid, process.env.MAILGUN_API_KEY, process.env.MAILGUN_DOMAIN, process.env.PASSWORD_RESET_URL, { db: @meshbludb, meshblu: @meshblu})

  forgot: (request, response) =>
    @forgotPasswordModel.forgot request.body.email, (error, data) =>
      return response.status(404).send(error.message) if error && error.message == 'Device not found for email address'
      return response.status(500).send(error.message) if error
      return response.send(201)

  reset: (request, response) =>
    {device,token,password} = request.body
    return response.status(422).send() unless device? && token? && password?
    @forgotPasswordModel.reset device, token, password, (error) =>
      return response.status(500).send(error.message) if error
      response.send(201)

module.exports = ForgotPasswordController
