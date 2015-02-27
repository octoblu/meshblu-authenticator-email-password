EmailPasswordController = require './email-password-controller'
debug = require('debug')('meshblu-email-password-authenticator:sessions-controller')

class SessionController
  constructor: (uuid, meshblu) ->
    @emailPasswordController = new EmailPasswordController uuid, meshblu: meshblu

  create: (request, response) =>
    debug "Got request: #{JSON.stringify(request.body)}"
    {email,password}  = request.body

    @emailPasswordController.getToken email, password, (error, device) =>
      return response.status(401).send error.message if error?
      response.status(201).send token: device.token

module.exports = SessionController
