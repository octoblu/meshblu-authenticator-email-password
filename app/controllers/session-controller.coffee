EmailPasswordController = require './email-password-controller'
debug = require('debug')('meshblu-email-password-authenticator:sessions-controller')
url = require 'url'

class SessionController
  constructor: (uuid, meshblu) ->
    @emailPasswordController = new EmailPasswordController uuid, meshblu: meshblu

  create: (request, response) =>
    debug "Got request: #{JSON.stringify(request.body)}"
    {email,password,callbackUrl}  = request.body

    @emailPasswordController.getToken email, password, (error, device) =>
      return response.status(401).send error.message if error?

      uriParams = url.parse callbackUrl
      uriParams.query ?= {}
      uriParams.query.uuid = device.uuid
      uriParams.query.token = device.token

      response.redirect url.format uriParams

module.exports = SessionController
