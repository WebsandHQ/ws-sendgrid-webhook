###
Node Sendgrid Webhook server.
###

basicAuth   = require 'connect-basic-auth'
connect     = require 'connect'
express     = require 'express'

cfg         = require('./config')()
console.log cfg
routes      = require './routes'
console.log "here"


port = process.env.PORT or cfg_metrics?.port or 3000
#set some defaults - runing thought run-coffee-development.sh will set admin:password as credentials
 
BASIC_USER = process.env.BASIC_USER or cfg_metrics?.basic_user or "websand"
BASIC_PASSWORD = process.env.BASIC_PASSWORD or cfg_metrics?.basic_password or "password"
if process.env.DEVELOPMENT?
  console.log "Basic auth user: " + BASIC_USER
  console.log "Basic auth password: " + BASIC_PASSWORD

###
# Setup
###

# server = express.createServer()
server = express()
server.configure ->
  server.set 'views', __dirname + '/../views'
  server.set 'view options',
    layout: false
    pretty: true

  server.use basicAuth (credentials, req, res, next)->
    if ((credentials.username == BASIC_USER) and (credentials.password == BASIC_PASSWORD))
      next()
    else
      res.send 'auth_failed', 403

  server.use connect.urlencoded()
  server.use connect.json()
  ###
  Use /static for all statics so these can be served nginx in production
  ###
  server.use '/static', express.static(__dirname + '/../static/')
  server.use server.router

console.log(__dirname)

# server.error (err, req, res, next) ->
server.use (err, req, res, next) ->
  if err instanceof NotFound
    res.render '404.jade',
      locals:
        title: '404 - Not Found'
      status: 404
  else
    console.log err
    res.render '500.jade',
      locals:
        title: 'The Server Encountered an Error'
        error: err
      status: 500

# server.dynamicHelpers
#   basePath: (req, res) ->
#     # return 'http://' + req.headers.host + '/metrics-dashboard'
#     return ''

###
# Routes
###
server.all '*', (req, res, next) -> req.requireAuthorization req, res, next

server.get '/', routes.GET_overview
server.get '/overview', routes.GET_overview

server.post '/hook/:app_name', routes.POST_process_webhook

# Error message.
server.get '/500', (req, res) ->
  throw new Error('This is a 500 Error')

server.get '/*', (req, res) ->
  console.log "Didn't find: " + req.url
  throw new NotFound("/*")

NotFound = (msg) ->
  @name = 'NotFound'
  Error.call this, msg
  Error.captureStackTrace this, arguments.callee

server.listen port
console.log 'Listening on http://0.0.0.0:' + port
