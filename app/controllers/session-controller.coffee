debug = require('debug')('meshblu-authenticator-email-password:sessions-controller')
url = require 'url'

class SessionController
  constructor: ({@meshbluHttp, @deviceModel}) ->

  create: (request, response) =>
    {email,password,callbackUrl} = request.body
    query = {}
    email = email.toLowerCase()
    query[@deviceModel.authenticatorUuid + '.id'] = email

    deviceFindCallback = (error, foundDevice) =>
      debug 'device find error', error if error?
      debug 'device find', foundDevice

      return response.status(401).send error?.message unless foundDevice

      debug 'about to generateAndStoreToken', foundDevice.uuid
      @meshbluHttp.generateAndStoreToken foundDevice.uuid, (error, device) =>
        return response.status(201).send(device:device) unless callbackUrl?

        uriParams = url.parse callbackUrl, true
        delete uriParams.search
        uriParams.query ?= {}
        uriParams.query.uuid = device.uuid
        uriParams.query.token = device.token
        uri = decodeURIComponent url.format(uriParams)

        response.status(201).location(uri).send(device: device, callbackUrl: uri)

    @deviceModel.findVerified query: query, password: password, deviceFindCallback

module.exports = SessionController
