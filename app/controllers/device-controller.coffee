PinController = require './pin-controller'

class DeviceController
  constructor: (uuid, meshblu) ->
    @pinController = new PinController uuid, meshblu: meshblu

  create: (request, response) =>
    pin = request.params.pin
    @pinController.createDevice pin, (error, uuid) =>
      return response.send 500, error: error if error?
      response.send 201, uuid: uuid
