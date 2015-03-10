cors = require 'cors'
DeviceController  = require './controllers/device-controller'
SessionController = require './controllers/session-controller'
ForgotPasswordController = require './controllers/forgot-password-controller'

class Routes
  constructor: (@app, meshbluJSON, meshblu) ->
    @deviceController  = new DeviceController meshbluJSON, meshblu
    @sessionController = new SessionController meshbluJSON, meshblu
    @forgotPasswordController = new ForgotPasswordController meshbluJSON, meshblu

  register: =>
    @app.options '*', cors()
    @app.get  '/', (request, response) => response.status(200).send status: 'online'
    @app.post '/devices', @deviceController.prepare, @deviceController.create
    @app.put '/devices', @deviceController.prepare, @deviceController.update
    @app.post '/sessions', @sessionController.create
    @app.post '/forgot', @forgotPasswordController.forgot
    @app.post '/reset', @forgotPasswordController.reset



module.exports = Routes
