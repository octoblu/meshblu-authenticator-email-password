DeviceController  = require './controllers/device-controller'
SessionController = require './controllers/session-controller'

class Routes
  constructor: (@app, meshbluJSON, meshblu) ->
    @deviceController  = new DeviceController meshbluJSON, meshblu
    @sessionController = new SessionController meshbluJSON, meshblu

  register: =>
    @app.get  '/', (request, response) => response.status(200).send status: 'online'
    @app.post '/devices', @deviceController.create
    @app.post '/sessions', @sessionController.create

module.exports = Routes
