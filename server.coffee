express      = require 'express'
morgan       = require 'morgan'
errorHandler = require 'errorhandler'
bodyParser   = require 'body-parser'
cors         = require 'cors'
MeshbluHttp  = require 'meshblu-http'
Routes       = require './app/routes'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
{DeviceAuthenticator} = require 'meshblu-authenticator-core'

try
  meshbluJSON  = require './meshblu.json'
catch
  meshbluJSON =
    uuid:   process.env.EMAIL_PASSWORD_AUTHENTICATOR_UUID
    token:  process.env.EMAIL_PASSWORD_AUTHENTICATOR_TOKEN
    server: process.env.MESHBLU_HOST
    port:   process.env.MESHBLU_PORT

meshbluJSON.name = process.env.EMAIL_PASSWORD_AUTHENTICATOR_NAME ? 'Email Authenticator'

port = process.env.EMAIL_PASSWORD_AUTHENTICATOR_PORT ? process.env.PORT ? 80

app = express()
app.use meshbluHealthcheck()
app.use morgan('dev')
app.use errorHandler()
app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: true)
app.use cors()

meshbluHttp = new MeshbluHttp meshbluJSON

authenticatorUuid = meshbluJSON.uuid
authenticatorName = meshbluJSON.name

deviceModel = new DeviceAuthenticator {authenticatorUuid, authenticatorName, meshbluHttp}

meshbluHttp.device meshbluJSON.uuid, (error, device) ->
  if error?
    console.error error.message, error.stack
    process.exit 1

  meshbluHttp.setPrivateKey(device.privateKey) unless meshbluHttp.privateKey

routes = new Routes {app, meshbluHttp, deviceModel}
routes.register()

app.listen port, =>
  console.log "listening at localhost:#{port}"

process.on 'SIGTERM', =>
  console.log 'SIGTERM caught, exiting'
  process.exit 0
