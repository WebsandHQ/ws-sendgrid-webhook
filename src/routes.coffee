_ = require 'underscore'
amqp = require('amqp')

config = require('../config')

config = config.development

MQ_url = config.amqp?.url
MQ_exchange_name = config.amqp?.exchange.name or throw("No exchange name given")
MQ_exchange_options = config.amqp?.exchange?.options or {}
MQ_routing_key = config.amqp?.routing_key
MQ_apps = config.apps or []
console.log "apps: " + MQ_apps


###
# Overview metrics route
###
exports.GET_overview = (req, res) ->
  res.render 'overview.jade',
    locals:
      test_local: 1


# handle a POST webhook
exports.POST_process_webhook = (req, res, next) ->
  queue = req.params.app_name
  console.log "app_name: " + queue
  console.log "body: "
  console.log req.body
  if not(queue in MQ_apps)
    console.log("App: '#{queue}' is not handled! ")
    res.send(500)
    return
  route = MQ_routing_key + queue

  publish req.body, route, (err) ->
    if err
      console.log("publish error: " + err)
      res.send(500)
    else
      res.send(200)


###
private publish(message, callback) - publishes a message to the queue.

payload: JSON string for message to send.
callback: (err) -> : callback when this operation completes
###
publish = (payload, queue, callback) ->
  console.log "1"
  connection = amqp.createConnection()
  connection.on 'ready', ->
    console.log "2"
    console.log MQ_exchange_name
    console.log MQ_exchange_options
    exchange = connection.exchange MQ_exchange_name, MQ_exchange_options

    exchange.on 'open', ->
      console.log "3"
      exchange.publish queue, payload, {mandatory: true}
      console.log "4"
      # try
        # connection.end()
      return callback(null)

  connection.on 'error', (err) ->
    console.log "connection error: " + err
    connection.end()
    connection.close()
    console.log "killed connection?"
    return callback("Publish Error: " + err)
