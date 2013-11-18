_ = require 'underscore'

webhook = require './webhook'

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
  # console.log "app_name: " + queue
  # console.log "body: "
  # console.log req.body

  webhook.publish req.body, queue, (err) ->
    if err
      console.log("publish error: " + err)
      res.send(500)
    else
      res.send(200)


