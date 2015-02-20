PinController = require './pin-controller'
debug = require('debug')('meshblu-pin-authenticator:device-controller')
_ = require 'lodash'

class DeviceController
  constructor: (uuid, meshblu) ->
    @pinController = new PinController uuid, meshblu: meshblu

  ipAddress: (request) =>
    return request.connection.remoteAddress unless request.headers['x-forwarded-for']?
    _.first request.headers['x-forwarded-for'].split(',')

  create: (request, response) =>
    {device, pin} = request.body
    device ?= {}
    device.ipAddress ?= @ipAddress(request)
    @pinController.createDevice pin, device, (error, device) =>
      return response.status(500).send error.message if error?
      response.status(201).send device

module.exports = DeviceController
