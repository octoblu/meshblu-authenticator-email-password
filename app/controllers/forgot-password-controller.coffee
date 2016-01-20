debug = require('debug')('meshblu-authenticator-email-password:forgot-controller')

class ForgotPasswordController
  constructor: ({@forgotPasswordModel}) ->

  forgot: (request, response) =>
    @forgotPasswordModel.forgot request.body.email, (error, data) =>
      if error
        return response.status(404).send(error.message) if error.message == 'Device not found for email address'
        return response.status(401).send('Cannot write to this device') if error.message == 'unauthorized'
        return response.status(500).send(error.message)

      return response.send(201)

  reset: (request, response) =>
    {device,token,password} = request.body
    return response.status(422).send() unless device? && token? && password?
    @forgotPasswordModel.reset device, token, password, (error) =>
      return response.status(500).send(error.message) if error
      response.send(201)

module.exports = ForgotPasswordController
