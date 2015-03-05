{DeviceAuthenticator} = require 'meshblu-authenticator-core'
MeshbluDB = require 'meshblu-db'
debug = require('debug')('meshblu-email-password-authenticator:device-controller')
_ = require 'lodash'
validator = require 'validator'

class DeviceController
  constructor: (meshbluJSON, @meshblu) ->
    @authenticatorUuid = meshbluJSON.uuid
    @authenticatorName = meshbluJSON.name
    @meshbludb = new MeshbluDB @meshblu

  create: (request, response) =>
    {email,password} = request.body
    return response.status(422).send new Error ('Invalid email') unless validator.isEmail(email)

    deviceModel = new DeviceAuthenticator @authenticatorUuid, @authenticatorName, meshblu: @meshblu, meshbludb: @meshbludb
    query = {}
    query[@authenticatorUuid + '.id'] = email
    device = 
      type: 'octoblu:user'

    deviceCreateCallback = (error, createdDevice) => 
      debug 'device create error', error if error?
      debug 'device created', createdDevice
      if error?
        return response.status(500).send(error)
      unless createdDevice?
        return response.status(401).send(new Error "Unable to validate user" )

      return response.json createdDevice
    
    debug 'device query', query
    deviceModel.create query, device, email, password, deviceCreateCallback

module.exports = DeviceController
