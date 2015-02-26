express      = require 'express'
morgan       = require 'morgan'
errorHandler = require 'errorhandler'
bodyParser   = require 'body-parser'
cors         = require 'cors'
meshblu      = require 'meshblu'
Routes       = require './app/routes'

try
  meshbluJSON  = require './meshblu.json'
catch
  meshbluJSON =
    uuid:   process.env.PIN_AUTHENTICATOR_UUID
    token:  process.env.PIN_AUTHENTICATOR_TOKEN
    server: process.env.MESHBLU_HOST
    port:   process.env.MESHBLU_PORT

port = process.env.PIN_AUTHENTICATOR_PORT ? 3003

app = express()
app.use morgan('combined')
app.use errorHandler()
app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: true)
app.use cors()

conn = meshblu.createConnection meshbluJSON
conn.on 'ready', ->
  routes = new Routes app, meshbluJSON.uuid, conn
  routes.register()

  app.listen port, =>
    console.log "listening at localhost:#{port}"

conn.on 'notReady', ->
  console.error "Unable to establish a connection to meshblu"
