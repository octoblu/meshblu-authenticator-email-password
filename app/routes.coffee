DeviceController  = require './controllers/device-controller'
SessionController = require './controllers/session-controller'

class Routes
  constructor: (@app, uuid, meshblu) ->
    @deviceController  = new DeviceController uuid, meshblu
    @sessionController = new SessionController uuid, meshblu

  register: =>
    @app.get  '/', (request, response) => response.status(200).send status: 'online'
    @app.post '/devices',                @deviceController.create
    @app.post '/devices/:uuid/sessions', @sessionController.create

module.exports = Routes
