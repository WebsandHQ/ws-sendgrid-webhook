###
 Handle webhooks from various callers.

The configuration file indicates the 'apps' that we route messages to
The other side of the queues handle the different types of webhooks.  This is
essentially just a webhook clearing house to handle the inbound flux.

Note that the queues are persistent so that if the server goes down then the
messages are retained.

At the moment, the response to a webhook is a 200 or a 500 depending on whether
we accepted it or not.  We accept everything to the queue if we can!
###
amqp = require('amqp')

config = require('../config')

config = config.development

MQ_url = config.amqp?.url
MQ_exchange_name = config.amqp?.exchange.name or throw("No exchange name given")
MQ_exchange_options = config.amqp?.exchange?.options or {}
MQ_routing_key = config.amqp?.routing_key_prefix
MQ_apps = config.apps or []
console.log "apps: " + MQ_apps

# cache the connection to the exchange.
connection = null
exchange = null
current_callback = null

###
private publish(message, callback) - publishes a message to the queue.

payload: JSON string for message to send.
callback: (err) -> : callback when this operation completes
###
exports.publish = (payload, queue, callback) ->
  if not(queue in MQ_apps)
    return callback("App: '#{queue}' is not handled! ")

  queue = MQ_routing_key + queue
  get_connection (err, connection, exchange) ->
    if err then return callback(err)
    console.log "Publising to queue #{queue}"
    exchange.publish queue, payload, {mandatory: true}
    # try
      # connection.end()
    return callback(null)



get_connection = (callback) ->
  current_callback = callback
  if connection != null then return current_callback(null, connection, exchange)

  connection = amqp.createConnection({url: MQ_url})
  connection.on 'ready', ->
    # console.log MQ_exchange_name
    # console.log MQ_exchange_options
    exchange = connection.exchange MQ_exchange_name, MQ_exchange_options

    exchange.on 'open', ->
      current_callback(null, connection, exchange)

  connection.on 'error', (err) ->
    console.log "connection error: " + err
    connection.end()
    console.log "killed connection?"
    return current_callback("Publish Error: " + err)
