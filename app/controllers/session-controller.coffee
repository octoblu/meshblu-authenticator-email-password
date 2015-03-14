debug = require('debug')('meshblu-email-password-authenticator:sessions-controller')
url = require 'url'

class SessionController
  constructor: (meshbluJSON, @meshblu, @deviceAuthenticator) ->
    @authenticatorUuid = meshbluJSON.uuid
    @authenticatorName = meshbluJSON.name

  create: (request, response) =>
    {email,password,callbackUrl} = request.body
    query = {}
    email = email.toLowerCase()
    query[@authenticatorUuid + '.id'] = email
    device =
      type: 'octoblu:user'

    deviceFindCallback = (error, foundDevice) =>
      debug 'device find error', error if error?
      debug 'device find', foundDevice

      return response.status(401).send error?.message unless foundDevice

      debug 'about to generateAndStoreToken', uuid: foundDevice.uuid
      @meshblu.generateAndStoreToken uuid: foundDevice.uuid, (device) =>
        return response.status(201).send(device:device) unless callbackUrl?

        uriParams = url.parse callbackUrl
        uriParams.query ?= {}
        uriParams.query.uuid = device.uuid
        uriParams.query.token = device.token
        uri = decodeURIComponent url.format(uriParams)

        response.status(201).location(uri).send(device: device, callbackUrl: uri)

    @deviceAuthenticator.findVerified query, password, deviceFindCallback

module.exports = SessionController
