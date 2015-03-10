cors      = require 'cors'
MeshbluDB = require 'meshblu-db'
{DeviceAuthenticator}    = require 'meshblu-authenticator-core'
DeviceController         = require './controllers/device-controller'
ForgotPasswordController = require './controllers/forgot-password-controller'
ForgotPasswordModel      = require './models/forgot-password-model'
SessionController        = require './controllers/session-controller'

class Routes
  constructor: (@app, meshbluJSON, meshblu) ->
    meshbludb                 = new MeshbluDB meshblu
    @deviceAuthenticator      = new DeviceAuthenticator meshbluJSON.uuid, meshbluJSON.name, {meshblu: meshblu, meshbludb: meshbludb}
    @deviceController         = new DeviceController meshbluJSON, meshblu, @deviceAuthenticator
    @forgotPasswordModel      = new ForgotPasswordModel meshbluJSON.Uuid, process.env.MAILGUN_API_KEY, process.env.MAILGUN_DOMAIN, process.env.PASSWORD_RESET_URL, { db: meshbludb, meshblu: meshblu}
    @forgotPasswordController = new ForgotPasswordController meshbluJSON, meshblu, @forgotPasswordModel
    @sessionController        = new SessionController meshbluJSON, meshblu, @deviceAuthenticator

  register: =>
    @app.options '*', cors()
    @app.get  '/', (request, response) => response.status(200).send status: 'online'
    @app.post '/devices', @deviceController.prepare, @deviceController.create
    @app.put '/devices', @deviceController.prepare, @deviceController.update
    @app.post '/sessions', @sessionController.create
    @app.post '/forgot', @forgotPasswordController.forgot
    @app.post '/reset', @forgotPasswordController.reset



module.exports = Routes
