express      = require 'express'
morgan       = require 'morgan'
errorHandler = require 'errorhandler'
bodyParser   = require 'body-parser'
meshblu      = require 'meshblu'
meshbluJSON  = require './meshblu.json'
Routes       = require './app/routes'

port = process.env.PIN_AUTHENTICATOR_PORT ? 3003

app = express()
app.use morgan('combined')
app.use errorHandler()
app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: true)

conn = meshblu.createConnection meshbluJSON
conn.on 'ready', ->
  routes = new Routes app, meshbluJSON.uuid, conn
  routes.register()

  app.listen port, =>
    console.log "listening at localhost:#{port}"
