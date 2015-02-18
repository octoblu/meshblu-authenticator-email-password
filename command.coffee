express      = require 'express'
morgan       = require 'morgan'
errorHandler = require 'errorhandler'
bodyParser   = require 'body-parser'
meshbluJSON  = require './meshblu.json'
Routes       = require './app/routes'

app = express()
app.use morgan('combined')
app.use errorHandler()
app.use bodyParser.json()
app.listen process.env.PIN_AUTHENTICATOR_PORT ? 3003

conn = meshblu.createConnection meshbluJSON
conn.on 'ready', ->
  routes = new Routes app, meshbluJSON.uuid, conn
  routes.register()
