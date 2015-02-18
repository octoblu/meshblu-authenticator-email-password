DeviceController  = require './controllers/device-controller'
SessionController = require './controllers/session-controller'

class Routes
  constructor: (@app, uuid, meshblu) ->
    @deviceController  = new DeviceController uuid, meshblu
    @sessionController = new SessionController uuid, meshblu

  register: =>
    @app.post '/devices',                @deviceController.create
    @app.post '/devices/:uuid/sessions', @sessionController.create

module.exports = Routes
