PinController = require './pin-controller'
debug = require('debug')('meshblu-pin-authenticator:device-controller')

class DeviceController
  constructor: (uuid, meshblu) ->
    @pinController = new PinController uuid, meshblu: meshblu

  create: (request, response) =>
    pin = request.body.pin
    debug request.body
    @pinController.createDevice pin, (error, uuid) =>
      return response.status(500).send error: error.message if error?
      response.status(201).send uuid: uuid

module.exports = DeviceController
