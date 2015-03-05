{DeviceAuthenticator} = require 'meshblu-authenticator-core'
MeshbluDB = require 'meshblu-db'
debug = require('debug')('meshblu-email-password-authenticator:sessions-controller')
url = require 'url'

class SessionController
  constructor: (meshbluJSON, @meshblu) ->
    @authenticatorUuid = meshbluJSON.uuid
    @authenticatorName = meshbluJSON.name
    @meshbludb = new MeshbluDB @meshblu

  create: (request, response) =>
    {email,password,callbackUrl} = request.body
    deviceModel = new DeviceAuthenticator @authenticatorUuid, @authenticatorName, meshblu: @meshblu, meshbludb: @meshbludb
    query = {}
    query[@authenticatorUuid + '.id'] = email
    device = 
      type: 'octoblu:user'

    deviceFindCallback = (error, foundDevice) =>
      debug 'device find error', error if error?
      debug 'device find', foundDevice

      return response.status(401).send error unless foundDevice
      
      debug 'about to generateAndStoreToken', uuid: foundDevice.uuid
      @meshblu.generateAndStoreToken uuid: foundDevice.uuid, (device) =>
        debug 'got called back'
        return response.send(device) unless callbackUrl?
        
        uriParams = url.parse callbackUrl
        uriParams.query ?= {}
        uriParams.query.uuid = device.uuid
        uriParams.query.token = device.token
        debug 'about to redirect', url.format uriParams
        response.redirect url.format uriParams

    deviceModel.findVerified query, password, deviceFindCallback

module.exports = SessionController
