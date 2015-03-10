{DeviceAuthenticator} = require 'meshblu-authenticator-core'
MeshbluDB = require 'meshblu-db'
debug = require('debug')('meshblu-email-password-authenticator:device-controller')
_ = require 'lodash'
validator = require 'validator'
url = require 'url'

class DeviceController
  constructor: (meshbluJSON, @meshblu) ->
    @authenticatorUuid = meshbluJSON.uuid
    @authenticatorName = meshbluJSON.name
    @meshbludb = new MeshbluDB @meshblu

  prepare: (request, response, next) =>
    {email,password} = request.body
    return response.status(422).send 'Password required' if _.isEmpty(password)
    return response.status(422).send 'Invalid email' unless validator.isEmail(email)

    query = {}
    email = email.toLowerCase()
    query[@authenticatorUuid + '.id'] = email

    request.email = email
    request.password = password
    request.deviceQuery = query
    request.deviceModel = new DeviceAuthenticator @authenticatorUuid, @authenticatorName, meshblu: @meshblu, meshbludb: @meshbludb

    next()

  create: (request, response) =>
    {deviceModel, deviceQuery, email, password} = request
    debug 'device query', deviceQuery

    deviceModel.create deviceQuery, type: 'octoblu:user', email, password, @reply(request.body.callbackUrl, response)

  update: (request, response) =>
    {deviceModel, deviceQuery, email, password} = request
    {uuid} = request.body
    debug 'device query', deviceQuery
    return response.status(422).send 'Uuid required' if _.isEmpty(uuid)

    deviceModel.addAuth deviceQuery, uuid, email, password, @reply(request.body.callbackUrl, response)

  reply: (callbackUrl, response) =>
    (error, device) =>
      if error?
        if error.message == DeviceAuthenticator.ERROR_DEVICE_ALREADY_EXISTS
          return response.status(401).json error: "Unable to create user"

        if error.message == DeviceAuthenticator.ERROR_DEVICE_NOT_FOUND
          return response.status(401).json error: "Unable to find device"

        return response.status(500).send(error)

      @meshblu.generateAndStoreToken uuid: device.uuid, (device) =>
        return response.status(201).send(device: device) unless callbackUrl?

        uriParams = url.parse callbackUrl
        uriParams.query ?= {}
        uriParams.query.uuid = device.uuid
        uriParams.query.token = device.token
        uri = url.format uriParams
        response.status(201).location(uri).send(device: device, callbackUrl: uri)

module.exports = DeviceController
