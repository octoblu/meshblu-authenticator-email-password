cors      = require 'cors'
{DeviceAuthenticator}    = require 'meshblu-authenticator-core'
DeviceController         = require './controllers/device-controller'
ForgotPasswordController = require './controllers/forgot-password-controller'
ForgotPasswordModel      = require './models/forgot-password-model'
SessionController        = require './controllers/session-controller'

class Routes
  constructor: ({@app, deviceModel, meshbluHttp}) ->
    @deviceController         = new DeviceController {meshbluHttp, deviceModel}
    @forgotPasswordModel      = new ForgotPasswordModel
      uuid: deviceModel.authenticatorUuid
      mailgunKey: process.env.MAILGUN_API_KEY
      mailgunDomain: process.env.MAILGUN_DOMAIN || 'octoblu.com'
      passwordResetUrl: process.env.PASSWORD_RESET_URL
      meshbluHttp: meshbluHttp

    @forgotPasswordController = new ForgotPasswordController {@forgotPasswordModel}
    @sessionController        = new SessionController {meshbluHttp, deviceModel}

  register: =>
    @app.options '*', cors()
    @app.get  '/', (request, response) => response.status(200).send status: 'online'
    @app.post '/devices', @deviceController.prepare, @deviceController.create
    @app.put '/devices', @deviceController.prepare, @deviceController.update
    @app.post '/sessions', @sessionController.create
    @app.post '/forgot', @forgotPasswordController.forgot
    @app.post '/reset', @forgotPasswordController.reset

module.exports = Routes
