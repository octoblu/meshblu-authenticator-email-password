DeviceController  = require './controllers/device-controller'
SessionController = require './controllers/session-controller'

class Routes
  constructor: (@app, uuid, meshblu) ->
    @deviceController  = new DeviceController uuid, meshblu
    @sessionController = new SessionController

  register: =>
    @app.post '/device',       @deviceController.create
    @app.post '/device/:uuid', @sessionController.create

module.exports = Routes
