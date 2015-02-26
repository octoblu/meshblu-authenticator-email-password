EmailPasswordController = require './email-password-controller'
debug = require('debug')('meshblu-email-password-authenticator:device-controller')
_ = require 'lodash'

class DeviceController
  constructor: (uuid, meshblu) ->
    @emailPasswordController = new EmailPasswordController uuid, meshblu: meshblu

  ipAddress: (request) =>
    return request.connection.remoteAddress unless request.headers['x-forwarded-for']?
    _.first request.headers['x-forwarded-for'].split(',')

  create: (request, response) =>
    {device, email, password} = request.body
    device ?= {}
    device.ipAddress ?= @ipAddress(request)
    @emailPasswordController.createDevice email, password, device, (error, device) =>
      return response.status(500).send error.message if error?
      response.status(201).send device

module.exports = DeviceController
