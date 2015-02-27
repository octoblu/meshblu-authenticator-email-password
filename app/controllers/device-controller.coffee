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
    debug "Got request: #{JSON.stringify(request.body)}"
    {device, email, password} = request.body

    device ?= {}
    device.ipAddress ?= @ipAddress(request)
    @emailPasswordController.createDevice email, password, device, (error, device) =>
      debug error, device
      return response.status(500).json error.message if error?
      response.json device

module.exports = DeviceController
