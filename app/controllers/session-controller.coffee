EmailPasswordController = require './email-password-controller'

class SessionController
  constructor: (uuid, meshblu) ->
    @emailPasswordController = new EmailPasswordController uuid, meshblu: meshblu

  create: (request, response) =>
    uuid = request.params.uuid
    {email,password}  = request.body

    @emailPasswordController.getToken uuid, email, password, (error, device) =>
      return response.status(401).send error.message if error?
      response.status(201).send token: device.token

module.exports = SessionController
