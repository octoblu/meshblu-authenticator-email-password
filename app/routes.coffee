cors = require 'cors'
{DeviceAuthenticator} = require 'meshblu-authenticator-core'
DeviceController  = require './controllers/device-controller'
SessionController = require './controllers/session-controller'
ForgotPasswordController = require './controllers/forgot-password-controller'
MeshbluDB = require 'meshblu-db'

class Routes
  constructor: (@app, meshbluJSON, meshblu) ->
    @meshbludb                = new MeshbluDB meshblu
    @deviceAuthenticator      = new DeviceAuthenticator meshbluJSON.uuid, meshbluJSON.name, {meshblu: meshblu, meshbludb: @meshbludb}
    @deviceController         = new DeviceController meshbluJSON, meshblu, @deviceAuthenticator
    @forgotPasswordController = new ForgotPasswordController meshbluJSON, meshblu
    @sessionController        = new SessionController meshbluJSON, meshblu

  register: =>
    @app.options '*', cors()
    @app.get  '/', (request, response) => response.status(200).send status: 'online'
    @app.post '/devices', @deviceController.create
    @app.post '/sessions', @sessionController.create
    @app.post '/forgot', @forgotPasswordController.forgot
    @app.post '/reset', @forgotPasswordController.reset



module.exports = Routes
