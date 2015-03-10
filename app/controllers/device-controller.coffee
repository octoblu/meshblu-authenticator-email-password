debug = require('debug')('meshblu-email-password-authenticator:device-controller')
_ = require 'lodash'
validator = require 'validator'
url = require 'url'

class DeviceController
  constructor: (meshbluJSON, @meshblu, @deviceAuthenticator) ->
    @authenticatorUuid = meshbluJSON.uuid
    @authenticatorName = meshbluJSON.name
   
  create: (request, response) =>
    {email,password} = request.body
    return response.status(422).send new Error('Password required') if _.isEmpty(password)
    return response.status(422).send new Error('Invalid email') unless validator.isEmail(email)

    query = {}
    email = email.toLowerCase()
    query[@authenticatorUuid + '.id'] = email
    device =
      type: 'octoblu:user'

    debug 'device query', query
    @deviceAuthenticator.create query, device, email, password, (error, createdDevice) =>
      console.log "CATS"
      if error?
        if error.message == 'device already exists'
          return response.status(401).json error: "Unable to create user"
        return response.status(500).send(error.message)

      @meshblu.generateAndStoreToken uuid: createdDevice.uuid, (device) =>
        {callbackUrl} = request.body
        return response.status(201).send(device: device) unless callbackUrl?

        uriParams = url.parse callbackUrl
        uriParams.query ?= {}
        uriParams.query.uuid = device.uuid
        uriParams.query.token = device.token
        uri = url.format uriParams
        response.status(201).location(uri).send(device: device, callbackUrl: uri)


module.exports = DeviceController
